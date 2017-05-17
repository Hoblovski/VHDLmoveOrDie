library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity ClientLogic is
	port(
		clk: in std_logic;
		keypush: in std_logic_vector(3 downto 0); -- WASD
		rst: in std_logic;
		begin_x: in std_logic_vector(9 downto 0);
		begin_y: in std_logic_vector(9 downto 0);
		
		mp:in std_logic_vector(0 downto 0) ;
		-----------------------------------------
		position: out std_logic_vector(18 downto 0);
		pos_x: out std_logic_vector(9 downto 0);
		pos_y: out std_logic_vector(9 downto 0);
		life: out std_logic_vector(6 downto 0);
		alive: out std_logic
	);
end ClientLogic;

architecture Logic of ClientLogic is
	signal x,y,h: integer;
	type state_type is (stand, move, jump, fall);
	signal jump_remain: integer := 0;
	signal state: state_type := stand;
	signal xx,yy: integer;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			--------------------reset game------------------------------
			if rst = '1' then
				x <= to_integer(unsigned(begin_x));
				y <= to_integer(unsigned(begin_y));
				h <= 200; --maxlife
				state <= stand;
			end if;
			---------------------check state----------------------------
			if keypush(3) = '1' and (state = stand or state = move) then
				state <= jump;
				jump_remain <= 200; -- max height
			end if;
			if state = jump and jump_remain = 0 then
				state <= fall;
			end if;
			if state = fall then --and position_is_block(x-1,y) then --check the position under player. TODO
				xx <= x-1;
				yy <= y;
				position <= std_logic_vector(to_unsigned(xx * 640 + yy, 19));
				if mp(0) = '1' then
					state <= stand;
				end if;
			end if;
			if (state = stand or state = move) then
				xx <= x-1;
				yy <= y;
				position <= std_logic_vector(to_unsigned(xx * 640 + yy, 19));
				if mp(0) = '0' then
					state <= fall;
				elsif keypush(2) = '1' or keypush(0) = '1'then
					state <= move;
				else 
					state <= stand;
				end if;
			end if;
			----------------------calc position--------------------------
			if state = jump then
				xx <= x+1;
				yy <= y;
				position <= std_logic_vector(to_unsigned(xx * 640 + yy, 19));
				if mp(0) = '1' then
					jump_remain <= 0;
				else
					jump_remain <= jump_remain - 1;
					x <= x + 1;
				end if;
			end if;
			if state = fall then
				x <= x - 1; -- already checked when checking state; do not need check again;
			end if;
			if keypush(2) = '1' then
				xx <= x;
				yy <= y-1;
				position <= std_logic_vector(to_unsigned(xx * 640 + yy, 19));
				if mp(0) = '0' then
					y <= y - 1;
				end if;
			elsif keypush(0) = '1' then
				xx <= x;
				yy <= y+1;
				position <= std_logic_vector(to_unsigned(xx * 640 + yy, 19));
				if mp(0) = '0' then
					y <= y + 1;
				end if;
			end if;
			----------------------calc life------------------------------
			if state = move then
				if h > 0 and h < 200 then
					h <= h + 1;
				end if;
			elsif h > 0 then
				h <= h - 1;
			end if;
			
			----------------------give output signals--------------------
			if h = 0 then
				alive <= '0';
			else
				alive <= '1';
			end if;
			pos_x <= std_logic_vector(to_unsigned(x,10));
			pos_y <= std_logic_vector(to_unsigned(y,10));
			life <= std_logic_vector(to_unsigned(h,7));
		end if;
	end process;
end Logic;