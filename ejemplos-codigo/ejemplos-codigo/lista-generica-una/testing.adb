with Ada.Text_IO;
with Generic_List;

procedure Testing is
   
   package Integer_List_1 is new Generic_List(Integer, Integer'Image);
   package Integer_List_2 is new Generic_List(Integer, Integer'Image);

begin

   Integer_List_1.Add (39);
   Integer_List_1.Add (22);
   Integer_List_1.Add (19);
   Integer_List_1.Print_All;
   
   Ada.Text_IO.New_Line;
   Integer_List_2.Add (-12);
   Integer_List_2.Add (111);
   Integer_List_2.Add (123);
   Integer_List_2.Print_All;
  
end Testing;

