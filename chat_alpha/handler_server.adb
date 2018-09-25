with Chat_Messages;
with Ada.Text_IO;

package body Handler_Server is

   package CM  renames Chat_Messages;
   package ATI renames Ada.Text_IO;
-- Los otros paquetes y los mapas/lista de clientes activos y old clients estan definidoes en el ads
   use type CM.Message_Type;

   function Time_Image (T: Ada.Calendar.Time) return String is
   begin
      return Gnat.Calendar.Time_IO.Image (T, "%d-%b-%y %T.%i");
   end Time_Image;

   procedure Client_Address (Address: in out ASU.Unbounded_String) is
        Posicion: Natural;
        Port: ASU.Unbounded_String;
        IP: ASU.Unbounded_String;
    begin
        Posicion := ASU.Index (Address, ":" );
        Address := ASU.Tail (Address, ASU.Length(Address)-(Posicion+1));
        Posicion := ASU.Index (Address, ",");
        IP := ASU.Head (Address, Posicion-1);
        Posicion := ASU.Index (Address, ":");
        Port := ASU.Tail (Address, ASU.Length(Address)-Posicion);
        Posicion := ASU.Index (Port, " ");
        Port := ASU.Tail (Port, ASU.Length(Port)-(Posicion+1));
        Address := ASU.To_Unbounded_String (ASU.To_String(IP) & ":" & ASU.To_String(Port));
    end Client_Address;

   procedure Send_To_All (M : AC.Map;
                        P_Buffer : access LLU.Buffer_Type;
                        Nick : ASU.Unbounded_String) is
   C: AC.Cursor := AC.First (Connected_Clients);
   Element_Aux : AC.Element_Type;
   begin
       while AC.Has_Element (C) loop
           Element_Aux := AC.Element (C);
           if ASU.To_String (Element_Aux.Key) = ASU.To_String (Nick) then
               AC.Next (C);
           else
               LLU.Send (Element_Aux.Value.EP, P_Buffer);
               AC.Next (C);
           end if;
       end loop;
   end Send_To_All;

   procedure Search_Oldest (M : in AC.Map; Nick_Old : out ASU.Unbounded_String) is
      C : AC.Cursor := AC.First (Connected_Clients);
      Element_Aux : AC.Element_Type;
      Last_Seen : Ada.Calendar.Time;
   begin
      Nick_Old := AC.Element(C).Key;
      Last_Seen := AC.Element(C).Value.Hour;
      while AC.Has_Element (C) loop
         Element_Aux := AC.Element (C);
         if Last_Seen > Element_Aux.Value.Hour then
            Nick_Old := Element_Aux.Key;
            Last_Seen := Element_Aux.Value.Hour;
            AC.Next (C);
         else
            AC.Next (C);
         end if;
      end loop;
   end Search_Oldest;

   procedure Server_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type) is
      Mess_Type : CM.Message_Type;
      Client_EP_Receive : LLU.End_Point_Type;
      Client_EP_Handler : LLU.End_Point_Type;
      Nick : ASU.Unbounded_String;
      Acogido : Boolean;
      Comentario : ASU.Unbounded_String;
      Hour : Ada.Calendar.Time;
      Value_Aux : AC_Value; --Evita en error en los out Value
      Success : Boolean;
      Nick_Old : ASU.Unbounded_String;
   begin
      Mess_Type := CM.Message_Type'Input (P_Buffer);
      case Mess_Type is
         when CM.Init =>
            Client_EP_Receive := LLU.End_Point_Type'Input (P_Buffer);
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            Nick := ASU.Unbounded_String'Input (P_Buffer);
            LLU.Reset (P_Buffer.all);
            Hour := Ada.Calendar.Clock;
            ATI.Put ("INIT received from " & ASU.To_String(Nick) & ": ");
            AC.Get (Connected_Clients, Nick, Value_Aux, Success);
            --Comprueba si está en la lista el nick y devuelve success
            if not Success then
               begin
                  AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                  --Aqui se le añade al mapa
                  ATI.Put_Line ("ACCEPTED");
                  Acogido := True;
                  CM.Message_Type'Output (P_Buffer, CM.Welcome);
                  Boolean'Output (P_Buffer, Acogido);
                  LLU.Send (Client_EP_Receive, P_Buffer);
                  LLU.Reset (P_Buffer.all);
                  --Mandar un mensaje a los demas
                  CM.Message_Type'Output (P_Buffer, CM.Server);
                  ASU.Unbounded_String'Output (P_Buffer,
                                                ASU.To_Unbounded_String("server"));
                  ASU.Unbounded_String'Output (P_Buffer,
                                                ASU.To_Unbounded_String (ASU.To_String(Nick)
                                               & " joins the chat"));
                  Send_To_All (Connected_Clients, P_Buffer, Nick);
                  LLU.Reset (P_Buffer.all);
                  --Hacer lo de echar al ultimo si no hay hueco
               exception
                  when AC.Full_Map =>
                     Search_Oldest (Connected_Clients, Nick_Old);
                     CM.Message_Type'Output (P_Buffer, CM.Server);
                     ASU.Unbounded_String'Output (P_Buffer,
                                                   ASU.To_Unbounded_String("server"));
                     ASU.Unbounded_String'Output (P_Buffer,
                                                   ASU.To_Unbounded_String (ASU.To_String(Nick_Old)
                                                    & " banned for being idle too long"));
                     Send_To_All (Connected_Clients, P_Buffer, Nick);
                     LLU.Reset (P_Buffer.all);
                     -- Borrar el viejo
                     AC.Delete (Connected_Clients, Nick_Old, Success);
                     -- hay que borrarlo de los activos y meterlos en los viejos
                     if Success then
                        OC.Put (Disconnected_Clients, Nick_Old, Hour);
                     end if;
                     AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                     ATI.Put_Line ("ACCEPTED");
                     Acogido := True;
                     CM.Message_Type'Output (P_Buffer, CM.Welcome);
                     Boolean'Output (P_Buffer, Acogido);
                     LLU.Send (Client_EP_Receive, P_Buffer);
                     LLU.Reset (P_Buffer.all);
                     --Mandar un mensaje a los demas
                     CM.Message_Type'Output (P_Buffer, CM.Server);
                     ASU.Unbounded_String'Output (P_Buffer,
                                                   ASU.To_Unbounded_String("server"));
                     ASU.Unbounded_String'Output (P_Buffer,
                                                   ASU.To_Unbounded_String (ASU.To_String(Nick)
                                                  & " joins the chat"));
                     Send_To_All (Connected_Clients, P_Buffer, Nick);
                     LLU.Reset (P_Buffer.all);
               end;
            else
               ATI.Put_Line ("IGNORED. nick already used");
               Acogido := False;
               CM.Message_Type'Output (P_Buffer, CM.Welcome);
               Boolean'Output (P_Buffer, Acogido);
               LLU.Send (Client_EP_Receive, P_Buffer);
               LLU.Reset (P_Buffer.all);
               -- no se si tengo que informar de que ha llegado un robanicks a los demás
            end if;
         when CM.Writer =>
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            Nick := ASU.Unbounded_String'Input (P_Buffer);
            Comentario := ASU.Unbounded_String'Input (P_Buffer);
            LLU.Reset (P_Buffer.all);
            --Comprobar el nick y el EP y si pasa
            AC.Get (Connected_Clients, Nick, Value_Aux, Success);
            ATI.Put ("WRITER received from ");
            if Success then
               if LLU.Image (Value_Aux.EP) = LLU.Image (Client_EP_Handler) then
                  --VOLVER A GUARDARLOS CON LA HORA NUEVA
                  Hour := Ada.Calendar.Clock;
                  AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                  --enviar un mensaje server con el comentario a todos excepto al que lo ha enviado
                  CM.Message_Type'Output (P_Buffer, CM.Server);
                  ASU.Unbounded_String'Output (P_Buffer, Nick);
                  ASU.Unbounded_String'Output (P_Buffer, Comentario);
                  Send_To_All (Connected_Clients, P_Buffer, Nick);
                  LLU.Reset (P_Buffer.all);
                  ATI.Put_Line (ASU.To_String(Nick) & ": " & ASU.To_String(Comentario));
                  --send to all
               end if;
            else
               ATI.Put_Line ("unknown client. IGNORED");
            end if;
            -- Que hacer si no pasa lo del nick y el EP ??
         when CM.Logout =>
         -- Pregunta que hacer si se recive un Logout de un baneado 
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            Nick := ASU.Unbounded_String'Input (P_Buffer);
            LLU.Reset (P_Buffer.all);
            ATI.Put_Line ("LOGOUT receiver from " & ASU.To_String(Nick));
            --buscar el nick entre los clientes activos y si lo encuentra comprobar que EP coincide
            AC.Get (Connected_Clients, Nick, Value_Aux, Success);
            if Success then
               if LLU.Image (Value_Aux.EP) = LLU.Image (Client_EP_Handler) then
                  AC.Delete (Connected_Clients, Nick, Success);
                  -- hay que borrarlo de los activos y meterlos en los viejos
                  if Success then
                     Hour := Ada.Calendar.Clock;
                     OC.Put (Disconnected_Clients, Nick, Hour);
                  end if;
               end if;
            -- enviar un mensaje al resto de clientes de que ha abandonado el chat
            CM.Message_Type'Output (P_Buffer, CM.Server);
            ASU.Unbounded_String'Output (P_Buffer,
                                          ASU.To_Unbounded_String("server"));
            ASU.Unbounded_String'Output (P_Buffer,
                                          ASU.To_Unbounded_String (ASU.To_String(Nick)
                                           & " leaves the chat"));
            Send_To_All (Connected_Clients, P_Buffer, Nick);
            LLU.Reset (P_Buffer.all);
            end if;
            -- no se que hacer si no pasa la autentificacion del nick y EP, preguntar en clase
         when others =>
            ATI.Put_Line ("Type of messages not found");
      end case;
   end Server_Handler;

   procedure Show_Active_Clients is
      M : AC.Map;
      C : AC.Cursor := AC.First (Connected_Clients);
      Element_Aux : AC.Element_Type;
      Nick : ASU.Unbounded_String;
      Address : ASU.Unbounded_String;
      Hour : Ada.Calendar.Time;
   begin
      ATI.Put_Line ("ACTIVE CLIENTS");
      ATI.Put_Line ("==============");
      while AC.Has_Element (C) loop
         Element_Aux := AC.Element (C);
         Nick := Element_Aux.Key;
         Hour := Element_Aux.Value.Hour;
         -- HAcer lo de los espacios creo que es el mismo codigo que la practica anterior;
         Address := ASU.To_Unbounded_String (LLU.Image(Element_Aux.Value.EP));
         Client_Address (Address);
         ATI.Put (ASU.To_String(Nick) & " ");
         ATI.Put (ASU.To_String(Address) & " ");
         ATI.Put_Line (Time_Image(Hour));
         AC.Next (C);
      end loop;
   end;

   procedure Show_Old_Clients is
      M : OC.Map;
      -- Si pongo ahi Disconnected_Clients me peta no se porque
      C : OC.Cursor := OC.First (Disconnected_Clients);
      Element_Aux : OC.Element_Type;
      Nick : ASU.Unbounded_String;
      Hour : Ada.Calendar.Time;
   begin
      ATI.Put_Line ("OLD CLIENTS");
      ATI.Put_Line ("==============");
      while OC.Has_Element (C) loop
         Element_Aux := OC.Element (C);
         Nick := Element_Aux.Key;
         Hour := Element_Aux.Value;
         -- Imprime el nick y a la hora a la que se ha pirado
         ATI.Put (ASU.To_String(Nick) & ": ");
         ATI.Put_Line (Time_Image(Hour));
         OC.Next (C);
      end loop;
   end;

end Handler_Server;
