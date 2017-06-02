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
        -- net data:
        clkControl: in std_logic;
		send: out std_logic;
		receive: in std_logic;
		rst: in std_logic;
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
            p1X, p1Y: in std_logic_vector(6 downto 0);
            p1Hp: in std_logic_vector(7 downto 0);

            p2X, p2Y: in std_logic_vector(6 downto 0);
            p2Hp: in std_logic_vector(7 downto 0);

            p3X, p3Y: in std_logic_vector(6 downto 0);
            p3Hp: in std_logic_vector(7 downto 0);

            p4X, p4Y: in std_logic_vector(6 downto 0);
            p4Hp: in std_logic_vector(7 downto 0);

            CLK_100MHz: in std_logic;
            HSYNC, VSYNC: out std_logic;
            r, g, b: out std_logic_vector(2 downto 0)
        );
    end component;

    component ClientLogic is
        generic (
            initJumpRemain: std_logic_vector(6 downto 0) := "0000110";
            initHp: std_logic_vector(7 downto 0) := x"FF";
                -- 6 (out of HEIGHT = 60). Specifies how high you can jump.
            pc: integer range 1 to 4 := 1 -- player code
        );

        port(
            clk_rom: in std_logic;
            clk: in std_logic;
            rst: in std_logic;
            wasdPressed: in std_logic_vector(3 downto 0); -- WASD
            initX: in std_logic_vector(6 downto 0);
            initY: in std_logic_vector(6 downto 0);

            p1X, p1Y: inout std_logic_vector(6 downto 0) := (others => '0');
            p1Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
            p2X, p2Y: inout std_logic_vector(6 downto 0) := (others => '0');
            p2Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
            p3X, p3Y: inout std_logic_vector(6 downto 0) := (others => '0');
            p3Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
            p4X, p4Y: inout std_logic_vector(6 downto 0) := (others => '0');
            p4Hp: inout std_logic_vector(7 downto 0) := (others=> '0')

            -- deprecated
            -- stateCode: out std_logic_vector(3 downto 0) := "0000"
        );
    end component;

	component connector is
		generic(
			receiveLenth: integer := 3;
			sendLenth: integer := 3
		);
		port(
			receive: in std_logic;
			clk: in std_logic;
			dataToSend: in std_logic_vector(sendLenth-1 downto 0); -- warning: begin with lower bits!!!
			ESend: in std_logic;
			send: out std_logic;
			dataReceive:out std_logic_vector(receiveLenth-1 downto 0);
			EReceive:out std_logic
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

    signal CLK_100Hz, swp_CLK_div18: std_logic;
    signal swp_wasdPressed: std_logic_vector(3 downto 0);

    signal x1, y1: std_logic_vector(6 downto 0) := (others=> '0');
    signal hp1: std_logic_vector(7 downto 0) := (others=> '0');

    signal swp_disp0: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp1: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp2: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp3: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp4: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp5: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp6: std_logic_vector(3 downto 0) := "0000";
    signal swp_disp7: std_logic_vector(3 downto 0) := "0000";
	
	-- net work--
    signal swp_dataReceive: std_logic_vector(87 downto 0);
    signal swp_EReceive: std_logic;
    signal swp_data: std_logic_vector(21 downto 0);
	
begin
    u0: ClkDivider generic map (
        n=> 22)
    port map (
        clkin=> CLK_100MHz,
        clkout=> CLK_100Hz);

    u000: ClkDivider generic map (
        n=> 22)
    port map (
        clkin=> CLK_100MHz,
        clkout=> swp_CLK_div18);

    u1: WASDDecoder port map (
        ps2_datain=> ps2_datain,
        ps2_clk=> ps2_clk,
        filter_clk=> CLK_100MHz,
        wasd=> swp_wasdPressed);

    swp_disp7 <= swp_wasdPressed;

	net: connector generic map(
		receiveLenth => 88,
		sendLenth => 22
	)
	port map(
		receive => receive,
		clk => clkControl,
		dataToSend => x1 & y1 & hp1, -- x,y,life
		ESend => swp_CLK_div18,
		send => send,
		dataReceive => swp_dataReceive,
		EReceive => swp_EReceive
	);

	U_LOGIC_1: ClientLogic generic map (
        pc=> 3)
    port map (
        clk_rom=> CLK_100MHz,
		clk=> CLK_100Hz,
		rst=> rst,
		wasdPressed=> swp_wasdPressed,
        initX=> "0000011",
        initY=> "0000011",
        --p1X=> X1, p1Y=> Y1, p1Hp=> hp1,
        p1X=> swp_dataReceive(87 downto 81), p1Y=> swp_dataReceive(80 downto 74), p1Hp=> swp_dataReceive(73 downto 66),
        --p2X=> X1, P2Y=> Y1, p2Hp=> hp1,
        p2X=> swp_dataReceive(65 downto 59), p2Y=> swp_dataReceive(58 downto 52), p2Hp=> swp_dataReceive(51 downto 44),
        p3X=> X1, P3Y=> Y1, p3Hp=> hp1,
        --p3X=> swp_dataReceive(43 downto 37), p3Y=> swp_dataReceive(36 downto 30), p3Hp=> swp_dataReceive(29 downto 22),
        p4X=> swp_dataReceive(21 downto 15), p4Y=> swp_dataReceive(14 downto 8) , p4Hp=> swp_dataReceive(7 downto 0)
	);

    u3: VGA640480 port map (
            p1X=> swp_dataReceive(87 downto 81), p1Y=> swp_dataReceive(80 downto 74), p1Hp=> swp_dataReceive(73 downto 66),
            p2X=> swp_dataReceive(65 downto 59), p2Y=> swp_dataReceive(58 downto 52), p2Hp=> swp_dataReceive(51 downto 44), 
            p3X=> swp_dataReceive(43 downto 37), p3Y=> swp_dataReceive(36 downto 30), p3Hp=> swp_dataReceive(29 downto 22), 
            p4X=> swp_dataReceive(21 downto 15), p4Y=> swp_dataReceive(14 downto 8) , p4Hp=> swp_dataReceive(7 downto 0), 

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

