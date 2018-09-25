with Chat_Messages;
with Ada.Text_IO;
with Cut_Directions;

package body Handler_Server is

   package CM  renames Chat_Messages;
   package ATI renames Ada.Text_IO;
   package CD renames Cut_Directions;

   use type CM.Message_Type;

   function Time_Image (T: Ada.Calendar.Time) return String is
   begin
      return Gnat.Calendar.Time_IO.Image (T, "%d-%b-%y %T.%i");
   end Time_Image;

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

   procedure Search_Oldest (M : in AC.Map;
                              Nick_Old : out ASU.Unbounded_String) is
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

   procedure Send_Welcome (Client_EP_Receive : in out LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type;
                              Acogido : Boolean) is
   begin
      CM.Message_Type'Output (P_Buffer, CM.Welcome);
      Boolean'Output (P_Buffer, Acogido);
      LLU.Send (Client_EP_Receive, P_Buffer);
      LLU.Reset (P_Buffer.all);
   end Send_Welcome;

   procedure Report_Joins_In_Chat (Nick : in ASU.Unbounded_String;
                                     P_Buffer : access LLU.Buffer_Type) is
   begin
      CM.Message_Type'Output (P_Buffer, CM.Server);
      ASU.Unbounded_String'Output (P_Buffer,
                                    ASU.To_Unbounded_String("server"));
      ASU.Unbounded_String'Output (P_Buffer,
                                    ASU.To_Unbounded_String (ASU.To_String(Nick)
                                   & " joins the chat"));
      Send_To_All (Connected_Clients, P_Buffer, Nick);
      LLU.Reset (P_Buffer.all);
   end Report_Joins_In_Chat;

   procedure Ban_Client (Nick_Old : in ASU.Unbounded_String;
                           Hour : in Ada.Calendar.Time) is
      Success : Boolean;
   begin
      AC.Delete (Connected_Clients, Nick_Old, Success);

      if Success then
         OC.Put (Disconnected_Clients, Nick_Old, Hour);
      end if;
   end Ban_Client;

   procedure Report_Ban (Nick : in ASU.Unbounded_String;
                           Nick_Old : in ASU.Unbounded_String;
                           P_Buffer : access LLU.Buffer_Type) is
   begin
      CM.Message_Type'Output (P_Buffer, CM.Server);
      ASU.Unbounded_String'Output (P_Buffer, ASU.To_Unbounded_String("server"));
      ASU.Unbounded_String'Output (P_Buffer,
                                   ASU.To_Unbounded_String(ASU.To_String(Nick_Old)
                                   & " banned for being idle too long"));
      Send_To_All (Connected_Clients, P_Buffer, Nick);
      LLU.Reset (P_Buffer.all);
   end Report_Ban;

   procedure Send_Writer (Nick : in ASU.Unbounded_String;
                           Comentario : in ASU.Unbounded_String;
                           P_Buffer : access LLU.Buffer_Type) is
   begin
      CM.Message_Type'Output (P_Buffer, CM.Server);
      ASU.Unbounded_String'Output (P_Buffer, Nick);
      ASU.Unbounded_String'Output (P_Buffer, Comentario);
      Send_To_All (Connected_Clients, P_Buffer, Nick);
      LLU.Reset (P_Buffer.all);
   end Send_Writer;

   procedure Report_Left_Chat (Nick : in ASU.Unbounded_String;
                                 P_Buffer : access LLU.Buffer_Type) is
   begin
      CM.Message_Type'Output (P_Buffer, CM.Server);
      ASU.Unbounded_String'Output (P_Buffer,
                                    ASU.To_Unbounded_String("server"));
      ASU.Unbounded_String'Output (P_Buffer,
                                    ASU.To_Unbounded_String (ASU.To_String(Nick)
                                     & " leaves the chat"));
      Send_To_All (Connected_Clients, P_Buffer, Nick);
      LLU.Reset (P_Buffer.all);
   end Report_Left_Chat;

   procedure Server_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer : access LLU.Buffer_Type) is
      Mess_Type : CM.Message_Type;
      Client_EP_Receive : LLU.End_Point_Type;
      Client_EP_Handler : LLU.End_Point_Type;
      Nick : ASU.Unbounded_String;
      Comentario : ASU.Unbounded_String;
      Hour : Ada.Calendar.Time;
      Value_Aux : AC_Value;
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
            if not Success then
               ATI.Put_Line ("ACCEPTED");
               Send_Welcome (Client_EP_Receive, P_Buffer, True);
               begin
                  AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                  Report_Joins_In_Chat (Nick, P_Buffer);
               exception
                  when AC.Full_Map =>
                     Search_Oldest (Connected_Clients, Nick_Old);
                     Report_Ban (Nick, Nick_Old, P_Buffer);
                     Ban_Client (Nick_Old, Hour);
                     AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                     Report_Joins_In_Chat (Nick, P_Buffer);
               end;
            else
               ATI.Put_Line ("IGNORED. nick already used");
               Send_Welcome (Client_EP_Receive, P_Buffer, False);
            end if;
         when CM.Writer =>
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            Nick := ASU.Unbounded_String'Input (P_Buffer);
            Comentario := ASU.Unbounded_String'Input (P_Buffer);
            LLU.Reset (P_Buffer.all);

            Hour := Ada.Calendar.Clock;
            AC.Get (Connected_Clients, Nick, Value_Aux, Success);
            ATI.Put ("WRITER received from ");
            if Success then
               if LLU.Image (Value_Aux.EP) = LLU.Image (Client_EP_Handler) then
                  AC.Put (Connected_Clients, Nick, (Client_EP_Handler, Hour));
                  ATI.Put (ASU.To_String(Nick) & ": ");
                  ATI.Put_Line (ASU.To_String(Comentario));
                  Send_Writer (Nick, Comentario, P_Buffer);
               end if;
            else
               ATI.Put_Line ("unknown client. IGNORED");
            end if;
         when CM.Logout =>
            Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
            Nick := ASU.Unbounded_String'Input (P_Buffer);
            LLU.Reset (P_Buffer.all);
            ATI.Put ("LOGOUT receiver from ");
            AC.Get (Connected_Clients, Nick, Value_Aux, Success);
            if Success then
               ATI.Put_Line (ASU.To_String(Nick));
               if LLU.Image (Value_Aux.EP) = LLU.Image (Client_EP_Handler) then
                  AC.Delete (Connected_Clients, Nick, Success);
                  if Success then
                     Hour := Ada.Calendar.Clock;
                     OC.Put (Disconnected_Clients, Nick, Hour);
                  end if;
                  Report_Left_Chat (Nick, P_Buffer);
               end if;
            else
               ATI.Put_Line ("unknown client. IGNORED");
            end if;
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
         Address := ASU.To_Unbounded_String (LLU.Image(Element_Aux.Value.EP));
         CD.Client_Address (Address);
         ATI.Put (ASU.To_String(Nick) & " ");
         ATI.Put (ASU.To_String(Address) & " ");
         ATI.Put_Line (Time_Image(Hour));
         AC.Next (C);
      end loop;
   end;

   procedure Show_Old_Clients is
      M : OC.Map;
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
         ATI.Put (ASU.To_String(Nick) & ": ");
         ATI.Put_Line (Time_Image(Hour));
         OC.Next (C);
      end loop;
   end;

end Handler_Server;
