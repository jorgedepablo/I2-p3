with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.Command_Line;
with Ada.Characters.Handling;
with Chat_Messages;
with Handler_Server;

procedure Chat_Server_2 is

   package ATI renames Ada.Text_IO;
   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ACH renames Ada.Characters.Handling;
   package CM  renames Chat_Messages;

   use type CM.Message_Type;

   Usage_Error : exception;
   Number_Clients_Error : exception;

   Host : ASU.Unbounded_String;
   Port : Natural;
   IP : ASU.Unbounded_String;
   Max_Clients : Natural;
   Server_EP : LLU.End_Point_Type;
   C : Character;

begin

   if ACL.Argument_Count /= 2 then
      raise Usage_Error;
   end if;

   Port := Integer'Value (ACL.Argument(1));
   Max_Clients := Integer'Value (ACL.Argument(2));
   Host := ASU.To_Unbounded_String (LLU.Get_Host_Name);
   IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Host)));

   if Max_Clients < 2 or Max_Clients > 50 then
      raise Number_Clients_Error;
   end if;

   Server_EP := LLU.Build (ASU.To_String(IP), Port);
   LLU.Bind (Server_EP, Handler_Server.Server_Handler'Access);

   loop
      ATI.Get_Immediate (C);
      if ACH.To_Lower (C) = 'l' then
         Handler_Server.Show_Active_Clients;
      elsif ACH.To_Lower (C) = 'o' then
         Handler_Server.Show_Old_Clients;
      else
         ATI.Put_Line ("To see active clients press 'l' or 'L'");
         ATI.Put_Line ("To see old clients press 'o' or 'O'");
      end if;
   end loop;

exception
   when Usage_Error =>
      ATI.Put_Line ("usage: <Port> <Clients[2 to 50]>");
      LLU.Finalize;
   when Number_Clients_Error =>
      ATI.Put_Line ("Invalid number of clients, must be [2 to 50]");
      LLU.Finalize;
   when Ex : others =>
      ATI.Put_Line ("UNEXPECTED ERROR: " & Ada.Exceptions.Exception_Name(Ex) &
                     "en: " & Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;
