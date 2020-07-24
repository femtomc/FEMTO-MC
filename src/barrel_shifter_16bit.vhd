library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.femto_mc.all;

entity barrel_shifter_16bit is
    port (
             input: in std_logic_vector(15 downto 0);
             shift: in std_logic_vector(15 downto 0);
             direction: std_logic;
             output: out std_logic_vector(15 downto 0)
);
end entity barrel_shifter_16bit;

architecture dataflow of barrel_shifter_16bit is
    signal shift_8_l : std_logic_vector(15 downto 0);
    signal shift_4_l : std_logic_vector(15 downto 0);
    signal shift_2_l : std_logic_vector(15 downto 0);
    signal shift_1_l : std_logic_vector(15 downto 0);
    signal shift_8_r : std_logic_vector(15 downto 0);
    signal shift_4_r : std_logic_vector(15 downto 0);
    signal shift_2_r : std_logic_vector(15 downto 0);
    signal shift_1_r : std_logic_vector(15 downto 0);
    signal larger_than_16 : std_logic;
begin
    with shift(3) select
        shift_8_l <= input(7 downto 0) & input (15 downto 8) when '1',
                     input when '0';

    with shift(3) select
        shift_8_r <= input(7 downto 0) & input(15 downto 8) when '1',
                     input when '0';

    with shift(2) select
        shift_4_l <= shift_8_l(11 downto 0) & shift_8_l(15 downto 12) when '1',
                     shift_8_l when '0';

    with shift(2) select
        shift_4_r <= shift_8_r(3 downto 0) & shift_8_r(15 downto 4) when '1',
                     shift_8_r when '0';

    with shift(1) select
        shift_2_l <= shift_4_l(13 downto 0) & shift_4_l(15 downto 14) when '1',
                     shift_4_l when '0';

    with shift(1) select
        shift_2_r <= shift_4_r(1 downto 0) & shift_4_r(15 downto 2) when '1',
                     shift_4_r when '0';

    with shift(0) select
        shift_1_l <= shift_2_l(14 downto 0) & shift_2_l(15) when '1',
                     shift_2_l when '0';

    with shift(0) select
        shift_1_r <= shift_2_r(0) & shift_2_r(15 downto 1) when '1',
                     shift_2_r when '0';

    larger_than_16 <= or_reduce(shift(15 downto 4));

    with to_stdlogicvector(direction & larger_than_16) select
        output <= shift_1_l when "10",
                  shift_1_r when "00",
                  "0000000000000000" when others;

end architecture dataflow;

