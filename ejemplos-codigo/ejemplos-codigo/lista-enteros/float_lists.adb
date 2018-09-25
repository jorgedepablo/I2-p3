with Ada.Text_IO;

package body Float_Lists is
   procedure Add (List   : in out List_Type;
                  A_Value: in Float) is
      P_Aux : List_Type;
   begin
      P_Aux := new Cell;
      P_Aux.Value := A_Value;
      P_Aux.Next  := List;
      List := P_Aux;
   end Add;

   procedure Print_All (List: in List_Type) is
      P_Aux : List_Type;
   begin
      P_Aux := List;
      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Float'Image(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_All;
end Float_Lists;
