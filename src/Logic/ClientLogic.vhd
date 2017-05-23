library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClientLogic is
    generic (
        maxLife: std_logic_vector(7 downto 0) := x"64";
            -- 100
        initJumpRemain: std_logic_vector(6 downto 0) := "0000110"
            -- 6 (out of HEIGHT = 48). Specifies how high you can jump.
    );

    port(
        clk: in std_logic;
        rst: in std_logic;
        wasdPressed: in std_logic_vector(3 downto 0); -- WASD
        initX: in std_logic_vector(6 downto 0) := "0101000"; -- 40
        initY: in std_logic_vector(6 downto 0) := "0011110"; -- 30

        X: out std_logic_vector(6 downto 0);
        Y: out std_logic_vector(6 downto 0);

        stateCode: out std_logic_vector(3 downto 0) := "0000"
        -- life: out std_logic_vector(6 downto 0);
        -- alive: out std_logic
    );
end ClientLogic;

architecture behave of ClientLogic is
    -- Originally I used nextX, nextY; but that causes instability.
    signal lX: std_logic_vector(6 downto 0) := "0101000"; -- 40
    signal lY: std_logic_vector(6 downto 0) := "0011110"; -- 30
    signal lblk, rblk, ublk, dblk: std_logic;
        -- whether left is blocked, right / up / down
    signal lWasdPressed: std_logic_vector(3 downto 0);

    type state_type is (stand, move, jump, fall);
    signal state: state_type := fall;
    signal jumpRemain: std_logic_vector(6 downto 0);

    component MapLogic is
        port (
            x: in std_logic_vector(6 downto 0);
            y: in std_logic_vector(6 downto 0);
            lblk, rblk, ublk, dblk: out std_logic
        );
    end component;

begin
    u0: MapLogic port map(
        x=> lX,
        y=> lY,
        lblk=> lblk,
        rblk=> rblk,
        ublk=> ublk,
        dblk=> dblk);

    -- TODO: 跳的时候上面的障碍; fall / jump的时候左右移动
    process (clk) begin
        if rising_edge(clk) then
            --------------------reset game------------------------------
            if rst = '1' then
                lX <= initX;
                lY <= initY;
                state <= fall; stateCode <= "0011";

            else
                case state is
                    when stand=>
                        if dblk = '0' then
                            state <= fall; stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk = '0' then
                            state <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk = '0' then
                            state <= move; stateCode <= "0001";
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and rblk = '0' then
                            state <= move; stateCode <= "0001";
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand; stateCode <= "0000";
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when move=>
                        if dblk = '0' then
                            state <= fall; stateCode <= "0011";
                            lX <= lX;
                            lY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk = '0' then
                            state <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            lX <= lX;
                            lY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk = '0' then
                            state <= move; stateCode <= "0001";
                            lX <= lX - 1;
                            lY <= lY;
                        elsif wasdPressed(0) = '1' and rblk = '0' then
                            state <= move; stateCode <= "0001";
                            lX <= lX + 1;
                            lY <= lY;
                        else
                            state <= stand; stateCode <= "0001";
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when fall=>
                        if dblk = '0' then
                            if wasdPressed(2) = '1' and lblk = '0' then
                                state <= fall; stateCode <= "0011";
                                lX <= lX - 1;
                                lY <= lY + 1;
                            elsif wasdPressed(0) = '1' and rblk = '0' then
                                state <= fall; stateCode <= "0011";
                                lX <= lX + 1;
                                lY <= lY + 1;
                            else
                                state <= fall; stateCode <= "0011";
                                lX <= lX;
                                lY <= lY + 1;
                            end if;
                        else
                            state <= stand; stateCode <= "0001";
                            lX <= lX;
                            lY <= lY;
                        end if;

                    when jump=>
                        if ublk = '0' and jumpRemain /= "0000000" then
                            if wasdPressed(2) = '1' and lblk = '0' then
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
                                lX <= lX - 1;
                                lY <= lY - 1;
                            elsif wasdPressed(0) = '1' and rblk = '0' then
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
                                lX <= lX + 1;
                                lY <= lY - 1;
                            else
                                jumpRemain <= jumpRemain - 1;
                                state <= jump; stateCode <= "0010";
                                lX <= lX;
                                lY <= lY - 1;
                            end if;
                        else
                            state <= fall; stateCode <= "0011";
                            lX <= lX;
                            lY <= lY;
                        end if;
                end case;

                X <= lX;
                Y <= lY;
            end if;
        end if;
    end process;
end behave;
