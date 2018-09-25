with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Ada.Exceptions;
with Ada.Command_Line;
with Ada.Characters.Handling;
with Handler_Client;
with Chat_Messages;

procedure Chat_CLient_2 is

   package ATI renames Ada.Text_IO;
   package ASU renames Ada.Strings.Unbounded;
   package LLU renames Lower_Layer_UDP;
   package ACL renames Ada.Command_Line;
   package ACH renames Ada.Characters.Handling;
   package CM  renames Chat_Messages;

   use type CM.Message_Type;

   Usage_Error : exception;
   Nick_Error : exception;
   Unreachable_Server : exception;
   Welcome_Error : exception;

   Host : ASU.Unbounded_String;
   Port : Natural;
   Nick : ASU.Unbounded_String;
   IP : ASU.Unbounded_String;
   Server_EP : LLU.End_Point_Type;
   Client_EP_Receive : LLU.End_Point_Type;
   Client_EP_Handler : LLU.End_Point_Type;
   Buffer : aliased LLU.Buffer_Type(1024);
   Expired : Boolean;
   Mess_Type : CM.Message_Type;
   Acogido : Boolean;
   Comentario : ASU.Unbounded_String;

begin

   if ACL.Argument_Count /= 3 then
      raise Usage_Error;
   end if;

   Host := ASU.To_Unbounded_String (ACL.Argument(1));
   Port := Integer'Value (ACL.Argument(2));
   Nick := ASU.To_Unbounded_String (ACL.Argument(3));

   if ACH.To_Lower (ASU.To_String(Nick)) = "server" then
      raise Nick_Error;
   end if;

   IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Host)));
   Server_EP := LLU.Build (ASU.To_String(IP), Port);

   LLU.Bind_Any (Client_EP_Handler, Handler_Client.Client_Handler'Access);
   LLU.Bind_Any (Client_EP_Receive);

   LLU.Reset (Buffer);
   CM.Message_Type'Output (Buffer'Access, CM.Init);
   LLU.End_Point_Type'Output (Buffer'Access, Client_EP_Receive);
   LLU.End_Point_Type'Output (Buffer'Access, Client_EP_Handler);
   ASU.Unbounded_String'Output (Buffer'Access, Nick);
   LLU.Send (Server_EP, Buffer'Access);
   LLU.Reset (Buffer);

   LLU.Receive (Client_EP_Receive, Buffer'Access, 10.0, Expired);
   if Expired then
      raise Unreachable_Server;
   else
      Mess_Type := CM.Message_Type'Input (Buffer'Access);
      if Mess_Type = CM.Welcome then
         ATI.Put ("Mini-Chat v2.0: ");
         Acogido := Boolean'Input (Buffer'Access);
         if not Acogido then
            raise Welcome_Error;
         else
            ATI.Put_Line ("Welcome " & ASU.To_String(Nick));
            ATI.Put (">>");
         end if;
      end if;
   end if;

   loop
      Comentario := ASU.To_Unbounded_String (ATI.Get_Line);
      if ACH.To_Lower (ASU.To_String(Comentario)) = ".quit" then
         LLU.Reset (Buffer);
         CM.Message_Type'Output (Buffer'Access, CM.Logout);
         LLU.End_Point_Type'Output (Buffer'Access, Client_EP_Handler);
         ASU.Unbounded_String'Output (Buffer'Access, Nick);
         LLU.Send (Server_EP, Buffer'Access);
         exit;
      else
         LLU.Reset (Buffer);
         CM.Message_Type'Output (Buffer'Access, CM.Writer);
         LLU.End_Point_Type'Output (Buffer'Access, Client_EP_Handler);
         ASU.Unbounded_String'Output (Buffer'Access, Nick);
         ASU.Unbounded_String'Output (Buffer'Access, Comentario);
         LLU.Send (Server_EP, Buffer'Access);
         ATI.Put (">>");
      end if;
   end loop;

   LLU.Finalize;

exception
   when Usage_Error =>
      ATI.Put_Line ("usage: <Host> <Port> <Nickname>");
      LLU.Finalize;
   when Nick_Error =>
      Ati.Put_Line ("This Nickname is not available");
      LLU.Finalize;
   when Unreachable_Server =>
      ATI.Put_Line ("Server unreachable");
      LLU.Finalize;
   when Welcome_Error =>
      ATI.Put_Line ("IGNORED new user " & ASU.To_String(Nick) &
                     ", nick already used");
      LLU.Finalize;
   when Ex : others =>
      ATI.Put_Line ("UNEXPECTED ERROR: " & Ada.Exceptions.Exception_Name(Ex) &
                     "en: " & Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;
      
end Chat_CLient_2;
