library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.femto_mc.all;

entity hex_counter is
port (
	increment, reset: in std_ulogic;
	lowDisplay: out std_logic_vector(6 downto 0);
	highDisplay: out std_logic_vector(6 downto 0));
end entity hex_counter;

architecture dataflow of hex_counter is

attribute chip_pin: string;
attribute chip_pin of increment: signal is "N21"; -- button 02
attribute chip_pin of reset: signal is "R24"; -- button 03
attribute chip_pin of highDisplay: signal is "AA14, AG18, AF17, AH17, AG17, AE17, AD17";
attribute chip_pin of lowDisplay: signal is "AC17, AA15, AB15, AB17, AA16, AB16, AA17";

signal counter : std_logic_vector(7 downto 0) := "00000000";
signal next_counter : std_logic_vector(7 downto 0) := "00000000";

begin
	n_adder: nbit_adder port map (
		a => counter,
		b => "00000001",
		c => next_counter
		);
	
	reg: regstd port map (
		clk => not increment,
		en => '1',
		reset => not reset,
		d => next_counter,
		q => counter
		);
		
	low_digit: hexDigit port map (
		encoding => counter(3 downto 0),
		digit => lowDisplay
		);
		
	high_digit: hexDigit port map (
		encoding => counter(7 downto 4),
		digit => highDisplay
		);
end;
