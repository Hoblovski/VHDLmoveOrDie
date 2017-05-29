library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;


entity MapLogic is
	port (
        clk_rom: in std_logic;
		x: in std_logic_vector(6 downto 0);
		y: in std_logic_vector(6 downto 0);
        lblk, rblk, ublk, dblk: out std_logic_vector(0 downto 0)
	);
end MapLogic;


architecture RomBehave of MapLogic is

    COMPONENT maplogicrom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
        );
    END COMPONENT;

    signal add0: std_logic_vector(12 downto 0);

begin
    add0 <= ("0" & x & "00000" )+
            (x & "0000" )+
            (x & "000" )+
            (x & "00" )+
            y; 

    u0: maplogicrom port map (
        address=> add0 - 1,
        clock=> clk_rom,
        q=> ublk);

    u1: maplogicrom port map (
        address=> add0 + 1,
        clock=> clk_rom,
        q=> dblk);

    u2: maplogicrom port map (
        address=> add0 - 60,
        clock=> clk_rom,
        q=> lblk);

    u3: maplogicrom port map (
        address=> add0 + 60,
        clock=> clk_rom,
        q=> rblk);


--    U_LU_BLOCK: maplogicrom port map (
--        address=> add0 - 60 - 1,
--        clock=> clk_rom,
--        q=> blk(0 downto 0));
--
--    U_UP_BLOCK_1: maplogicrom port map (
--        address=> add0 - 1,
--        clock=>clk_rom,
--        q=> blk(1 downto 1));
--
--    U_RU_BLOCK: maplogicrom port map (
--        address=> add0 + 60 - 1,
--        clock=> clk_rom,
--        q=> blk(2 downto 2));
--
--    U_RIGHT_BLOCK_1: maplogicrom port map (
--        address=> add0 + 60,
--        clock=> clk_rom,
--        q=> blk(3 downto 3));
--
--    U_RD_BLOCK: maplogicrom port map (
--        address=> add0 + 60 + 1,
--        clock=> clk_rom,
--        q=> blk(4 downto 4));
--
--    U_DOWN_BLOCK_1: maplogicrom port map (
--        address=> add0 + 1,
--        clock=> clk_rom,
--        q=> blk(5 downto 5));
--
--    U_LD_BLOCK: maplogicrom port map (
--        address=> add0 - 60 + 1,
--        clock=> clk_rom,
--        q=> blk(6 downto 6));
--
--    U_LEFT_BLOCK_1: maplogicrom port map (
--        address=> add0 - 60,
--        clock=> clk_rom,
--        q=> blk(7 downto 7));
--
end;
