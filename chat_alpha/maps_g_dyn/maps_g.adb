with Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   package ASU renames Ada.Strings.Unbounded;
--EL key va a ser el nick
-- Value va a ser el EP a diferencia de los ejemplos
   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);

   procedure Get (M: Map; Key : in Key_Type; Value : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;

   procedure Put (M : in out Map; Key : Key_Type; Value : Value_Type) is
      P_Aux : Cell_A;
      Found : Boolean;
   begin
      P_Aux := M.P_First;
      Found := False;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
      if not Found then
         if M.Length < Max then
            M.P_First := new Cell'(Key, Value, M.P_First);
            M.Length := M.Length + 1;
		   else
			      raise Full_Map;
		   end if;
      end if;
   end Put;

   procedure Delete (M : in out Map; Key : in Key_Type; Success : out Boolean) is
      P_Current : Cell_A;
      P_Previus : Cell_A;
   begin
      Success := False;
      P_Previus := null;
      P_Current := M.P_First;
      while not Success and P_Current /= null loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Previus /= null then
               P_Previus.Next := P_Current.Next;
            end if;
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
            end if;
            Free (P_Current);
         else
            P_Previus := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;
   end Delete;

   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   function First (M : Map) return Cursor is
   begin
      return (M => M, Element_A => M.P_First);
   end First;

   procedure Next (C : in out Cursor) is
   begin
      if C.Element_A /= null then
         C.Element_A := C.Element_A.Next;
      end if;
   end Next;

   function Has_Element (C : Cursor) return Boolean is
   begin
      if C.Element_A /= null then
         return True;
      else
         return False;
      end if;
   end Has_Element;

   function Element (C : Cursor) return Element_Type is

   begin
      if C.Element_A /= null then
         return (Key => C.Element_A.Key, Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;

end Maps_G;
