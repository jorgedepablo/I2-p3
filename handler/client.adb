with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Handlers;

procedure Client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;


   Client_EP : LLU.End_Point_Type;
   Server_EP : LLU.End_Point_Type;
   Request : ASU.Unbounded_String;
   Buffer : aliased LLU.Buffer_Type (1024);


begin

   Server_EP := LLU.Build("127.0.0.1", 6123);
   -- Construye un End_Point libre cualquiera y se ata a él
   LLU.Bind_Any(Client_EP, Handlers.Client_Handler'Access);
   -- Construye el End_Point en el que está atado el servidor

   -- reinicializa el buffer para empezar a utilizarlo
   LLU.Reset(Buffer);

   loop
      Ada.Text_IO.Put("Introduce una cadena caracteres: ");
      Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
      if ASU.Length (Request) /= 0 then
         -- introduce el End_Point del cliente en el Buffer
         -- para que el servidor sepa dónde responder
         LLU.End_Point_Type'Output(Buffer'Access, Client_EP);
         -- introduce el Unbounded_String en el Buffer
         -- (se coloca detrás del End_Point introducido antes)
         ASU.Unbounded_String'Output(Buffer'Access, Request);
         -- envía el contenido del Buffer
         LLU.Send(Server_EP, Buffer'Access);
            -- reinicializa (vacía) el buffer para ahora recibir en él
            LLU.Reset(Buffer);
      else
         exit ;
      end if;
   end loop;

   LLU.Finalize;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Client;
