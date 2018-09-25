with Ada.Text_IO;
with Generic_Lists;

procedure Testing is
   
   package Integer_Lists is new Generic_Lists(Integer);

   Mi_Lista_I: Integer_Lists.List_Type;

begin

   Integer_Lists.Add (Mi_Lista_I, 39);
   Integer_Lists.Add (Mi_Lista_I, 22);
   Integer_Lists.Add (Mi_Lista_I, 19);
   Ada.Text_IO.Put_Line ("Enteros: " & 
			   Natural'Image(Integer_Lists.Count(Mi_Lista_I)));

end Testing;

