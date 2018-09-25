with Ada.Strings.Unbounded;

package Cut_Directions is

   package ASU renames Ada.Strings.Unbounded;

   procedure Client_Address (Address: in out ASU.Unbounded_String);

end Cut_Directions;
