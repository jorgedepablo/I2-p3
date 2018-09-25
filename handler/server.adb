with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Handlers;

procedure Server is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;

   Server_EP: LLU.End_Point_Type;
   C : Character;


begin

   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build ("127.0.0.1", 6123);

   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP, Handlers.Server_Handler'Access);

   -- bucle infinito
   loop

      Ada.Text_IO.Get_Immediate (C);
      if C = 'T' or C = 't' then
         exit;
      else
         ADA.Text_IO.Put_Line ("Para terminar el servidor pulse t o T");
      end if;

   end loop;

   LLU.Finalize;
   -- nunca se alcanza este punto
   -- si se alcanzara, habría que llamar a LLU.Finalize;

exception
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Server;
