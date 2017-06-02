library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClientLogic is
    generic (
        initJumpRemain: std_logic_vector(6 downto 0) := "0000110";
        initHp: std_logic_vector(7 downto 0) := x"FF";
            -- 6 (out of HEIGHT = 60). Specifies how high you can jump.
        pc: integer range 1 to 4 := 1 -- player code
    );

    port(
        clk_rom: in std_logic;
        clk: in std_logic;
        rst: in std_logic;
        wasdPressed: in std_logic_vector(3 downto 0); -- WASD
        initX, initY: in std_logic_vector(6 downto 0);

        p1X, p1Y: inout std_logic_vector(6 downto 0) := (others => '0');
        p1Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
        p2X, p2Y: inout std_logic_vector(6 downto 0) := (others => '0');
        p2Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
        p3X, p3Y: inout std_logic_vector(6 downto 0) := (others => '0');
        p3Hp: inout std_logic_vector(7 downto 0) := (others=> '0');
        p4X, p4Y: inout std_logic_vector(6 downto 0) := (others => '0');
        p4Hp: inout std_logic_vector(7 downto 0) := (others=> '0')

        -- deprecated
        -- stateCode: out std_logic_vector(3 downto 0) := "0000"
    );
end ClientLogic;

architecture behave of ClientLogic is
    -- Originally I used nextX, nextY; but that causes instability.
    signal lX: std_logic_vector(6 downto 0) := initX;
    signal lY: std_logic_vector(6 downto 0) := initY;
    signal lblk, rblk, ublk, dblk: std_logic_vector(0 downto 0);
    signal blk: std_logic_vector(7 downto 0);
        -- whether left is blocked, right / up / down

    signal lHp: std_logic_vector(7 downto 0) := x"FF";
    signal isDead: std_logic := '0';

    type state_type is (stand, move, jump, fall);
    signal state: state_type := fall;
    signal jumpRemain: std_logic_vector(6 downto 0);

    component MapLogic is
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
    end component;

begin

    u0: MapLogic generic map (
        pc=> pc)
    port map (
        clk_rom=> clk_rom,
        p1X=> p1X, p1Y=> p1Y,
        p2X=> p2X, p2Y=> p2Y,
        p3X=> p3X, p3Y=> p3Y,
        p4X=> p4X, p4Y=> p4Y,
        blk=> blk);

    process (lHp, lX, lY) begin
        case pc is
            when 1=>
                p1Hp <= lHp;
                p1X <= lX;
                p1Y <= lY;
            when 2=>
                p2Hp <= lHp;
                p2X <= lX;
                p2Y <= lY;
            when 3=>
                p3Hp <= lHp;
                p3X <= lX;
                p3Y <= lY;
            when 4=>
                p4Hp <= lHp;
                p4X <= lX;
                p4Y <= lY;
        end case;
    end process;

    -- TODO: 跳的时候上面的障碍; fall / jump的时候左右移动
    process (clk) begin
        if rising_edge(clk) then
            --------------------reset game------------------------------
            if rst = '1' then
                lX <= initX;
                lY <= initY;
                lHp <= initHp;
                state <= fall;
--                stateCode <= "0011";

            elsif lHp /= x"00" then
                case state is
                    when stand=>
                        if blk(5) = '0' then -- blk(5)
                            state <= fall;
--                            stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and blk(1) = '0' then -- blk(1)
                            state <= jump;
--                            stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                            state <= move;
--                            stateCode <= "0001";
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and blk(3) = '0' then -- blk(3)
                            state <= move;
--                            stateCode <= "0001";
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand;
--                            stateCode <= "0000";
                            lHp <= lHp - 1;
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when move=>
                        if blk(5) = '0' then -- blk(5)
                            state <= fall;
--                            stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and blk(1) = '0' then -- blk(1)
                            state <= jump;
--                            stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                            state <= move;
--                            stateCode <= "0001";
                            if lHp /= x"FF" then
                                lHp <= lHp + 1;
                            end if;
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and blk(3) = '0' then -- blk(3)
                            state <= move;
--                            stateCode <= "0001";
                            if lHp /= x"FF" then
                                lHp <= lHp + 1;
                            end if;
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand;
--                            stateCode <= "0001";
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when fall=>
                        if blk(5) = '0' then -- blk(5)
                            if wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                                state <= fall;
--                                stateCode <= "0011";
                                if blk(6) = '0' then
                                    lX <= lX - 1;
                                else
                                    lX <= lX;
                                end if;
                                lY <= lY + 1;
                            elsif wasdPressed(0) = '1' and blk(3) = '0' then -- blk(3)
                                state <= fall;
--                                stateCode <= "0011";
                                if blk(4) = '0' then
                                    lX <= lX + 1;
                                else
                                    lX <= lX;
                                end if;
                                lY <= lY + 1;
                            else
                                state <= fall;
--                                stateCode <= "0011";
                                lX <= lX;
                                lY <= lY + 1;
                            end if;
                        else
                            if wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                                state <= move;
--                                stateCode <= "0010";
                                lX <= lX - 1;
                                lY <= lY;
                            elsif wasdPressed(0) = '1' and blk(3) = '0' then -- blk(3)
                                state <= move;
--                                stateCode <= "0010";
                                lX <= lX + 1;
                                lY <= lY;
                            else
                                state <= stand;
--                                stateCode <= "0001";
                                lX <= lX;
                                lY <= lY;
                            end if;
                        end if;

                    when jump=>
                        if blk(1) = '0' and jumpRemain /= "0000000" then -- blk(1)
                            if wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                                jumpRemain <= jumpRemain - 1;
                                state <= jump;
--                                stateCode <= "0010";
                                if blk(0) = '0' then
                                    lX <= lX - 1;
                                else
                                    lX <= lX;
                                end if;
                                lY <= lY - 1;
                            elsif wasdPressed(0) = '1' and blk(3) = '0' then
                                jumpRemain <= jumpRemain - 1;
                                state <= jump;
--                                stateCode <= "0010";
                                if blk(2) = '0' then
                                    lX <= lX + 1;
                                else
                                    lX <= lX;
                                end if;
                                lY <= lY - 1;
                            else
                                jumpRemain <= jumpRemain - 1;
                                state <= jump;
--                                stateCode <= "0010";
                                lX <= lX;
                                lY <= lY - 1;
                            end if;
                        else
                            if wasdPressed(2) = '1' and blk(7) = '0' then -- blk(7)
                                state <= fall;
--                                stateCode <= "0010";
                                lX <= lX - 1;
                                lY <= lY;
                            elsif wasdPressed(0) = '1' and blk(3) = '0' then -- blk(3)
                                state <= fall;
--                                stateCode <= "0010";
                                lX <= lX + 1;
                                lY <= lY;
                            else
                                state <= fall;
--                                stateCode <= "0010";
                                lX <= lX;
                                lY <= lY;
                            end if;
                        end if;
                end case;

            end if;
        end if;
    end process;
end behave;
