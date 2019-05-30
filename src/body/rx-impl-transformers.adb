package body Rx.Impl.Transformers is

   ------------------
   -- Get_Observer --
   ------------------

   not overriding function Get_Observer (This : in out Operator) return Into.Holders.Observers.Reference is
      --  This same function, as expression in the spec, bugs out with access checks (???) in 7.3
   begin
      if This.Is_Subscribed then
         return This.Downstream.Ref;
      else
         raise No_Longer_Subscribed;
      end if;
   end Get_Observer;

   ------------------
   -- Set_Observer --
   ------------------

   procedure Set_Observer (This : in out Operator; Consumer : Into.Observer'Class) is
   begin
      if This.Downstream.Is_Empty then
         This.Downstream.Hold (Consumer);
      else
         raise Constraint_Error with "Downstream Observer already set";
      end if;
   end Set_Observer;

   ---------------
   -- Subscribe --
   ---------------

   overriding procedure Subscribe (This : in out Operator; Consumer : in out Into.Observer'Class)
   is
   begin
      if This.Has_Parent then
         declare
            Parent : From.Observable := This.Get_Parent; -- Our own copy
         begin
            This.Set_Observer (Consumer);
            Parent.Subscribe (This);
         end;
      else
         raise Constraint_Error with "Attempting subscription without producer observable";
      end if;
   end Subscribe;

   ------------------
   -- On_Complete  --
   ------------------

   overriding procedure On_Complete  (This : in out Operator) is
   begin
      This.Get_Observer.On_Complete;
      This.Unsubscribe;
   end On_Complete ;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error (This : in out Operator; Error : Errors.Occurrence) is
   begin
      This.Get_Observer.On_Error (Error);
      This.Unsubscribe;
   end On_Error;

   -------------------
   -- Unsubscribe --
   -------------------

   overriding procedure Unsubscribe (This : in out Operator) is
   begin
      This.Downstream.Clear;
   end Unsubscribe;

   ------------------
   -- Concatenate --
   ------------------

   function Concatenate (Producer : From.Observable;
                         Consumer : Operator'Class)
                          return Into.Observable
   is
   begin
      return Actual : Operator'Class := Consumer do
         Actual.Set_Parent (Producer);
      end return;
   end Concatenate;

end Rx.Impl.Transformers;
