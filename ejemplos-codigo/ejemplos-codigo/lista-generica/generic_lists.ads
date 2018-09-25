
generic
   type Element_Type is private;
package Generic_Lists is

   type List_Type is limited private;

   procedure Add (List   : in out List_Type;
                  A_Value: in Element_Type);
   
  
private

   type Cell;
   type List_Type is access Cell;

   type Cell is record
      Value: Element_Type;
      Next: List_Type;
   end record;

end Generic_Lists;

