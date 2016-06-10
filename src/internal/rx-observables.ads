with Rx.Count;
with Rx.From;
private with Rx.Just;
private with Rx.Observe_On;
with Rx.Operate;
with Rx.Schedulers;
private with Rx.Subscribe;
with Rx.Subscriptions;
with Rx.Traits.Arrays;
with Rx.Typed;

generic
   with package Typed is new Rx.Typed (<>);
package Rx.Observables is

   -- Shortcuts
   subtype Observable is Typed.Producers.Observable'Class;
   subtype Observer   is Typed.Consumers.Observer'Class;
   subtype T is Typed.Type_Traits.T;

   -- Scaffolding
   package Operate is new Rx.Operate (Typed);
   subtype Operator is Operate.Operator'Class;

   -----------
   -- Count --
   -----------

   generic
      with function Succ (V : T) return T;
   package Counters is
      package Self_Count is new Rx.Count (Operate.Transform, Succ);

      function Count (First : T) return Operator renames Self_Count.Count;
   end Counters;

   ----------
   -- From --
   ----------

   package Default_Arrays is new Rx.Traits.Arrays (Typed, Integer);

   -- Observable from an array of values, useful for literal arrays
   function From (A : Default_Arrays.Typed_Array) return Observable;

   ----------
   -- Just --
   ----------

   -- Observable from single value
   function Just (V : T) return Observable;

   ----------------
   -- Observe_On --
   ----------------

   function Observe_On (Scheduler : Schedulers.Scheduler) return Operator;

   ---------------
   -- Subscribe --
   ---------------

   function Subscribe (On_Next : Typed.Actions.Proc1 := null) return Observer;

   ---------
   -- "&" --
   ---------

   --  Chain preparation
   function "&" (L : Observable;
                 R : Operator)
                 return Observable renames Operate.Transform."&"; -- OMG

   --  Subscribe
   function "&" (L : Observable;
                 R : Observer)
                 return Subscriptions.Subscription;

private

   package From_Arrays is new Rx.From.From_Array (Default_Arrays);
   function From (A : Default_Arrays.Typed_Array) return Observable
                  renames From_Arrays.From;

   package RxJust is new Rx.Just (Typed);
   function Just (V : T) return Observable renames RxJust.Create;

   package RxObserveOn is new Rx.Observe_On (Operate);
   function Observe_On (Scheduler : Schedulers.Scheduler) return Operator renames RxObserveOn.Create;

   package RxSubscribe is new Rx.Subscribe (Typed);
   function Subscribe (On_Next : Typed.Actions.Proc1 := null) return Observer renames RxSubscribe.As;


end Rx.Observables;
