with Ada.Strings.Unbounded;

--
-- Este paquete implementa un TAD de una tabla de símbolos implementada
-- como un árbol de búsqueda binaria en el que las claves y los valores
-- son de tipo ASU.Unbounded_String
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

private

   type Tree_Node;
   type Map is access Tree_Node;
   type Tree_Node is record
      Key   : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Value : ASU.Unbounded_String := ASU.Null_Unbounded_String;
      Left  : Map;
      Right : Map;
   end record;

end Maps;
