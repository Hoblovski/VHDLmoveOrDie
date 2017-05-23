library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MoveController is
    port (
        CLK: in std_logic;
        wasdPressed: in std_logic_vector(3 downto 0);
        X: out std_logic_vector(6 downto 0);
        Y: out std_logic_vector(6 downto 0)
    );
end MoveController;

architecture behave of MoveController is
    signal l_X: std_logic_vector(6 downto 0) := "0101000";
    signal l_Y: std_logic_vector(6 downto 0) := "0011110";
begin
    X <= l_X;
    Y <= l_Y;

    process (CLK) begin
        if (rising_edge(CLK)) then
            if wasdPressed(3) = '1' then -- W
                l_Y <= l_Y - 1;
            elsif wasdPressed(1) = '1' then -- S
                l_Y <= l_Y + 1;
            end if;
            if wasdPressed(2) = '1' then -- A
                l_X <= l_X - 1;
            elsif wasdPressed(0) = '1' then -- D
                l_X <= l_X + 1;
            end if;
        end if;
    end process;

end behave;
