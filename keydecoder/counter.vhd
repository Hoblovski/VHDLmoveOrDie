library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Counter is
    port (
        datain: in std_logic;
        dataout: out std_logic_vector(3 downto 0)
    );
end Counter;

architecture behave of Counter is
    signal ldataout: std_logic_vector(3 downto 0);
begin
    dataout <= ldataout;

    process (datain) begin
        if (rising_edge(datain)) then
            ldataout <= ldataout + 1;
        end if;
    end process;
end behave;
