
generic
   type Element_Type is private;
   Max: in Natural := 50;
package Generic_Lists is

   type List_Type is limited private;

   procedure Add (List   : in out List_Type;
                  A_Value: in Element_Type);
   
   Full_List: exception;
   
   function Count (List: in List_Type) return Natural;
  
private

   type Cell;
   type Cell_A is access Cell;

   type Cell is record
      Value: Element_Type;
      Next: List_Type;
   end record;

   type List_Type is record
      P_First: Cell_A;
      Total: Natural := 0;
   end record;
   
end Generic_Lists;

