with Ada.Strings.Unbounded;
with Ada.Text_IO;

package body Handlers is

   package ASU renames Ada.Strings.Unbounded;

   Reply : ASU.Unbounded_String;

   procedure Server_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type) is
    Client_EP: LLU.End_Point_Type;
    Request : ASU.Unbounded_String;

   begin

   Reply := ASU.To_Unbounded_String("Bienvenido");

   Client_EP := LLU.End_Point_Type'Input (P_Buffer);
   Request := ASU.Unbounded_String'Input (P_Buffer);
   Ada.Text_IO.Put ("Petición: ");
   Ada.Text_IO.Put_Line (ASU.To_String(Request));

   LLU.Reset (P_Buffer.all);
   --  introduce el Unbounded_String en el Buffer
   ASU.Unbounded_String'Output (P_Buffer, Reply);

   -- envía el contenido del Buffer
   LLU.Send (Client_EP, P_Buffer);
   LLU.Reset (P_Buffer.all);
   end Server_Handler;

   procedure Client_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type) is


   begin

      Reply := ASU.Unbounded_String'Input(P_Buffer);
      Ada.Text_IO.Put("Respuesta: ");
      Ada.Text_IO.Put_Line (ASU.To_String(Reply));
      LLU.Reset (P_Buffer.all);
   end Client_Handler;

end Handlers;
