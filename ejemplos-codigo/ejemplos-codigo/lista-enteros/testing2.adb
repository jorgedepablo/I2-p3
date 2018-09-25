with Ada.Text_IO;

with Integer_Lists;
with Float_Lists;

procedure Testing2 is

  Mi_Lista_I: Integer_Lists.List_Type;
  Mi_Lista_F: Float_Lists.List_Type;

begin

  Integer_Lists.Add (Mi_Lista_I, 39);
  Integer_Lists.Add (Mi_Lista_I, 22);
  Integer_Lists.Add (Mi_Lista_I, 19);

  Integer_Lists.Print_All (Mi_Lista_I);

  Float_Lists.Add (Mi_Lista_F, 39.23);
  Float_Lists.Add (Mi_Lista_F, 22.0);
  Float_Lists.Add (Mi_Lista_F, 19.234);

  Float_Lists.Print_All (Mi_Lista_F);
end Testing2;

