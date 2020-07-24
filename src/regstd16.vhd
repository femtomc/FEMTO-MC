library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regstd16 is
    port (
             en: in std_ulogic;
             clk: in std_ulogic;
             reset: in std_ulogic;
             d: in std_logic_vector(15 downto 0);
             q: out std_logic_vector(15 downto 0)
         );
end entity regstd16;

architecture behav of regstd16 is
begin
    storage : process(clk, reset) is
    begin
        if reset = '1' then
            q <= "0000000000000000";
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process storage;
end architecture behav;
