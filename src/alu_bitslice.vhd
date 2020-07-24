library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.femto_mc.all;

entity alu_bitslice is
	port (a, b, x_3, x_2, x_1, x_0, c_in, op_0: in std_ulogic;
			f_out, eq, c_out: out std_ulogic);
end entity alu_bitslice;

architecture dataflow of alu_bitslice is
signal mux_0 : std_ulogic := '0';
signal mux_1 : std_ulogic := '0';
signal mux_2 : std_ulogic := '0';
signal mux_3 : std_ulogic := '0';
signal mux_4 : std_ulogic := '0';
signal mux_5 : std_ulogic := '0';
signal mux_6 : std_ulogic := '0';
signal mux_7 : std_ulogic := '0';
signal mux_8 : std_ulogic := '0';
signal inter_out_add : std_ulogic := '0';

begin

	-- Arithmetic
	mux_0 <= '0' when (x_3 = '0') else '1';
	mux_2 <= mux_0 when (x_0 = '0') else '0';
	mux_1 <= a when (mux_2 = '0') else (not a);
	mux_4 <= '0' when (x_0 = '0') else mux_0;
	mux_3 <= b when (mux_4 = '0') else (not b);
	
	u1: full_adder port map (a => mux_1, b => mux_3, c_in => c_in, s => inter_out_add, c_out => c_out);
	
	-- Logic
	mux_5 <= (a and b) when (x_3 = '0') else (a or b);
	mux_6 <= (mux_5) when (x_2 = '0') else (a xor b);
	mux_7 <= (mux_6) when (x_1 = '0') else (a nand b);
	mux_8 <= (mux_7) when (x_0 = '0') else (not mux_7);
	
	-- Out
	f_out <= inter_out_add when (op_0 = '0') else mux_8;
	eq <= not (a xor b);
	
end architecture dataflow;
