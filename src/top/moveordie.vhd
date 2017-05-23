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
        CLK_100MHz: in std_logic;
        -- disp:
        disp0: out std_logic_vector(6 downto 0) := "0000000";
        disp1: out std_logic_vector(6 downto 0) := "0000000";
        disp2: out std_logic_vector(6 downto 0) := "0000000";
        disp3: out std_logic_vector(6 downto 0) := "0000000";
        disp4: out std_logic_vector(6 downto 0) := "0000000";
        disp5: out std_logic_vector(6 downto 0) := "0000000";
        disp6: out std_logic_vector(6 downto 0) := "0000000";
        disp7: out std_logic_vector(6 downto 0) := "0000000"
        -- misc:
    );
end MoveOrDie;

architecture behave of MoveOrDie is
-----------------------components----------------------------------------------
    component WASDDecoder is
        port (
            ps2_datain, ps2_clk,                -- PS2 data
            filter_clk: in std_logic;   -- filter_clk: 100 MHz
            wasd: out std_logic_vector(3 downto 0)  -- whether wasd is pressed
        );
    end component;

    component VGA640480 is
        port (
            x, y: in std_logic_vector(6 downto 0) := (others => '0');
            CLK_100MHz: in std_logic;
            HSYNC, VSYNC: out std_logic;
            r, g, b: out std_logic_vector(2 downto 0)
        );
    end component;

    component MoveController is
        port (
            CLK: in std_logic;
            wasdPressed: in std_logic_vector(3 downto 0);
            X: out std_logic_vector(6 downto 0);
            Y: out std_logic_vector(6 downto 0)
        );
    end component;

    component ClientLogic is
        generic (
            maxLife: std_logic_vector(7 downto 0) := x"64";
                -- 100
            initJumpRemain: std_logic_vector(6 downto 0) := "0000110"
                -- 6 (out of HEIGHT = 48). Specifies how high you can jump.
        );

        port(
            clk: in std_logic;
            rst: in std_logic;
            wasdPressed: in std_logic_vector(3 downto 0); -- WASD
            initX: in std_logic_vector(6 downto 0) := "0101000"; -- 40
            initY: in std_logic_vector(6 downto 0) := "0011110"; -- 30

            X: out std_logic_vector(6 downto 0);
            Y: out std_logic_vector(6 downto 0);
            stateCode: out std_logic_vector(3 downto 0)
            -- life: out std_logic_vector(6 downto 0);
            -- alive: out std_logic
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

    component DisplayDecoder is
        port (
            code: in std_logic_vector(3 downto 0);
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;
-----------------------components----------------------------------------------

    signal swp_x, swp_y: std_logic_vector(6 downto 0);
    signal swp_CLK_100Hz: std_logic;
    signal swp_wasdPressed: std_logic_vector(3 downto 0);

    signal swp_disp0: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp1: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp2: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp3: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp4: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp5: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp6: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp7: std_logic_vector(3 downto 0) := "0000";

begin
    u0: ClkDivider generic map (
        n=> 24)
    port map (
        clkin=> CLK_100MHz,
        clkout=> swp_CLK_100Hz);

    u1: WASDDecoder port map (
        ps2_datain=> ps2_datain,
        ps2_clk=> ps2_clk,
        filter_clk=> CLK_100MHz,
        wasd=> swp_wasdPressed);
    swp_disp7 <= swp_wasdPressed;

	u2: ClientLogic port map (
		clk=> swp_CLK_100Hz,
		rst=> '0',
		wasdPressed=> swp_wasdPressed,
		X => swp_x,
		Y => swp_y,
        stateCode=> swp_disp0
	);

--    swp_disp1 <= swp_x(3 downto 0);
--    swp_disp2 <= swp_y(3 downto 0);

--    u2: MoveController port map(
--        CLK=> swp_CLK_100Hz,
--        wasdPressed=> swp_wasdPressed,
--        X=> swp_x,
--        Y=> swp_y);

    u3: VGA640480 port map (
            x=> swp_x,
            y=> swp_y,
            CLK_100MHz=> CLK_100MHz,
            HSYNC=>vga_HSYNC,
            VSYNC=>vga_VSYNC,
            r=> vga_r,
            g=> vga_g,
            b=> vga_b);

    dispu0: DisplayDecoder port map (
            code=> swp_disp0,
            seg_out=> disp0);
    dispu1: DisplayDecoder port map (
            code=> swp_disp1,
            seg_out=> disp1);
    dispu2: DisplayDecoder port map (
            code=> swp_disp2,
            seg_out=> disp2);
    dispu3: DisplayDecoder port map (
            code=> swp_disp3,
            seg_out=> disp3);
    dispu4: DisplayDecoder port map (
            code=> swp_disp4,
            seg_out=> disp4);
    dispu5: DisplayDecoder port map (
            code=> swp_disp5,
            seg_out=> disp5);
    dispu6: DisplayDecoder port map (
            code=> swp_disp6,
            seg_out=> disp6);
    dispu7: DisplayDecoder port map (
            code=> swp_disp7,
            seg_out=> disp7);
end behave;

