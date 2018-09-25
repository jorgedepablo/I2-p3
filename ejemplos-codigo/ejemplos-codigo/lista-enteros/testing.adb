with Ada.Text_IO;

with Integer_Lists;

procedure Testing is

  Mi_Lista: Integer_Lists.List_Type;

begin

  Integer_Lists.Add (Mi_Lista, 39);
  Integer_Lists.Add (Mi_Lista, 22);
  Integer_Lists.Add (Mi_Lista, 19);

  Integer_Lists.Print_All (Mi_Lista);

end Testing;

