library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity receiver is
	generic(
		maxLenth: integer := 3
	);
	port(
		clk: in std_logic;
		input: in std_logic;
		data: out std_logic_vector(maxLenth-1 downto 0);
		Eout: out std_logic
	);
end receiver;

architecture ses of receiver is
	signal cnt: integer := 0;
	signal check: std_logic;
	signal datatemp: std_logic_vector(maxLenth-1 downto 0);
	signal Etemp: std_logic;
begin
	Eout <= Etemp;
	process(clk)
	begin
		if rising_edge(clk) then
			if cnt < 0 then
				cnt <= cnt + 1;
			elsif cnt = 0 then
				if input = '0' then
					cnt <= 1;
					Etemp <= '0';
					check <= '0';
				end if;
			elsif cnt <= maxLenth then
				datatemp(cnt-1) <= input;
				check <= check xor input;
				cnt <= cnt + 1;
			else
				if check = input then
					Etemp <= '1';
					cnt <= -1;
					data <= datatemp;
				end if;
			end if;
		end if;
	end process;
end ses;