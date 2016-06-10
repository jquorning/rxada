with Rx.Traits.Arrays;
with Rx.Traits.Iterable;

package Rx.From is

   pragma Preelaborate;

   generic
      with package Arrays is new Rx.Traits.Arrays (<>);
   package From_Array is
      function From (A : Arrays.Typed_Array) return Arrays.Typed.Producers.Observable'Class;
   end From_Array;

   generic
      with package Iterable is new Rx.Traits.Iterable (<>);
   package From_Iterable is
      function From (C : Iterable.Container) return Iterable.Typed.Producers.Observable'Class;
   end From_Iterable;

end Rx.From;
