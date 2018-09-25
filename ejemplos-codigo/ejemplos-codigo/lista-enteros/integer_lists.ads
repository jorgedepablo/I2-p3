package Integer_Lists is

   type List_Type is limited private;

   procedure Add (List   : in out List_Type;
                  A_Value: in Integer);

   procedure Print_All (List: in List_Type);


private

   type Cell;
   type List_Type is access Cell;

   type Cell is record
      Value: Integer;
      Next: List_Type;
   end record;

end Integer_Lists;

