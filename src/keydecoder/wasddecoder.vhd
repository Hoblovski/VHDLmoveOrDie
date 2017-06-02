library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity WasdDecoder is
    port (
        ps2_datain, ps2_clk : in std_logic; -- PS2 clk and data
        filter_clk: in std_logic;             -- filter clock
        wasd: out std_logic_vector(3 downto 0)
    );
end WasdDecoder;

architecture rtl of WasdDecoder is
    type state_type is (delay, start, d0, d1, d2, d3, d4, d5, d6, d7, parity, stop, finish);
    signal data, clk, clk1, clk2, odd: std_logic; -- 毛刺处理内部信号, odd为奇偶校验
    signal code : std_logic_vector(7 downto 0);
    signal state : state_type;

    type decoder_state_type is (break, start);
    signal decoder_state: decoder_state_type := start;
    signal l_wasd: std_logic_vector(3 downto 0) := (others=> '0');

begin
    clk1 <= ps2_clk when rising_edge(filter_clk);
    clk2 <= clk1 when rising_edge(filter_clk);
    clk <= (not clk1) and clk2;

    data <= ps2_datain when rising_edge(filter_clk);

    odd <= code(0) xor code(1) xor code(2) xor code(3)
        xor code(4) xor code(5) xor code(6) xor code(7);

    wasd <= l_wasd;

    process (filter_clk) begin
        if rising_edge(filter_clk) then
--            loe <= '0';
            case state is
                when delay =>
                    state <= start;
                when start =>
                    if clk = '1' then
                        if data = '0' then
                            state <= d0;
                        else
                            state <= delay;
                        end if;
                    end if;
                when d0 =>
                    if clk = '1' then
                        code(0) <= data;
                        state <= d1;
                    end if;
                when d1 =>
                    if clk = '1' then
                        code(1) <= data;
                        state <= d2;
                    end if;
                when d2 =>
                    if clk = '1' then
                        code(2) <= data;
                        state <= d3;
                    end if;
                when d3 =>
                    if clk = '1' then
                        code(3) <= data;
                        state <= d4;
                    end if;
                when d4 =>
                    if clk = '1' then
                        code(4) <= data;
                        state <= d5;
                    end if;
                when d5 =>
                    if clk = '1' then
                        code(5) <= data;
                        state <= d6;
                    end if;
                when d6 =>
                    if clk = '1' then
                        code(6) <= data;
                        state <= d7;
                    end if;
                when d7 =>
                    if clk = '1' then
                        code(7) <= data;
                        state <= parity;
                    end if;
                WHEN parity =>
                    IF clk = '1' then
                        if (data xor odd) = '1' then
                            state <= stop;
                        else
                            state <= delay;
                        end if;
                    END IF;
                WHEN stop =>
                    IF clk = '1' then
                        if data = '1' then
                            state <= finish;
                        else
                            state <= delay;
                        end if;
                    END IF;
                WHEN finish =>
                    state <= delay;

            -- XXX: HACK (WTF WHY????)
            case decoder_state is
                when start =>
                    case code is
                        when x"F0" =>
                            decoder_state <= break;
                        when x"1D" =>
                            l_wasd(3) <= '1';
                        when x"1C" =>
                            l_wasd(2) <= '1';
                        when x"1B" =>
                            l_wasd(1) <= '1';
                        when x"23" =>
                            l_wasd(0) <= '1';
                        when others =>
                            null;
                    end case;
                when break =>
                    case code is
                        when x"1D" =>
                            l_wasd(3) <= '0';
                            decoder_state <= start;
                        when x"1C" =>
                            l_wasd(2) <= '0';
                            decoder_state <= start;
                        when x"1B" =>
                            l_wasd(1) <= '0';
                            decoder_state <= start;
                        when x"23" =>
                            l_wasd(0) <= '0';
                            decoder_state <= start;
                        when others =>
                            null;
                    end case;
            end case;

--                    loe <= '1';
                when others =>
                    state <= delay;
            end case;
        end if;
    end process;
--
--    process (loe) begin
--        if (rising_edge(loe)) then
--            case decoder_state is
--                when start =>
--                    case code is
--                        when x"F0" =>
--                            decoder_state <= break;
--                        when x"1D" =>
--                            l_wasd(3) <= '1';
--                        when x"1C" =>
--                            l_wasd(2) <= '1';
--                        when x"1B" =>
--                            l_wasd(1) <= '1';
--                        when x"23" =>
--                            l_wasd(0) <= '1';
--                        when others =>
--                            null;
--                    end case;
--                when break =>
--                    case code is
--                        when x"1D" =>
--                            l_wasd(3) <= '0';
--                            decoder_state <= start;
--                        when x"1C" =>
--                            l_wasd(2) <= '0';
--                            decoder_state <= start;
--                        when x"1B" =>
--                            l_wasd(1) <= '0';
--                            decoder_state <= start;
--                        when x"23" =>
--                            l_wasd(0) <= '0';
--                            decoder_state <= start;
--                        when others =>
--                            null;
--                    end case;
--            end case;
--        end if;
--    end process;
--
end rtl;

