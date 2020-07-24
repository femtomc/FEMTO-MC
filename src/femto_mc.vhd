library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package femto_mc is

component full_adder
	port (
		a, b, c_in: in std_ulogic;
		s, c_out: out std_ulogic);
end component;

component adder_16bit is
	port (
		a: in std_logic_vector(15 downto 0);
		b: in std_logic_vector(15 downto 0);
		c: out std_logic_vector(15 downto 0));
end component;

component hexDigit is
port (
	encoding: in std_logic_vector(3 downto 0);
	digit: out std_logic_vector(6 downto 0)
	);
end component;

component regstd is
port (
	en: in std_ulogic;
	clk: in std_ulogic;
	reset: in std_ulogic;
	d: in std_logic_vector(7 downto 0);
	q: out std_logic_vector(7 downto 0)
	);
end component;

component regstd16 is
port (
	en: in std_ulogic;
	clk: in std_ulogic;
	reset: in std_ulogic;
	d: in std_logic_vector(15 downto 0);
	q: out std_logic_vector(15 downto 0)
	);
end component;

component reg_arr_16bit is
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
end component;

component alu_bitslice is
	port (a, b, x_3, x_2, x_1, x_0, c_in, op_0: in std_ulogic;
			f_out, eq, c_out: out std_ulogic);
end component;

component alu is
    port (a, b: in std_logic_vector(15 downto 0);
    x_3, x_2, x_1, x_0, op_0: in std_ulogic;
    eq: out std_ulogic;
    f_out: out std_logic_vector(15 downto 0));
end component;

component barrel_shifter_16bit is
    port (
             input: in std_logic_vector(15 downto 0);
             shift: in std_logic_vector(15 downto 0);
             direction: std_logic;
             output: out std_logic_vector(15 downto 0)
);
end component;

end femto_mc;
