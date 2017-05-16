-- Clock frequency divider
library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ClkDivider is
    generic (
        n: integer := 1 -- clkin: f0 -> clkout: f0 / (2^n)
    );
    port (
        clkin: in std_logic;
        clkout: out std_logic
    );
end ClkDivider;


architecture behave of ClkDivider is
    signal l_reCnt: std_logic_vector(n - 1 downto 0) := (others => '0');
    signal l_clkout: std_logic := '0';
begin

    clkout <= l_clkout;

    process (clkin) begin
        if (rising_edge(clkin)) then
            l_reCnt <= l_reCnt + 1;
            if (l_reCnt(n - 1) = '1') then
                l_reCnt <= (others => '0');
                l_clkout <= not l_clkout;
            end if;
        end if;
    end process;

end behave;
