with Ada.Text_IO;
with Ada.Strings.Unbounded.Text_IO;

package body Maps is
   package ASUIO renames Ada.Strings.Unbounded.Text_IO;

   use type Asu.Unbounded_String;


   procedure Get (M       : Map;
                  Key     : in  ASU.Unbounded_String;
                  Value   : out ASU.Unbounded_String;
                  Success : out Boolean) is
      Current : Map;
   begin
      Value := ASU.Null_Unbounded_String;

      Success := False;
      Current := M;
      while not Success and Current /= null loop
         if Current.Key = Key then
            Value := Current.Value;
            Success := True;
         elsif Key > Current.Key then
            Current := Current.Right;
         else
            Current := Current.Left;
         end if;
      end loop;

   end Get;

   procedure Put (M     : in out Map;
                  Key   : ASU.Unbounded_String;
                  Value : ASU.Unbounded_String) is
      Current : Map;
      Parent  : Map;

      type Child_Type is (Right_Child, Left_Child);
      Last_Child_Visited : Child_Type;
      Found : Boolean;
   begin

      if M = null then
         M := new Tree_Node'(Key, Value, null, null);
         return;
      end if;

      Found := False;
      Parent  := null;
      Current := M;
      while not Found and Current /= null loop
         if Current.Key = Key then
            Current.Value := Value;
            Found := True;
         elsif Key > Current.Key then
            Parent  := Current;
            Current := Current.Right;
            Last_Child_Visited := Right_Child;
         else
            Parent  := Current;
            Current := Current.Left;
            Last_Child_Visited := Left_Child;
         end if;
      end loop;

      if not Found then
         if Last_Child_Visited = Right_Child then
            Parent.Right := new Tree_Node'(Key, Value, null, null);
         elsif Last_Child_Visited = Left_Child then
            Parent.Left := new Tree_Node'(Key, Value, null, null);
         end if;
      end if;

   end Put;


   function Min (M : Map) return Map is
      Current : Map;
   begin

      Current := M;
      while Current.Left /= null loop
            Current := Current.Left;
      end loop;

      return Current;

   end Min;


   function Delete_Min (M : Map)  return Map  is
      P_Aux: Map;
      P : Map;
   begin

      P_Aux := M;

      if P_Aux = null then
         return null;
      end if;

      if P_Aux.Left = null then
         P := P_Aux.Right;
         P_Aux := null; -- Hay que liberar memoria si no hay GC
         return P;
      else
         P_Aux.Left := Delete_Min (P_Aux.Left);
         return P_Aux;
      end if;

   end Delete_Min;


   procedure Delete (M       : in out Map;
                     Key     : in  Asu.Unbounded_String;
                     Success : out Boolean) is
      Min : Map;
      P_Aux : Map;
      P_Free : Map;
   begin
      Success := True;

      if M = null then
         Success := False;
         return;
      end if;

      if Key < M.Key and then M.Left /= null Then
         Delete (M.Left, Key, Success);
         return;
      end if;

      if Key > M.Key and then M.Right /= null then
         Delete (M.Right, Key, Success);
         return;
      end if;


      if M.Key = Key then
         if M.Left = null then
            P_Aux := M.Right;
            P_Free := M; -- Si no hay GC, liberar P_Free
            M := P_Aux;
         elsif M.Right = null then
            P_Aux := M.Left;
            P_Free := M; -- Si no hay GC, liberar P_Free
            M := P_Aux;
         else
            Min := Maps.Min (M.Right);
            if Min /= null then
               M.Key := Min.key;
               M.Value := Min.Value;
            end if;
            M.Right := Delete_Min (M.Right);
         end if;
      end if;
   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      if M /= null then
         return 1 + Map_Length (M.Left) + Map_Length (M.Right);
      else
         return 0;
      end if;
   end Map_Length;


   procedure Print_Tree (M : Map) is
   begin
      if M /= null then
         if M.Left /= null then
            Print_Tree (M.Left);
         end if;

         ASUIO.Put_Line ("(" & M.Key & ", " & M.Value & ")");

         if M.Right /= null then
            Print_Tree (M.Right);
         end if;
      end if;
   end Print_Tree;

   procedure Print_Map (M : Map) is
   begin
      Ada.Text_Io.Put_Line ("Symbol Table");
      Ada.Text_Io.Put_Line ("============");

      Print_Tree (M);
   end Print_Map;






end Maps;
