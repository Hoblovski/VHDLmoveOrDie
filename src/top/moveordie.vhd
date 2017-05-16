library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity MoveOrDie is
    port ( 
        -- ps2 data:
        ps2_datain, ps2_clk: in std_logic;
        -- vga data:
        vga_HSYNC, vga_VSYNC: out std_logic;
        vga_r, vga_g, vga_b: out std_logic_vector(2 downto 0);
        -- clocks:
        CLK_100MHz: in std_logic
        -- misc:
    );
end MoveOrDie;

architecture behave of MoveOrDie is

    component WASDDecoder is
        port (
            ps2_datain, ps2_clk,                -- PS2 data
            filter_clk: in std_logic;   -- filter_clk: 100 MHz
            wasd: out std_logic_vector(3 downto 0)  -- whether wasd is pressed
        );
    end component;

    component VGA640480 is
        port (
    -- TODO: now only a single black dot at x, y
            x, y: in std_logic_vector(9 downto 0) := (others => '0');
            CLK_100MHz: in std_logic;
            HSYNC, VSYNC: out std_logic;
            r, g, b: out std_logic_vector(2 downto 0)
        );
    end component;

    component MoveController is
        port (
            CLK: in std_logic;
            wasdPressed: in std_logic_vector(3 downto 0);
            X: out std_logic_vector(9 downto 0);
            Y: out std_logic_vector(9 downto 0)
        );
    end component;

    component ClkDivider is
        generic (
            n: integer := 1 -- clkin: f0 -> clkout: f0 / (2^n)
        );
        port (
            clkin: in std_logic;
            clkout: out std_logic
        );
    end component;

    signal swp_x, swp_y: std_logic_vector(9 downto 0);
    signal swp_CLK_128MHz: std_logic;   -- not really 128 Hz :)
    signal swp_wasdPressed: std_logic_vector(3 downto 0);

begin
    u0: ClkDivider generic map (
        n=> 18)
    port map (
        clkin=> CLK_100MHz,
        clkout=> swp_CLK_128MHz);

    u1: WASDDecoder port map (
        ps2_datain=> ps2_datain,
        ps2_clk=> ps2_clk,
        filter_clk=> CLK_100MHz,
        wasd=> swp_wasdPressed);

    u2: MoveController port map (
        CLK=> swp_CLK_128MHz,
        wasdPressed=> swp_wasdPressed,
        X=> swp_x,
        Y=> swp_y);

    u3: VGA640480 port map (
            x=> swp_x,
            y=> swp_y,
            CLK_100MHz=> CLK_100MHz,
            HSYNC=>vga_HSYNC,
            VSYNC=>vga_VSYNC,
            r=> vga_r,
            g=> vga_g,
            b=> vga_b);
end behave;

