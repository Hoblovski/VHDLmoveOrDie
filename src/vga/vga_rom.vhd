library ieee;
use ieee.std_logic_1164.all;

entity vga_rom is
    port (
        CLK_100MHz, reset: in std_logic;
        hs, vs: out STD_LOGIC; 
        r, g, b: out STD_LOGIC_vector(2 downto 0);
        datain, dataclkin: in std_logic;
        seg_0, seg_1, seg_2: out std_logic_vector(6 downto 0);
        mvCtrlCLKIn: in std_logic
    );
end vga_rom;

architecture vga_rom of vga_rom is

    component vga640480 is
        port (
            X, Y: in STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
            reset: in STD_LOGIC;

            CLK_50MHz: out STD_LOGIC;
            CLK_100MHz: in STD_LOGIC;
            hs, vs: out STD_LOGIC;
            r, g, b: out STD_LOGIC_vector(2 downto 0)
        );
    end component;

    component digital_rom is
        PORT
        (
            address: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
            clock: IN STD_LOGIC;
            q: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    end component;

    component MoveControl is
        port (
            CLK: in std_logic;
            wasdPressed: in std_logic_vector(3 downto 0);
            X: out std_logic_vector(9 downto 0);
            Y: out std_logic_vector(9 downto 0)
        );
    end component;

    component top is
        port (
            datain, clkin, fclk, rst_in: in std_logic;
            seg_0, seg_1, seg_2: out std_logic_vector(6 downto 0);
            wasd: out std_logic_vector(3 downto 0)
        );
    end component;

    signal address_swp: std_logic_vector(17 downto 0);
    signal CLK_50MHz_swp: std_logic;
    signal q_swp: std_logic_vector(2 downto 0);
    signal wasd_swp: std_logic_vector(3 downto 0);
    signal X_swp: std_logic_vector(9 downto 0);
    signal Y_swp: std_logic_vector(9 downto 0);

begin
    u2: top port map(
        datain=> datain,
        clkin=> dataclkin,
        fclk=> CLK_100MHz,
        rst_in=> '0',
        seg_0=> seg_0,
        seg_1=> seg_1,
        seg_2=> seg_2,
        wasd=> wasd_swp);
    u3: MoveControl port map(
        CLK=> mvCtrlCLKIn,
        wasdPressed=> wasd_swp,
        X=> X_swp,
        Y=> Y_swp);
    u4: vga640480 port map(
        X=> X_swp,
        Y=> Y_swp,
        CLK_100MHz=>CLK_100MHz, 
        CLK_50MHz=>CLK_50MHz_swp,
        reset=>reset, 
        hs=>hs, vs=>vs, 
        r=>r, g=>g, b=>b
    );
end vga_rom;
