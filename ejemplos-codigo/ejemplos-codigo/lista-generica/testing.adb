with Ada.Text_IO;
with Generic_Lists;
with Lower_Layer_UDP;

procedure Testing is
   package LLU renames Lower_Layer_UDP;
   
   package Integer_Lists is new Generic_Lists(Integer);
   package Float_Lists is new Generic_Lists(Float);
   package EP_Lists is new Generic_Lists(LLU.End_Point_Type);

  Mi_Lista_I: Integer_Lists.List_Type;
  Mi_Lista_F: Float_Lists.List_Type;
  Mi_Lista_EP: EP_Lists.List_Type;

begin

  Integer_Lists.Add (Mi_Lista_I, 39);
  Integer_Lists.Add (Mi_Lista_I, 22);
  Integer_Lists.Add (Mi_Lista_I, 19);

  Float_Lists.Add (Mi_Lista_F, 39.23);
  Float_Lists.Add (Mi_Lista_F, 22.0);
  Float_Lists.Add (Mi_Lista_F, 19.234);
  
  EP_Lists.Add (Mi_Lista_EP, LLU.Build("127.0.0.1", 6001));
  EP_Lists.Add (Mi_Lista_EP, LLU.Build("17.1.2.3", 9567));
  
  LLU.Finalize;
end Testing;

