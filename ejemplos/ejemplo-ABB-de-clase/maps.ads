with Pantalla;
with Ada.Strings.Unbounded;

--
-- This package implements a Symbol Table as a Binary Search Tree of:
--   Key   : ASU.Unbounded_String
--   Value : ASU.Unbounded_String
--

package Maps is
   package ASU renames Ada.Strings.Unbounded;



      type Map is limited private;

   procedure Get (M       : Map;
                  Key     : in  ASU.Unbounded_String;
                  Value   : out ASU.Unbounded_String;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : ASU.Unbounded_String;
                  Value : ASU.Unbounded_String);

   procedure Delete (M      : in out Map;
                     Key     : in  Asu.Unbounded_String;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);

   procedure Draw_Tree (M : Map);

private

   type Tree_Node;
   type Map is access Tree_Node;
   type Tree_Node is record
      Key   : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Value : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Left  : Map;
      Right : Map;
      Color : Pantalla.T_Color;
   end record;

end Maps;
