library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity connector is
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
end connector;

architecture sess of connector is

component receiver is
	generic(
		maxLenth: integer := 3
	);
	port(
		clk: in std_logic;
		input: in std_logic;
		data: out std_logic_vector(maxLenth-1 downto 0);
		Eout: out std_logic
	);
end component;
	
component sender is
	generic(
		maxLenth: integer := 3
	);
	port(
		clk: in std_logic;
		ESend: in std_logic;
		data: in std_logic_vector(maxLenth-1 downto 0);
		output: out std_logic
	);
end component;

begin
	u0: receiver generic map(
		maxLenth => maxLenth
	)
	port map(
		clk=>clk,
		input=>receive,
		data=>dataReceive,
		Eout=>EReceive
	);
	
	u1: sender generic map(
		maxLenth => maxLenth
	)
	port map(
		clk=>clk,
		ESend=>ESend,
		data=>dataToSend,
		output=>send
	);
end sess;