-- WASD decoder
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

entity KeyboardDecoder is
    port (
        fclk: in std_logic;                      -- filter fclk
        ie: in std_logic;                       -- input enable
        code: in std_logic_vector(7 downto 0);
        wasdPressed: out std_logic_vector(3 downto 0)
    );
end KeyboardDecoder;

architecture behave of KeyboardDecoder is
    type stateType is (break, start);
    signal state: stateType := start;
    signal lwasdPressed: std_logic_vector(3 downto 0) := "0000";

begin
    wasdPressed <= lwasdPressed;

    process (fclk, ie) begin
        if (rising_edge(ie)) then
            --if (ie = '1') then
                case state is
                    when start =>
                        case code is
                            when x"F0" =>
                                state <= break;
                            when x"1D" =>
                                lwasdPressed(3) <= '1';
                            when x"1C" =>
                                lwasdPressed(2) <= '1';
                            when x"1B" =>
                                lwasdPressed(1) <= '1';
                            when x"23" =>
                                lwasdPressed(0) <= '1';
                            when others =>
                                null;
                        end case;
                    when break =>
                        case code is
                            when x"1D" =>
                                lwasdPressed(3) <= '0';
                            when x"1C" =>
                                lwasdPressed(2) <= '0';
                            when x"1B" =>
                                lwasdPressed(1) <= '0';
                            when x"23" =>
                                lwasdPressed(0) <= '0';
                            when others =>
                                null;
                        end case;
                        state <= start;
                end case;
            --end if;
        end if;
    end process;

end behave;
