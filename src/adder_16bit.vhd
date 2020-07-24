library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.femto_mc.all;

entity adder_16bit is
	port (a: in std_ulogic_vector(15 downto 0);
			b: in std_ulogic_vector(15 downto 0);
			c: out std_ulogic_vector(15 downto 0));
end entity adder_16bit;

architecture dataflow of adder_16bit is
	
	signal carry: std_ulogic_vector(16 downto 0) := "00000000000000000";
	
begin
	u0: full_adder port map (a => a(0), b => b(0), c_in => carry(0), s => c(0), c_out => carry(1));
	u1: full_adder port map (a => a(1), b => b(1), c_in => carry(1), s => c(1), c_out => carry(2));
	u2: full_adder port map (a => a(2), b => b(2), c_in => carry(2), s => c(2), c_out => carry(3));
	u3: full_adder port map (a => a(3), b => b(3), c_in => carry(3), s => c(3), c_out => carry(4));
	u4: full_adder port map (a => a(4), b => b(4), c_in => carry(4), s => c(4), c_out => carry(5));
	u5: full_adder port map (a => a(5), b => b(5), c_in => carry(5), s => c(5), c_out => carry(6));
	u6: full_adder port map (a => a(6), b => b(6), c_in => carry(6), s => c(6), c_out => carry(7));
	u7: full_adder port map (a => a(7), b => b(7), c_in => carry(7), s => c(7), c_out => carry(8));
	u8: full_adder port map (a => a(8), b => b(8), c_in => carry(8), s => c(8), c_out => carry(9));
	u9: full_adder port map (a => a(9), b => b(9), c_in => carry(9), s => c(9), c_out => carry(10));
	u10: full_adder port map (a => a(10), b => b(10), c_in => carry(10), s => c(10), c_out => carry(11));
	u11: full_adder port map (a => a(11), b => b(11), c_in => carry(11), s => c(11), c_out => carry(12));
	u12: full_adder port map (a => a(12), b => b(12), c_in => carry(12), s => c(12), c_out => carry(13));
	u13: full_adder port map (a => a(13), b => b(13), c_in => carry(13), s => c(13), c_out => carry(14));
	u14: full_adder port map (a => a(14), b => b(14), c_in => carry(14), s => c(14), c_out => carry(15));
	u15: full_adder port map (a => a(15), b => b(15), c_in => carry(15), s => c(15), c_out => carry(16));
end architecture dataflow;
		
