with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Text_IO;

package body Handler_Client is

   package ASU renames Ada.Strings.Unbounded;
   package CM  renames Chat_Messages;
   package ATI renames Ada.Text_IO;

   use type CM.Message_Type;

   procedure Client_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type) is
      Mess_Type : CM.Message_Type;
      Nick : ASU.Unbounded_String;
      Reply : ASU.Unbounded_String;

   begin
      Mess_Type := CM.Message_Type'Input (P_Buffer);
      Nick := ASU.Unbounded_String'Input (P_Buffer);
      Reply := ASU.Unbounded_String'Input (P_Buffer);

      if Mess_Type = CM.Server then
         ATI.Put (ASCII.LF);
         ATI.Put_Line (ASU.To_String(Nick) & ": " & ASU.To_String(Reply));
         ATI.Put (">>");
      end if;

   end Client_Handler;

end Handler_Client;
