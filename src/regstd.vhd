library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regstd is
    port (
             en: in std_ulogic;
             clk: in std_ulogic;
             reset: in std_ulogic;
             d: in std_ulogic_vector(7 downto 0);
             q: out std_ulogic_vector(7 downto 0)
         );
end entity regstd;

architecture behav of regstd is
begin
    storage : process(clk, reset) is
    begin
        if reset = '1' then
            q <= "00000000";
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process storage;
end architecture behav;
