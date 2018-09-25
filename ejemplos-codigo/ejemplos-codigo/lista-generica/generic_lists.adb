with Ada.Text_IO;

package body Generic_Lists is
   procedure Add (List   : in out List_Type;
                  A_Value: in Element_Type) is
      P_Aux : List_Type;
   begin
      P_Aux := new Cell;
      P_Aux.Value := A_Value;
      P_Aux.Next  := List;
      List := P_Aux;
   end Add;

end Generic_Lists;
