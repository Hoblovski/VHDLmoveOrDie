-- output (0 to F) to display (7 bits)
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity displayDecoder is
    port (
            code: in std_logic_vector(3 downto 0);
            seg_out : out std_logic_vector(6 downto 0)
    );
end displayDecoder;

architecture behave of displayDecoder is begin
    process (code) begin
        case code is
            when  "0000" =>
                seg_out <= "1111110";
            when "0001" =>
                seg_out <= "1100000";
            when "0010" =>
                seg_out <= "1011101";
            when "0011"=>
                seg_out <= "1111001";
            when "0100" =>
                seg_out <= "1100011";
            when "0101" =>
                seg_out  <= "0111011";
            when "0110" =>
                seg_out  <= "0111111";
            when "0111" =>
                seg_out  <= "1101000";
            when "1000" =>
                seg_out  <= "1111111";
            when "1001" =>
                seg_out  <= "1111011";
            when "1010" =>
                seg_out  <= "1101111";
            when "1011" =>
                seg_out  <= "0110111";
            when "1100" =>
                seg_out  <= "0011110";
            when "1101" =>
                seg_out  <= "1110101";
            when "1110" =>
                seg_out  <= "0011111";
            when "1111" =>
                seg_out  <= "0001111";
            when others =>
                seg_out <= "0000000";
        end case;
    end process;
end behave;
