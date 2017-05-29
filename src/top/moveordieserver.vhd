library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity MoveOrDieServer is
	port(
		receive_1: in std_logic;
		clk100M: in std_logic;
		clk25M: in std_logic;
        -- vga data:
        vga_HSYNC, vga_VSYNC: out std_logic;
        vga_r, vga_g, vga_b: out std_logic_vector(2 downto 0);
        -- view
        EReceive: out std_logic;
        Receiveview: out std_logic;
        dataview: out std_logic_vector(6 downto 0)
	);
end MoveOrDieServer;

architecture sss of MoveOrDieServer is

component connector is
	generic(
		maxLenth: integer := 3
	);
	port(
		receive: in std_logic;
		clk: in std_logic;
		dataToSend: in std_logic_vector(maxLenth-1 downto 0); -- warning: begin with lower bits!!!
		ESend: in std_logic;
		send: out std_logic;
		dataReceive:out std_logic_vector(maxLenth-1 downto 0);
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

component VGA640480 is
    port (
        x, y: in std_logic_vector(6 downto 0) := (others => '0');
        hp: in std_logic_vector(7 downto 0) := (others => '1');
        CLK_100MHz: in std_logic;
        HSYNC, VSYNC: out std_logic;
        r, g, b: out std_logic_vector(2 downto 0)
    );
end component;


---------------------------------------------------------------------------

signal data_1: std_logic_vector(22 downto 0) := "00000000000000000000000";
--data_x(22-16),data_y(15-9),life(8-1),alive(0)

signal dataToSend: std_logic_vector(22 downto 0);
signal ESend, send: std_logic;
signal swp_CLK_div6, swp_CLK_div12: std_logic;
begin
	Receiveview <= receive_1;
	
    u00: ClkDivider generic map (
        n=> 6)
    port map (
        clkin=> CLK100M,
        clkout=> swp_CLK_div6);
        
    u000: ClkDivider generic map (
        n=> 12)
    port map (
        clkin=> CLK100M,
        clkout=> swp_CLK_div12);


	net: connector generic map(
		maxLenth => 23
	)
	port map(
		receive => receive_1,
		clk => swp_CLK_div6,
		dataToSend => dataToSend,
		ESend => ESend,
		send => send,
		dataReceive => data_1,
		EReceive => EReceive
	);
	
	visual: VGA640480 port map(
		x => data_1(22 downto 16),
		y => data_1(15 downto 9),
		hp => data_1(8 downto 1),
		CLK_100MHz => clk100M,
		HSYNC => vga_HSYNC,
		VSYNC => vga_VSYNC,
		r => vga_r,
		g => vga_g,
		b => vga_b
	);
	dataview <= data_1(22 downto 16);
end sss;