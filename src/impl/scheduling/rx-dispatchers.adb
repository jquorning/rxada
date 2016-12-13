package body Rx.Dispatchers is

   Shutting_Down : Boolean := False
     with Atomic;

   --------------
   -- Shutdown --
   --------------

   procedure Shutdown is
   begin
      Shutting_Down := True;
   end Shutdown;

   -----------------
   -- Terminating --
   -----------------

   function Terminating return Boolean is (Shutting_Down);

   ------------
   -- Events --
   ------------

   package body Events is

      use Typed.Conversions;

      type Kinds is (On_Next, On_Completed, On_Error);

      type Runner (Kind : Kinds) is new Runnable with record
         Child : Shared.Subscriber;
         case Kind is
            when On_Next      => V : Typed.D;
            when On_Error     => E : Errors.Occurrence;
            when On_Completed => null;
         end case;
      end record;

      overriding procedure Run (R : Runner) is
         RW : Runner := R; -- Local writable copy
      begin
         case R.Kind is
            when On_Next      =>
               begin
                  RW.Child.On_Next (+R.V);
               exception
                  when E : others =>
                     Typed.Default_Error_Handler (RW.Child, E);
               end;
            when On_Error     =>
               RW.Child.On_Error (RW.E);
               if not R.E.Is_Handled then
                  R.E.Reraise; -- Because we are in a new thread, the Error won't go any further
               end if;
            when On_Completed =>
               RW.Child.On_Completed;
         end case;
      end Run;

      -------------
      -- On_Next --
      -------------

      procedure On_Next
        (Sched : in out Dispatcher'Class;
         Observer : Shared.Subscriber;
         V : Typed.Type_Traits.T)
      is
      begin
         Sched.Schedule (Runner'(On_Next, Observer, +V));
      end On_Next;

      ------------------
      -- On_Completed --
      ------------------

      procedure On_Completed
        (Sched : in out Dispatcher'Class;
         Observer : Shared.Subscriber)
      is
      begin
         Sched.Schedule (Runner'(On_Completed, Observer));
      end On_Completed;

      --------------
      -- On_Error --
      --------------

      procedure On_Error
        (Sched : in out Dispatcher'Class;
         Observer : Shared.Subscriber;
         E : Rx.Errors.Occurrence)
      is
      begin
         Sched.Schedule (Runner'(On_Error, Observer, E));
      end On_Error;

   end Events;

   package body Subscribe is

      type Runner is new Runnable with record
         Op : Operate.Holders.Definite;
      end record;

      overriding procedure Run (R : Runner) is
         Parent : Operate.Observable := R.Op.CRef.Get_Parent;
         Child  : Operate.Subscriber := R.Op.CRef;
      begin
         Parent.Subscribe (Child);
      end Run;

      procedure On_Subscribe (Sched : in out Dispatcher'Class; Operator : Operate.Preserver'Class) is
      begin
         Sched.Schedule (Runner'(Runnable with Operate.Holders.Hold (Operator)));
      end On_Subscribe;

   end Subscribe;

end Rx.Dispatchers;
