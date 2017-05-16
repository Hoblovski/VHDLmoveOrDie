library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity top is
    port (
        datain, clkin, fclk, rst_in: in std_logic;
        seg_0, seg_1, seg_2: out std_logic_vector(6 downto 0);
        wasd: out std_logic_vector(3 downto 0)
    );
end top;

architecture behave of top is

    component Keyboard is
        port (
            datain, clkin : in std_logic;
            fclk, rst : in std_logic;
            scancode : out std_logic_vector(7 downto 0);  -- scan code signal output
            oe: out std_logic
        );
    end component;

    component displayDecoder is
        port (
            code: in std_logic_vector(3 downto 0);
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;

    component Counter is
        port (
            datain: in std_logic;
            dataout: out std_logic_vector(3 downto 0)
        );
    end component;

    component KeyboardDecoder is
        port (
            ie: in std_logic;                       -- input enable
            code: in std_logic_vector(7 downto 0);
            wasdPressed: out std_logic_vector(3 downto 0)
        );
    end component;

    signal scancode: std_logic_vector(7 downto 0);
    signal sc0, sc1, sc2, sc3: std_logic_vector(7 downto 0) := (others => '0'); -- l to r 4 pos
    signal rst : std_logic;
    signal clk_f: std_logic;
    signal toe: std_logic;
    signal lcnt: std_logic_vector(3 downto 0);

begin
    rst<=not rst_in;

    u0: Keyboard port map(
        datain, clkin, fclk, rst, scancode, toe);
    u1: displayDecoder port map(
        scancode(3 downto 0), seg_0);
    u2: displayDecoder port map(
        scancode(7 downto 4), seg_1);
    u3: Counter port map(
        toe, lcnt);
    u4: displayDecoder port map(
        lcnt, seg_2);
    u5: KeyboardDecoder port map(
        ie=>toe, code=> scancode, wasdPressed=> wasd);

end behave;

