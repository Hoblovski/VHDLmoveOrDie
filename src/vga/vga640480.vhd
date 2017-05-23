library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

--  The screen:
--     +------------> x / 640
--     |
--     |
--     |
--     |
--     |
--     |
--     V  y / 480

entity VGA640480 is
    port (
-- TODO: now only a single black dot at x, y
        x, y: in std_logic_vector(6 downto 0) := (others => '0');
        CLK_100MHz: in std_logic;
        HSYNC, VSYNC: out std_logic;
        r, g, b: out std_logic_vector(2 downto 0)
    );
end vga640480;


architecture behavior of VGA640480 is

    component MapGraphic is
        port (
            x: in std_logic_vector(6 downto 0);
            y: in std_logic_vector(6 downto 0);
            gridCode: out std_logic_vector(3 downto 0)
        );
    end component;

    signal l_r, l_g, l_b : std_logic_vector(2 downto 0);
    signal l_HSYNC, l_VSYNC : std_logic;
    signal l_vgaX : std_logic_vector(9 downto 0); --X坐标
    signal l_vgaY : std_logic_vector(9 downto 0); --Y坐标
    signal l_CLK_50MHz, CLK_25MHz: std_logic := '0';
    signal l_gridCode: std_logic_vector(3 downto 0);

begin

    process (CLK_100MHz) begin
        if rising_edge(CLK_100MHz) then
            l_CLK_50MHz <= not l_CLK_50MHz;
        end if;
    end process;

    process (l_CLK_50MHz) begin
        if rising_edge(l_CLK_50MHz) then
            CLK_25MHz <= not CLK_25MHz;
        end if;
    end process;

    -- Generate l_vgaX
    -- l_vgaX: (actual range 0..799; effective range 0..640)
    process (CLK_25MHz)
    begin
        if rising_edge(CLK_25MHz) then
            if l_vgaX = 799 then
                l_vgaX <= (others=>'0');
            else
                l_vgaX <= l_vgaX + 1;
            end if;
        end if;
    end process;

    -- Generate l_vgaY
    -- l_vgaY: (actual range 0..525; effective range 0..640)
    process (CLK_25MHz) --场区间行数（含消隐区）
    begin
        if rising_edge(CLK_25MHz) then
            if l_vgaX=799 then
                if l_vgaY=524 then
                    l_vgaY <= (others=>'0');
                else
                    l_vgaY <= l_vgaY + 1;
                end if;
            end if;
        end if;
    end process;

    -- Generate HSYNC
    process (CLK_25MHz)
    begin
        if rising_edge(CLK_25MHz) then
            if l_vgaX>=656 and l_vgaX<752 then
                l_HSYNC <= '0';
            else
                l_HSYNC <= '1';
            end if;
        end if;
    end process;

    -- Generate VSYNC
    process (CLK_25MHz)
    begin
        if rising_edge(CLK_25MHz) then
            if l_vgaY>=490 and l_vgaY<492 then
                l_VSYNC <= '0';
            else
                l_VSYNC <= '1';
            end if;
        end if;
    end process;

    u0: MapGraphic port map (
        x=> l_vgaX(9 downto 3),
        y=> l_vgaY(9 downto 3),
        gridCode=> l_gridCode);

    -- Generate BGR according to l_vgaX, l_vgaY
    process (CLK_25MHz, l_vgaX, l_vgaY)
    begin
        if rising_edge(CLK_25MHz) then
            if (l_vgaX(9 downto 3) = x and l_vgaY(9 downto 3) = y) then
                l_r <= (others => '1');
                l_g <= (others => '0');
                l_b <= (others => '0');
            else
                if l_gridCode = "0000" then
                    l_r <= (others => '1');
                    l_g <= (others => '1');
                    l_b <= (others => '1');
                elsif l_gridCode = "0001" then
                    l_r <= (others => '0');
                    l_g <= (others => '0');
                    l_b <= (others => '0');
                else
                    l_r <= (others => '0');
                    l_g <= (others => '1');
                    l_b <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Mapping HSYNC
    process (CLK_25MHz)
    begin
        if rising_edge(CLK_25MHz) then
            HSYNC <= l_HSYNC;
        end if;
    end process;

    -- Mapping VSYNC
    process (CLK_25MHz)
    begin
        if rising_edge(CLK_25MHz) then
            VSYNC <= l_VSYNC;
        end if;
    end process;

    -- Mapping BGR
    process (l_HSYNC, l_VSYNC, l_r, l_g, l_b, l_vgaX, l_vgaY) --色彩输出
    begin
        if (l_vgaX < 640 and l_vgaY < 480) then
            r <= l_r;
            g <= l_g;
            b <= l_b;
        else
            r <= (others => '0');
            g <= (others => '0');
            b <= (others => '0');
        end if;
    end process;

end behavior;
