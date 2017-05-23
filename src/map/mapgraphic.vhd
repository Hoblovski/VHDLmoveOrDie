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

entity MapGraphic is
	port (
		x: in std_logic_vector(6 downto 0);
		y: in std_logic_vector(6 downto 0);
        gridCode: out std_logic_vector(3 downto 0)
	);
end MapGraphic;

architecture DummyBehave of MapGraphic is
begin
    process (x, y) begin
        if (y(5) = '1' and y(4) = '1' and (y(3) = '1' or y(2) = '1' or y(1) = '1' or y(0) = '1')) then -- y >= 32 + 16 = 48
            gridCode <= "0001";
        else
            if (y(5) = '1' and x(5) = '1' and (y(4) = '1' or y(3) = '1' or y(2) = '1' or y(1) = '1' or y(0) = '1')) then
                gridCode <= "0001";
            else
                gridCode <= "0000";
            end if;
        end if;
    end process;
end;
