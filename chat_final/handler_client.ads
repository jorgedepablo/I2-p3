with Lower_Layer_UDP;

package Handler_Client is

   package LLU renames Lower_Layer_UDP;

   procedure Client_Handler (From : in LLU.End_Point_Type;
                              To : in LLU.End_Point_Type;
                              P_Buffer: access LLU.Buffer_Type);
end Handler_Client;
