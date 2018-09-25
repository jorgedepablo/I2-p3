--
--  TAD de una tabla de símbolos (map) implementada como una lista
--  enlazada no ordenada.
--

with Ada.Strings.Unbounded;

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

   procedure Delete (M       : in out Map;
                     Key     : in  Asu.Unbounded_String;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   --
   -- Cursor Interface for iterating over Map elements
   --
   type Cursor is limited private;
   function First (M: Map) return Cursor;
   procedure Next (C: in out Cursor);
   function Has_Element (C: Cursor) return Boolean;
   type Element_Type is record
      Key:   ASU.Unbounded_String;
      Value: ASU.Unbounded_String;
   end record;
   No_Element: exception;
   -- Raises No_Element if Has_Element(C) = False;
   function Element (C: Cursor) return Element_Type;

private

   type Cell;
   type Cell_A is access Cell;
   type Cell is record
      Key   : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Value : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Next  : Cell_A;
   end record;

   type Map is record
      P_First : Cell_A;
      Length  : Natural := 0;
   end record;

   type Cursor is record
      M         : Map;
      Element_A : Cell_A;
   end record;

end Maps;
