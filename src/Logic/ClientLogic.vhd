library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
   
entity ClientLogic is
    generic (
        initJumpRemain: std_logic_vector(6 downto 0) := "0000110"
            -- 6 (out of HEIGHT = 48). Specifies how high you can jump.
    );

    port(
        clk_rom: in std_logic;
        clk: in std_logic;
        rst: in std_logic;
        wasdPressed: in std_logic_vector(3 downto 0); -- WASD
        initX: in std_logic_vector(6 downto 0) := "0101000"; -- 40
        initY: in std_logic_vector(6 downto 0) := "0011110"; -- 30

        X: out std_logic_vector(6 downto 0);
        Y: out std_logic_vector(6 downto 0);
        hp: out std_logic_vector(7 downto 0);

        stateCode: out std_logic_vector(3 downto 0) := "0000"
    );
end ClientLogic;

architecture behave of ClientLogic is
    -- Originally I used nextX, nextY; but that causes instability.
    signal lX: std_logic_vector(6 downto 0) := "0101000"; -- 40
    signal lY: std_logic_vector(6 downto 0) := "0011110"; -- 30
    signal lblk, rblk, ublk, dblk: std_logic_vector(0 downto 0);
--    signal l_blk: std_logic_vector(7 downto 0) := (others=> '0');
        -- whether left is blocked, right / up / down

    signal lHp: std_logic_vector(7 downto 0) := x"FF";
    signal isDead: std_logic := '0';

    type state_type is (stand, move, jump, fall);
    signal state: state_type := fall;
    signal jumpRemain: std_logic_vector(6 downto 0);

    component MapLogic is
        port (
            clk_rom: in std_logic;
            x: in std_logic_vector(6 downto 0);
            y: in std_logic_vector(6 downto 0);
            lblk, rblk, ublk, dblk: out std_logic_vector(0 downto 0)
        );
    end component;

begin

    u0: MapLogic port map(
        clk_rom=> clk_rom,
        x=> lX,
        y=> lY,
        lblk=> lblk,
        rblk=> rblk,
        ublk=> ublk,
        dblk=> dblk);

    hp <= x"FF"; -- lHp

    -- TODO: 跳的时候上面的障碍; fall / jump的时候左右移动
    process (clk) begin
        if rising_edge(clk) then
            --------------------reset game------------------------------
            if rst = '1' then
                lX <= initX;
                lY <= initY;
                state <= fall; stateCode <= "0011";

            elsif lHp /= x"00" then
                case state is
                    when stand=>
                        if dblk(0) = '0' then -- dblk(0)
                            state <= fall; stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk(0) = '0' then -- ublk(0)
                            state <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                            state <= move; stateCode <= "0001";
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                            state <= move; stateCode <= "0001";
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand; stateCode <= "0000";
                            -- lHp <= lHp - 1;
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when move=>
                        if dblk(0) = '0' then -- dblk(0)
                            state <= fall; stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk(0) = '0' then -- ublk(0)
                            state <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                            state <= move; stateCode <= "0001";
                            if lHp /= x"FF" then
                                lHp <= lHp + 1;
                            end if;
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                            state <= move; stateCode <= "0001";
                            if lHp /= x"FF" then
                                lHp <= lHp + 1;
                            end if;
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand; stateCode <= "0001";
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when fall=>
                        if dblk(0) = '0' then -- dblk(0)
                            if wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                                state <= fall; stateCode <= "0011";
--                                if l_blk(6) = '0' then
                                    lX <= lX - 1;
--                                else
--                                    lX <= lX;
--                                end if;
                                lY <= lY + 1;
                            elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                                state <= fall; stateCode <= "0011";
--                                if l_blk(4) = '0' then
                                    lX <= lX + 1;
--                                else
--                                    lX <= lX;
--                                end if;
                                lY <= lY + 1;
                            else
                                state <= fall; stateCode <= "0011";
                                lX <= lX;
                                lY <= lY + 1;
                            end if;
                        else
                            if wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                                state <= move; stateCode <= "0010";
                                lX <= lX - 1;
                                lY <= lY;
                            elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                                state <= move; stateCode <= "0010";
                                lX <= lX + 1;
                                lY <= lY;
                            else
                                state <= stand; stateCode <= "0001";
                                lX <= lX;
                                lY <= lY;
                            end if;
                        end if;

                    when jump=>
                        if ublk(0) = '0' and jumpRemain /= "0000000" then -- ublk(0)
                            if wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
--                                if l_blk(0) = '0' then
                                    lX <= lX - 1;
--                                else
--                                    lX <= lX;
--                                end if;
                                lY <= lY - 1;
                            elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
--                                if l_blk(2) = '0' then
                                    lX <= lX + 1;
--                                else
--                                    lX <= lX;
--                                end if;
                                lY <= lY - 1;
                            else
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
                                lX <= lX;
                                lY <= lY - 1;
                            end if;
                        else
                            if wasdPressed(2) = '1' and lblk(0) = '0' then -- lblk(0)
                                state <= fall; stateCode <= "0010";
                                lX <= lX - 1;
                                lY <= lY;
                            elsif wasdPressed(0) = '1' and rblk(0) = '0' then -- rblk(0)
                                state <= fall; stateCode <= "0010";
                                lX <= lX + 1;
                                lY <= lY;
                            else
                                state <= fall; stateCode <= "0010";
                                lX <= lX;
                                lY <= lY;
                            end if;
                        end if;
                end case;

                X <= lX;
                Y <= lY;
            end if;
        end if;
    end process;
end behave;
