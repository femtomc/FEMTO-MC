library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
	port (a, b, c_in: in std_ulogic;
			s, c_out: out std_ulogic);
end entity full_adder;

architecture dataflow of full_adder is
begin
	c_out <= ((a xor b) and c_in) or (a and b);
	s <= (a xor b) xor c_in;
end architecture dataflow;