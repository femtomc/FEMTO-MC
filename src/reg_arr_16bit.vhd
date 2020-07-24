library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.femto_mc.all;

entity reg_arr_16bit is
    port (en: in std_ulogic;
          clk: in std_ulogic;
          reset: in std_ulogic;
          data: in std_logic_vector(15 downto 0);
          reg_w_addr: in std_logic_vector(3 downto 0);
          reg_a_addr: in std_logic_vector(3 downto 0);
          reg_b_addr: in std_logic_vector(3 downto 0);
          reg_a: out std_logic_vector(15 downto 0);
          reg_b: out std_logic_vector(15 downto 0);

          -- Debug
          debug_0: out std_logic_vector(15 downto 0);
          debug_1: out std_logic_vector(15 downto 0);
          debug_2: out std_logic_vector(15 downto 0);
          debug_3: out std_logic_vector(15 downto 0);
          debug_4: out std_logic_vector(15 downto 0);
          debug_5: out std_logic_vector(15 downto 0);
          debug_6: out std_logic_vector(15 downto 0);
          debug_7: out std_logic_vector(15 downto 0);
          debug_8: out std_logic_vector(15 downto 0);
          debug_9: out std_logic_vector(15 downto 0);
          debug_10: out std_logic_vector(15 downto 0);
          debug_11: out std_logic_vector(15 downto 0);
          debug_12: out std_logic_vector(15 downto 0);
          debug_13: out std_logic_vector(15 downto 0);
          debug_14: out std_logic_vector(15 downto 0);
          debug_15: out std_logic_vector(15 downto 0);
          debug_enable: out std_logic_vector(15 downto 0)
      );
end;

architecture behav of reg_arr_16bit is

    signal out_0 : std_logic_vector(15 downto 0);
    signal out_1 : std_logic_vector(15 downto 0);
    signal out_2 : std_logic_vector(15 downto 0);
    signal out_3 : std_logic_vector(15 downto 0);
    signal out_4 : std_logic_vector(15 downto 0);
    signal out_5 : std_logic_vector(15 downto 0);
    signal out_6 : std_logic_vector(15 downto 0);
    signal out_7 : std_logic_vector(15 downto 0);
    signal out_8 : std_logic_vector(15 downto 0);
    signal out_9 : std_logic_vector(15 downto 0);
    signal out_10 : std_logic_vector(15 downto 0);
    signal out_11 : std_logic_vector(15 downto 0);
    signal out_12 : std_logic_vector(15 downto 0);
    signal out_13 : std_logic_vector(15 downto 0);
    signal out_14 : std_logic_vector(15 downto 0);
    signal out_15 : std_logic_vector(15 downto 0);

    signal enable : std_logic_vector(15 downto 0);

begin
    regstd_0 : regstd16 port map (en => enable(0),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_0);

    regstd_1 : regstd16 port map (en => enable(1),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_1);

    regstd_2 : regstd16 port map (en => enable(2),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_2);

    regstd_3 : regstd16 port map (en => enable(3),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_3);

    regstd_4 : regstd16 port map (en => enable(4),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_4);

    regstd_5 : regstd16 port map (en => enable(5),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_5);

    regstd_6 : regstd16 port map (en => enable(6),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_6);

    regstd_7 : regstd16 port map (en => enable(7),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_7);

    regstd_8 : regstd16 port map (en => enable(8),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_8);

    regstd_9 : regstd16 port map (en => enable(9),
                                  clk => clk,
                                  reset => reset,
                                  d => data,
                                  q => out_9);

    regstd_10 : regstd16 port map (en => enable(10),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_10);

    regstd_11 : regstd16 port map (en => enable(11),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_11);

    regstd_12 : regstd16 port map (en => enable(12),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_12);

    regstd_13 : regstd16 port map (en => enable(13),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_13);

    regstd_14 : regstd16 port map (en => enable(14),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_14);

    regstd_15 : regstd16 port map (en => enable(15),
                                   clk => clk,
                                   reset => reset,
                                   d => data,
                                   q => out_15);

    debug_0 <= out_0;
    debug_1 <= out_1;
    debug_2 <= out_2;
    debug_3 <= out_3;
    debug_4 <= out_4;
    debug_5 <= out_5;
    debug_6 <= out_6;
    debug_7 <= out_7;
    debug_8 <= out_8;
    debug_9 <= out_9;
    debug_10 <= out_10;
    debug_11 <= out_11;
    debug_12 <= out_12;
    debug_13 <= out_13;
    debug_14 <= out_14;
    debug_15 <= out_15;
    debug_enable <= enable;

    with reg_w_addr & en select
        enable <= "0000000000000001" when "00001",
                  "0000000000000010" when "00011",
                  "0000000000000100" when "00101",
                  "0000000000001000" when "00111",
                  "0000000000010000" when "01001",
                  "0000000000100000" when "01011",
                  "0000000001000000" when "01101",
                  "0000000010000000" when "01111",
                  "0000000100000000" when "10001",
                  "0000001000000000" when "10011",
                  "0000010000000000" when "10101",
                  "0000100000000000" when "10111",
                  "0001000000000000" when "11001",
                  "0010000000000000" when "11011",
                  "0100000000000000" when "11101",
                  "1000000000000000" when "11111",
                  "0000000000000000" when others;

    with reg_a_addr select
        reg_a <= out_0 when "0000",
                 out_1 when "0001",
                 out_2 when "0010",
                 out_3 when "0011",
                 out_4 when "0100",
                 out_5 when "0101",
                 out_6 when "0110",
                 out_7 when "0111",
                 out_8 when "1000",
                 out_9 when "1001",
                 out_10 when "1010",
                 out_11 when "1011",
                 out_12 when "1100",
                 out_13 when "1101",
                 out_14 when "1110",
                 out_15 when "1111";

    with reg_b_addr select
        reg_b <= out_0 when "0000",
                 out_1 when "0001",
                 out_2 when "0010",
                 out_3 when "0011",
                 out_4 when "0100",
                 out_5 when "0101",
                 out_6 when "0110",
                 out_7 when "0111",
                 out_8 when "1000",
                 out_9 when "1001",
                 out_10 when "1010",
                 out_11 when "1011",
                 out_12 when "1100",
                 out_13 when "1101",
                 out_14 when "1110",
                 out_15 when "1111";

end architecture behav;
