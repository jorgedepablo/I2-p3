package body Cut_Directions is

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

end Cut_Directions;
