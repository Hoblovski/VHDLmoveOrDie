library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;

--    +-------------------> x / 80
--    |                           
--    |
--    |
--    |
--    |
--    V y / 60

entity MapLogic is
	port (
		x: in std_logic_vector(6 downto 0);
		y: in std_logic_vector(6 downto 0);
        lblk, rblk, ublk, dblk: out std_logic
	);
end MapLogic;

architecture DummyBehave of MapLogic is
begin
    process (x, y) begin
        if (x /= ("0000000")) then
            lblk <= '0';
        else
            lblk <= '1';
        end if;
        rblk <= '0';
        ublk <= '0';
        if (y(5) = '1' and y(4) = '1') then -- y >= 32 + 16 = 48
            dblk <= '1';
        else
            if (y(5) = '1' and x(5) = '1') then
                dblk <= '1';
            else
                dblk <= '0';
            end if;
        end if;
    end process;
end;
