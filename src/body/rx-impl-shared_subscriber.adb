with Ada.Unchecked_Deallocation;

-- with Gnat.IO; use Gnat.IO;

package body Rx.Impl.Shared_Subscriber is

   ------------
   -- Create --
   ------------

   function Create (Held : Typed.Observer) return Subscriber is
   begin
      return (Actual => new Typed.Observer'(Held));
   end Create;

   -------------
   -- Release --
   -------------

   procedure Release (This : in out Subscriber) is
      procedure Free is new Ada.Unchecked_Deallocation (Typed.Observer, Subscriber_Access);
   begin
      Free (This.Actual);
   end Release;

   -------------
   -- On_Next --
   -------------

   overriding procedure On_Next
     (This : in out Subscriber;
      V : Typed.Type_Traits.T)
   is
   begin
      This.Actual.On_Next (V);
   end On_Next;

   ------------------
   -- On_Completed --
   ------------------

   overriding procedure On_Completed (This : in out Subscriber) is
   begin
      This.Actual.On_Completed;
      This.Release;
   end On_Completed;

   --------------
   -- On_Error --
   --------------

   overriding procedure On_Error
     (This  : in out Subscriber;
      Error :        Errors.Occurrence)
   is
   begin
      This.Actual.On_Error (Error);
      This.Release;
   end On_Error;

end Rx.Impl.Shared_Subscriber;
