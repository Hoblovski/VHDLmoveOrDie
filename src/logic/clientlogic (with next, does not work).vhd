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
    signal lX, nextX: std_logic_vector(6 downto 0) := "0101000"; -- 40
    signal lY, nextY: std_logic_vector(6 downto 0) := "0011110"; -- 30
    signal lblk, rblk, ublk, dblk: std_logic;
        -- whether left is blocked, right / up / down
    signal lWasdPressed: std_logic_vector(3 downto 0);

    type state_type is (stand, move, jump, fall);
    signal state, nextState: state_type := fall;
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
        x=> nextX,
        y=> nextY,
        lblk=> lblk,
        rblk=> rblk,
        ublk=> ublk,
        dblk=> dblk);

    -- TODO: 跳的时候上面的障碍; fall / jump的时候左右移动
    process (clk) begin
        if rising_edge(clk) then
            --------------------reset game------------------------------
            if rst = '1' then
                nextX <= initX;
                nextY <= initY;
                nextState <= fall; stateCode <= "0011";

            else
                case state is
                    when stand=>
                        if dblk = '0' then
                            nextState <= fall; stateCode <= "0011";
                            nextX <= lX;
                            nextY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk = '0' then
                            nextState <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            nextX <= lX;
                            nextY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk = '0' then
                            nextState <= move; stateCode <= "0001";
                            nextX <= lX - 1;
                            nextY <= lY;
                        elsif wasdPressed(0) = '1' and rblk = '0' then
                            nextState <= move; stateCode <= "0001";
                            nextX <= lX + 1;
                            nextY <= lY;
                        else
                            nextState <= stand; stateCode <= "0000";
                            nextX <= lX;
                            nextY <= lY;
                        end if;

                    when move=>
                        if dblk = '0' then
                            nextState <= fall; stateCode <= "0011";
                            nextX <= lX;
                            nextY <= lY + 1;
                        elsif wasdPressed(3) = '1' and ublk = '0' then
                            nextState <= jump; stateCode <= "0010";
                            jumpRemain <= initJumpRemain;
                            nextX <= lX;
                            nextY <= lY - 1;
                        elsif wasdPressed(2) = '1' and lblk = '0' then
                            nextState <= move; stateCode <= "0001";
                            nextX <= lX - 1;
                            nextY <= lY;
                        elsif wasdPressed(0) = '1' and rblk = '0' then
                            nextState <= move; stateCode <= "0001";
                            nextX <= lX + 1;
                            nextY <= lY;
                        else
                            nextState <= stand; stateCode <= "0001";
                            nextX <= lX;
                            nextY <= lY;
                        end if;

                    when fall=>
                        if dblk = '0' then
                            nextState <= fall; stateCode <= "0011";
                            nextX <= lX;
                            nextY <= lY + 1;
                        else
                            nextState <= stand; stateCode <= "0001";
                            nextX <= lX;
                            nextY <= lY;
                        end if;

                    when jump=>
                        if ublk = '0' and jumpRemain /= "0000000" then
                            jumpRemain <= jumpRemain - 1;
                            nextState <= jump; stateCode <= "0010";
                            nextX <= lX;
                            nextY <= lY - 1;
                        else
                            nextState <= stand; stateCode <= "0001";
                            nextX <= lX;
                            nextY <= lY;
                        end if;
                end case;

                lX <= nextX;
                lY <= nextY;
                X <= nextX;
                Y <= nextY;
                state <= nextState;
            end if;
        end if;
    end process;
end behave;
