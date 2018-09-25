with Pantalla;

with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Maps;

procedure Maps_Test is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;
   package ASUTIO renames Ada.Strings.Unbounded.Text_IO;
   use type ASU.Unbounded_String;

   Success : Boolean;

   A_Map : Maps.Map;

   procedure Borrar (Key: String) is
      S : ASU.Unbounded_String;
   begin

      Pantalla.Borrar;
      Pantalla.Mover_Cursor (Pantalla.T_Fila'Last, Pantalla.T_Columna'Last/2);
      Pantalla.Poner_Color (Pantalla.Rojo);
      Ada.Text_Io.Put_Line ("Press Enter to Delete " & Key);
      Pantalla.Poner_Color (Pantalla.Blanco);

      Maps.Draw_Tree(A_Map);

      S:=ASU.To_Unbounded_STring(Ada.Text_Io.Get_Line);

      Maps.Delete(A_Map, ASU.To_Unbounded_String(Key), Success);
   end Borrar;

   procedure Insertar (key: String; Value: string) is
      S : ASU.Unbounded_String;
   begin
      Pantalla.Borrar;
      Pantalla.Mover_Cursor (Pantalla.T_Fila'Last, Pantalla.T_Columna'Last/2-10);
      Pantalla.Poner_Color (Pantalla.Verde);
      Ada.Text_Io.Put_Line ("Press <ENTER> to Put (" & Key & ", " & Value & ")");


      Pantalla.Poner_Color (Pantalla.Blanco);

      Maps.Draw_Tree(A_Map);

      Maps.Put (A_Map, ASU.To_Unbounded_String (Key),
                ASU.To_Unbounded_String (Value));

      S:=ASU.To_Unbounded_STring(Ada.Text_Io.Get_Line);

   end Insertar;


begin

   Insertar("nbc.com", "66.77.124.26");
   Insertar("facebook.com", "69.63.181.12");
   Insertar("yelp.com", "63.251.52.110");
   Insertar("zappos.com", "66.209.92.150");
   Insertar("google.com", "69.63.189.16");
   Insertar("bbva.es", "195.76.187.83");
   Insertar("cbs.com", "198.99.118.37");
   Insertar("google.com", "66.249.92.104");
   Insertar("edi.com", "192.86.2.98");
   Insertar("viacom.com", "206.220.43.92");
   Insertar("xing.com", "213.238.60.19");
   Insertar("facebook.com", "69.63.189.11");
   Insertar("ucla.edu", "169.232.55.22");
   Insertar("wings.com", "12.155.29.35 ");


   ------------

   Borrar("google.com");
   Borrar("nbc.com");
   Borrar("ucla.edu");
   Borrar("viacom.com");
   Borrar("edi.com");
   Borrar("yelp.com");
   Borrar("bbva.es");
   Borrar("xing.com");
   Borrar("facebook.com");
   Borrar("wings.com");
   Borrar("cbs.com");
   Borrar("zappos.com");




   ----------------------

   Pantalla.Borrar;


end Maps_Test;
