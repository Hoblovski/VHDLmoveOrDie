library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.std_logic_arith.ALL;

entity MapLogic is
    generic (
        ps: integer range 3 to 3 := 3; -- player size, > 0; FIXED DON'T TOUCH
        pc: integer range 1 to 4 := 1 -- player code (1 to 4)
    );  -- actual size: ps
    port (
        clk_rom: in std_logic;
        p1X, p1Y: in std_logic_vector(6 downto 0) := (others => '0');
        p2X, p2Y: in std_logic_vector(6 downto 0) := (others => '0');
        p3X, p3Y: in std_logic_vector(6 downto 0) := (others => '0');
        p4X, p4Y: in std_logic_vector(6 downto 0) := (others => '0');
        blk: out std_logic_vector(7 downto 0)
    );
end MapLogic;


architecture RomBehave of MapLogic is

    COMPONENT maplogicrom IS
        PORT
        (
            address     : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
            clock       : IN STD_LOGIC ;
            q       : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
        );
    END COMPONENT;

    signal add0: std_logic_vector(12 downto 0);
    signal ub, rb, db, lb: std_logic_vector(ps - 1 downto 0);
    -- o: offset
    signal o1x, o1y: std_logic_vector(6 downto 0) := (others=> '0');
    signal o2x, o2y: std_logic_vector(6 downto 0) := (others=> '0');
    signal o3x, o3y: std_logic_vector(6 downto 0) := (others=> '0');

    signal map_blk: std_logic_vector(7 downto 0) := (others=> '0');
    signal ply_blk: std_logic_vector(7 downto 0) := (others=> '0');
    
    signal x, y: std_logic_vector(6 downto 0) := (others=> '0');

begin
    add0 <=
            (("0" & p1X & "00000" )+ 
            (p1X & "0000")) + 
            ((p1X & "000" )+
            (p1X & "00")) + p1Y when pc = 1
        else
            (("0" & p2X & "00000" )+ 
            (p2X & "0000")) + 
            ((p2X & "000" )+
            (p2X & "00")) + p2Y when pc = 2 
        else
            (("0" & p3X & "00000" )+ 
            (p3X & "0000")) + 
            ((p3X & "000" )+
            (p3X & "00")) + p3Y when pc = 3
        else
            (("0" & p4X & "00000" )+ 
            (p4X & "0000")) + 
            ((p4X & "000" )+
            (p4X & "00")) + p4Y;

    blk <= map_blk or ply_blk;

    o1x <= (p1X - p2X) when pc = 1 else
            (p2X - p1X) when pc = 2 else
            (p3X - p1X) when pc = 3 else
            (p4X - p1X);
    o1y <= (p1Y - p2Y) when pc = 1 else
            (p2Y - p1Y) when pc = 2 else
            (p3Y - p1Y) when pc = 3 else
            (p4Y - p1Y);
    o2x <= (p1X - p3X) when pc = 1 else
            (p2X - p3X) when pc = 2 else
            (p3X - p2X) when pc = 3 else
            (p4X - p2X);
    o2y <= (p1Y - p3Y) when pc = 1 else
            (p2Y - p3Y) when pc = 2 else
            (p3Y - p2Y) when pc = 3 else
            (p4Y - p2Y);
    o3x <= (p1X - p4X) when pc = 1 else
            (p2X - p4X) when pc = 2 else
            (p3X - p4X) when pc = 3 else
            (p4X - p3X);
    o3y <= (p1Y - p4Y) when pc = 1 else
            (p2Y - p4Y) when pc = 2 else
            (p3Y - p4Y) when pc = 3 else
            (p4Y - p3Y);

    process (o1x, o1y, o2x, o2y, o3x, o3y) begin
        if (((o2y >= 125) and ((o2x >= 126) or (o2x <= 2))) or
                ((o3y >= 125) and ((o3x >= 126) or (o3x <= 2))) or
                ((o1y >= 125) and ((o1x >= 126) or (o1x <= 2)))) then
            ply_blk(5) <= '1';
        else
            ply_blk(5) <= '0';
        end if;
        if (((o2x >= 125) and ((o2y <= 2) or (o2y >= 126))) or
                ((o3x >= 125) and ((o3y <= 2) or (o3y >= 126))) or
                ((o1x >= 125) and ((o1y <= 2) or (o1y >= 126)))) then
            ply_blk(3) <= '1';
        else
            ply_blk(3) <= '0';
        end if;
        if (((o2y < 4) and ((o2x < 3) or (o2x > 125))) or
                ((o3y < 4) and ((o3x < 3) or (o3x > 125))) or
                ((o1y < 4) and ((o1x < 3) or (o1x > 125)))) then
            ply_blk(1) <= '1';
        else
            ply_blk(1) <= '0';
        end if;
        if (((o2x <= 3) and ((o2y <= 2) or (o2y >= 126))) or
                ((o3x <= 3) and ((o3y <= 2) or (o3y >= 126))) or
                ((o1x <= 3) and ((o1y <= 2) or (o1y >= 126)))) then
            ply_blk(7) <= '1';
        else
            ply_blk(7) <= '0';
        end if;
    end process;

    -- 0
    U_LU_BLOCK: maplogicrom port map (
        address=> add0 - 60 - 1,
        clock=> clk_rom,
        q=> map_blk(0 downto 0));

    -- 2
    U_RU_BLOCK: maplogicrom port map (
        address=> add0 - 1 + 60 * ps,
        clock=> clk_rom,
        q=> map_blk(2 downto 2));

    -- 4
    U_RD_BLOCK: maplogicrom port map (
        address=> add0 + 60 * ps + 1 * ps,
        clock=> clk_rom,
        q=> map_blk(4 downto 4));

    -- 6
    U_LD_BLOCK: maplogicrom port map (
        address=> add0 - 60 + 1 * ps,
        clock=> clk_rom,
        q=> map_blk(6 downto 6));

    -- 1
    GEN_UP_BLOCK:
    for I in 0 to ps - 1 generate
        U_UP_BLOCK_I:
        maplogicrom port map (
            address=> add0 - 1 + 60 * I,
            clock=>clk_rom,
            q=> ub(I downto I));
    end generate GEN_UP_BLOCK;

    process (ub)
        variable tmp: std_logic;
    begin
        tmp := '0';
        for I in 0 to ps - 1 loop
            tmp := tmp or ub(I);
        end loop;
        map_blk(1) <= tmp;
    end process;

    -- 3
    GEN_RIGHT_BLOCK:
    for I in 0 to ps - 1 generate
        U_RIGHT_BLOCK_I:
        maplogicrom port map (
            address=> add0 + 60 * ps + 1 * I,
            clock=>clk_rom,
            q=> rb(I downto I));
    end generate GEN_RIGHT_BLOCK;

    process (rb)
        variable tmp: std_logic;
    begin
        tmp := '0';
        for I in 0 to ps - 1 loop
            tmp := tmp or rb(I);
        end loop;
        map_blk(3) <= tmp;
    end process;

    -- 5
    GEN_DOWN_BLOCK:
    for I in 0 to ps - 1 generate
        U_DOWN_BLOCK_I:
        maplogicrom port map (
            address=> add0 + 1 * ps + 60 * I,
            clock=>clk_rom,
            q=> db(I downto I));
    end generate GEN_DOWN_BLOCK;

    process (db)
        variable tmp: std_logic;
    begin
        tmp := '0';
        for I in 0 to ps - 1 loop
            tmp := tmp or db(I);
        end loop;
        map_blk(5) <= tmp;
    end process;

    -- 7
    GEN_LEFT_BLOCK:
    for I in 0 to ps - 1 generate
        U_LEFT_BLOCK_I:
        maplogicrom port map (
            address=> add0 - 60 + 1 * I,
            clock=>clk_rom,
            q=> lb(I downto I));
    end generate GEN_LEFT_BLOCK;

    process (lb)
        variable tmp: std_logic;
    begin
        tmp := '0';
        for I in 0 to ps - 1 loop
            tmp := tmp or lb(I);
        end loop;
        map_blk(7) <= tmp;
    end process;

end;
