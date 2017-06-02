library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--    +-------------------> vga_x / 80
--    |
--    |
--    |
--    |
--    |
--    V vga_y / 60

-- Working freq: 25 MHz
entity MapGraphic is
    generic (
        ps: integer := 3 -- player size; FIXED DON'T TOUCH
    );
    port (
        rom_clk: in std_logic;
        vga_x: in std_logic_vector(9 downto 0);
        vga_y: in std_logic_vector(9 downto 0);

        p1X, p1Y: in std_logic_vector(6 downto 0) := (others => '0');
        p1Hp: in std_logic_vector(7 downto 0) := (others => '1');

        p2X, p2Y: in std_logic_vector(6 downto 0) := (others => '0');
        p2Hp: in std_logic_vector(7 downto 0) := (others => '1');

        p3X, p3Y: in std_logic_vector(6 downto 0) := (others => '0');
        p3Hp: in std_logic_vector(7 downto 0) := (others => '1');

        p4X, p4Y: in std_logic_vector(6 downto 0) := (others => '0');
        p4Hp: in std_logic_vector(7 downto 0) := (others => '1');

        R: out std_logic_vector(2 downto 0);
        G: out std_logic_vector(2 downto 0);
        B: out std_logic_vector(2 downto 0)
    );
end MapGraphic;

architecture RomBehave of MapGraphic is
    COMPONENT maprom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);    -- 60x  + vga_y
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT blockrom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);  -- GC & vga_x & vga_y
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT playerrom IS
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            clock		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
        );
    END COMPONENT;

    signal add0: std_logic_vector(12 downto 0);
    signal gridCode: std_logic_vector(5 downto 0);
    signal bgRGB: std_logic_vector(8 downto 0);

    signal p1_x_offset: std_logic_vector(6 downto 0);
    signal p1_y_offset: std_logic_vector(6 downto 0);
    signal p1_offset_code: std_logic_vector(3 downto 0);
    signal p1_RGB: std_logic_vector(8 downto 0);

    signal p2_x_offset: std_logic_vector(6 downto 0);
    signal p2_y_offset: std_logic_vector(6 downto 0);
    signal p2_offset_code: std_logic_vector(3 downto 0);
    signal p2_RGB: std_logic_vector(8 downto 0);

    signal p3_x_offset: std_logic_vector(6 downto 0);
    signal p3_y_offset: std_logic_vector(6 downto 0);
    signal p3_offset_code: std_logic_vector(3 downto 0);
    signal p3_RGB: std_logic_vector(8 downto 0);

    signal p4_x_offset: std_logic_vector(6 downto 0);
    signal p4_y_offset: std_logic_vector(6 downto 0);
    signal p4_offset_code: std_logic_vector(3 downto 0);
    signal p4_RGB: std_logic_vector(8 downto 0);

begin
    add0 <= (("0" & vga_x(9 downto 3) & "00000" )+
            (vga_x(9 downto 3) & "0000")) +
            ((vga_x(9 downto 3) & "000" )+
            (vga_x(9 downto 3) & "00")) +
            vga_y(9 downto 3); -- 60 vga_x(9 downto 3) + vga_y(9 downto 3)

    u0: maprom port map (
        address=> add0,
        clock=>rom_clk,
        q=> gridCode);

    u1: blockrom port map (
        address=> gridCode & vga_x(2 downto 0) & vga_y(2 downto 0),
        clock=> rom_clk,
        q=> bgRGB);

    -- p1 related computation
    p1_x_offset <= vga_x(9 downto 3) - p1X;
    p1_y_offset <= vga_y(9 downto 3) - p1Y;
    -- last four digits of 3 * p1_x_offset + p1_y_offset
    p1_offset_code <= (p1_x_offset(3 downto 0) + (p1_x_offset(2 downto 0) & "0")) + p1_y_offset(3 downto 0); -- HACK
    U_PLAYERROM_P1: 
    playerrom port map (
        address=> "00" & p1_offset_code & vga_x(2 downto 0) & vga_y(2 downto 0),
        clock=>rom_clk,
        q=> p1_RGB);

    -- p2 related computation
    p2_x_offset <= vga_x(9 downto 3) - p2X;
    p2_y_offset <= vga_y(9 downto 3) - p2Y;
    -- last four digits of 3 * p2_x_offset + p2_y_offset
    p2_offset_code <= (p2_x_offset(3 downto 0) + (p2_x_offset(2 downto 0) & "0")) + p2_y_offset(3 downto 0); -- HACK
    U_PLAYERROM_P2: 
    playerrom port map (
        address=> "01" & p2_offset_code & vga_x(2 downto 0) & vga_y(2 downto 0),
        clock=>rom_clk,
        q=> p2_RGB);

    -- p3 related computation
    p3_x_offset <= vga_x(9 downto 3) - p3X;
    p3_y_offset <= vga_y(9 downto 3) - p3Y;
    -- last four digits of 3 * p3_x_offset + p3_y_offset
    p3_offset_code <= (p3_x_offset(3 downto 0) + (p3_x_offset(2 downto 0) & "0")) + p3_y_offset(3 downto 0); -- HACK
    U_PLAYERROM_P3: 
    playerrom port map (
        address=> "10" & p3_offset_code & vga_x(2 downto 0) & vga_y(2 downto 0),
        clock=>rom_clk,
        q=> p3_RGB);

    -- p4 related computation
    p4_x_offset <= vga_x(9 downto 3) - p4X;
    p4_y_offset <= vga_y(9 downto 3) - p4Y;
    -- last four digits of 3 * p4_x_offset + p4_y_offset
    p4_offset_code <= (p4_x_offset(3 downto 0) + (p4_x_offset(2 downto 0) & "0")) + p4_y_offset(3 downto 0); -- HACK
    U_PLAYERROM_P4: 
    playerrom port map (
        address=> "11" & p4_offset_code & vga_x(2 downto 0) & vga_y(2 downto 0),
        clock=>rom_clk,
        q=> p4_RGB);

    process (vga_x, vga_y, bgRGB,
            p1_x_offset, p1_y_offset, p1Hp, p1_RGB,
            p2_x_offset, p2_y_offset, p2Hp, p2_RGB,
            p3_x_offset, p3_y_offset, p3Hp, p3_RGB, 
            p4_x_offset, p4_y_offset, p4Hp, p4_RGB) 

        variable pR, pG, pB: std_logic_vector(5 downto 0) := (others=>'0');
        variable bR, bG, bB: std_logic_vector(5 downto 0) := (others=>'0');
        variable player_x: std_logic_vector(4 downto 0) := (others=>'0');
        variable player_y: std_logic_vector(4 downto 0) := (others=>'0');
        constant three: std_logic_vector(1 downto 0) := "11";
        constant thirty_two: std_logic_vector(5 downto 0) := "100000";

    begin

        -- player 1
        if (p1_x_offset < ps and p1_y_offset < ps) then
            player_x := p1_x_offset(1 downto 0) & vga_x(2 downto 0);
            player_y := p1_y_offset(1 downto 0) & vga_y(2 downto 0);
            if (player_y = "00000") then
                if (player_x * thirty_two <= p1Hp * three) then
                    R <= (others=> '1');
                    G <= (others=> '0');
                    B <= (others=> '0');
                else
                    R <= (others=> '1');
                    G <= (others=> '1');
                    B <= (others=> '1');
                end if;
            else
                R <= p1_RGB(8 downto 6);
                G <= p1_RGB(5 downto 3);
                B <= p1_RGB(2 downto 0);
            end if;

        -- player 2
        elsif (p2_x_offset < ps and p2_y_offset < ps) then
            player_x := p2_x_offset(1 downto 0) & vga_x(2 downto 0);
            player_y := p2_y_offset(1 downto 0) & vga_y(2 downto 0);
            if (player_y = "00000") then
                if (player_x * thirty_two <= p2Hp * three) then
                    R <= (others=> '1');
                    G <= (others=> '0');
                    B <= (others=> '0');
                else
                    R <= (others=> '1');
                    G <= (others=> '1');
                    B <= (others=> '1');
                end if;
            else
                R <= p2_RGB(8 downto 6);
                G <= p2_RGB(5 downto 3);
                B <= p2_RGB(2 downto 0);
            end if;

        -- player 3
        elsif (p3_x_offset < ps and p3_y_offset < ps) then
            player_x := p3_x_offset(1 downto 0) & vga_x(2 downto 0);
            player_y := p3_y_offset(1 downto 0) & vga_y(2 downto 0);
            if (player_y = "00000") then
                if (player_x * thirty_two <= p3Hp * three) then
                    R <= (others=> '1');
                    G <= (others=> '0');
                    B <= (others=> '0');
                else
                    R <= (others=> '1');
                    G <= (others=> '1');
                    B <= (others=> '1');
                end if;
            else
                R <= p3_RGB(8 downto 6);
                G <= p3_RGB(5 downto 3);
                B <= p3_RGB(2 downto 0);
            end if;

        -- player 4
        elsif (p4_x_offset < ps and p4_y_offset < ps) then
            player_x := p4_x_offset(1 downto 0) & vga_x(2 downto 0);
            player_y := p4_y_offset(1 downto 0) & vga_y(2 downto 0);
            if (player_y = "00000") then
                if (player_x * thirty_two <= p4Hp * three) then
                    R <= (others=> '1');
                    G <= (others=> '0');
                    B <= (others=> '0');
                else
                    R <= (others=> '1');
                    G <= (others=> '1');
                    B <= (others=> '1');
                end if;
            else
                R <= p4_RGB(8 downto 6);
                G <= p4_RGB(5 downto 3);
                B <= p4_RGB(2 downto 0);
            end if;

        -- background only
        else
            R <= bgRGB(8 downto 6);
            G <= bgRGB(5 downto 3);
            B <= bgRGB(2 downto 0);
        end if;
    end process;

end;

