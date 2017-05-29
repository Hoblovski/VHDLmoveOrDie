library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--    +-------------------> x / 80
--    |
--    |
--    |
--    |
--    |
--    V y / 60

entity MapGraphic is
	port (
        rom_clk: in std_logic;
		x: in std_logic_vector(9 downto 0);
		y: in std_logic_vector(9 downto 0);
        p1X: in std_logic_vector(6 downto 0);
        p1Y: in std_logic_vector(6 downto 0);
        p1Hp: in std_logic_vector(7 downto 0);
        R: out std_logic_vector(2 downto 0);
        G: out std_logic_vector(2 downto 0);
        B: out std_logic_vector(2 downto 0)
	);
end MapGraphic;

architecture RomBehave of MapGraphic is
    COMPONENT maprom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);    -- 60x  + y
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT blockrom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);  -- GC & x & y
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT playerrom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0); -- PC & X & y
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    END COMPONENT;

    signal add0: std_logic_vector(12 downto 0);
    signal gridCode: std_logic_vector(5 downto 0);
    signal RGB: std_logic_vector(8 downto 0);
    signal playerRGB: std_logic_vector(8 downto 0);
    signal playerCode: std_logic_vector(1 downto 0);

begin
    add0 <= ("0" & x(9 downto 3) & "00000" )+
            (x(9 downto 3) & "0000" )+
            (x(9 downto 3) & "000" )+
            (x(9 downto 3) & "00" )+
            y(9 downto 3); -- 60 x(9 downto 3) + y(9 downto 3)

    u0: maprom port map (
        address=> add0,
        clock=>rom_clk,
        q=> gridCode);

    u1: blockrom port map (
        address=> gridCode & x(2 downto 0) & y(2 downto 0),
        clock=> rom_clk,
        q=> RGB);
    
    u2: playerrom port map (
        address=> playerCode & x(2 downto 0) & y(2 downto 0),
        clock=>rom_clk,
        q=> playerRGB);

    process (RGB, x, y) begin
        if (x(9 downto 3) = p1X and y(9 downto 3) = p1Y) then
            playerCode <= "00";
            R <= p1Hp(7 downto 5);
            G <= playerRGB(5 downto 3);
            B <= playerRGB(2 downto 0);
        else
            R <= RGB(8 downto 6);
            G <= RGB(5 downto 3);
            B <= RGB(2 downto 0);
        end if;
    end process;

end;

