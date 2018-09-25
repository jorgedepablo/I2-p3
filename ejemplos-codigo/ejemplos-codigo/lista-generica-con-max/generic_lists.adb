
package body Generic_Lists is
   
   procedure Add (List   : in out List_Type;
                  A_Value: in Element_Type) is
      P_Aux : Cell_A;
   begin
      if Total = Max then
         raise Full_List;
      end if;
      P_Aux := new Cell;
      P_Aux.Value := A_Value;
      P_Aux.Next  := List.P_First;
      List.P_First := P_Aux;
      List.Total := List.Total + 1;
   end Add;
   
   function Count (List: in List_Type) return Natural is
   begin
      return Total;
   end Count;
   
end Generic_Lists;
