
generic
   type Element_Type is private;
   with function Image(E: Element_Type) return String;
package Generic_List is

   procedure Add (A_Value: in Element_Type);
   
   procedure Print_All;
   
end Generic_List;

