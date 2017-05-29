library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity WASDDecoder is
    port (
        ps2_datain,
        ps2_clk,                -- PS2 data
        filter_clk: in std_logic;   -- filter_clk: 100 MHz
        wasd: out std_logic_vector(3 downto 0)  -- whether wasd is pressed
    );
end WASDDecoder;

architecture behave of WASDDecoder is

    component Keyboard is
        port (
            datain, clkin : in std_logic; -- PS2 clk and data
            fclk: in std_logic;  -- filter clock
            scancode : out std_logic_vector(7 downto 0); -- scan code signal output
            oe : out std_logic -- output enable
        );
    end component;

    component KeyboardDecoder is
        port (
            fclk: in std_logic;                      -- filter fclk
            ie: in std_logic;                       -- input enable
            code: in std_logic_vector(7 downto 0);
            wasdPressed: out std_logic_vector(3 downto 0)
        );
    end component;

    signal scancode: std_logic_vector(7 downto 0);
    signal oe_swp: std_logic;

begin

    u0: Keyboard port map(
        datain=> ps2_datain,
        clkin=> ps2_clk,
        fclk=> filter_clk,
        scancode=> scancode,
        oe=> oe_swp);

    u1: KeyboardDecoder port map(
        fclk=> filter_clk,
        ie=> oe_swp,
        code=> scancode,
        wasdPressed=> wasd);

end behave;

