with Ada.Text_IO;

package body Generic_List is
   
   type Cell;
   type Cell_A is access Cell;

   type Cell is record
      Value: Element_Type;
      Next: Cell_A;
   end record;

   List: Cell_A;
   
   procedure Add (A_Value: in Element_Type) is
      P_Aux : Cell_A;
   begin
      P_Aux := new Cell;
      P_Aux.Value := A_Value;
      P_Aux.Next  := List;
      List := P_Aux;
   end Add;
   
   procedure Print_All is
      P_Aux : Cell_A;
   begin
      P_Aux := List;
      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Image(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_All;
      
   
end Generic_List;
