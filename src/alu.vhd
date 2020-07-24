library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.femto_mc.all;

entity alu is
    port (a, b: in std_logic_vector(15 downto 0);
    x_3, x_2, x_1, x_0, op_0: in std_ulogic;
    eq: out std_ulogic := '0';
    f_out: out std_logic_vector(15 downto 0));
end entity alu;

architecture dataflow of alu is
    signal carry: std_logic_vector(16 downto 0) := "00000000000000000";
    signal eq_16bit: std_logic_vector(15 downto 0);
begin

    u0: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(0), 
                               b => b(0), 
                               eq => eq_16bit(0),
                               c_in => x_1, 
                               f_out => f_out(0), 
                               c_out => carry(1));

    u1: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(1), 
                               b => b(1), 
                               eq => eq_16bit(1),
                               c_in => carry(1), 
                               f_out => f_out(1), 
                               c_out => carry(2));

    u2: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(2), 
                               b => b(2), 
                               eq => eq_16bit(2),
                               c_in => carry(2), 
                               f_out => f_out(2), 
                               c_out => carry(3));

    u3: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(3), 
                               b => b(3), 
                               eq => eq_16bit(3),
                               c_in => carry(3), 
                               f_out => f_out(3), 
                               c_out => carry(4));

    u4: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(4), 
                               b => b(4), 
                               eq => eq_16bit(4),
                               c_in => carry(4), 
                               f_out => f_out(4), 
                               c_out => carry(5));

    u5: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(5), 
                               b => b(5), 
                               eq => eq_16bit(5),
                               c_in => carry(5), 
                               f_out => f_out(5), 
                               c_out => carry(6));

    u6: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(6), 
                               b => b(6), 
                               eq => eq_16bit(6),
                               c_in => carry(6), 
                               f_out => f_out(6), 
                               c_out => carry(7));

    u7: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(7), 
                               b => b(7), 
                               eq => eq_16bit(7),
                               c_in => carry(7), 
                               f_out => f_out(7), 
                               c_out => carry(8));	

    u8: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(8), 
                               b => b(8), 
                               eq => eq_16bit(8),
                               c_in => carry(8), 
                               f_out => f_out(8), 
                               c_out => carry(9));

    u9: alu_bitslice port map (x_3 => x_3, 
                               x_2 => x_2, 
                               x_1 => x_1, 
                               x_0 => x_0, 
                               op_0 => op_0, 
                               a => a(9), 
                               b => b(9), 
                               eq => eq_16bit(9),
                               c_in => carry(9), 
                               f_out => f_out(9), 
                               c_out => carry(10));

    u10: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(10), 
                                b => b(10), 
                                eq => eq_16bit(10),
                                c_in => carry(10), 
                                f_out => f_out(10), 
                                c_out => carry(11));

    u11: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(11), 
                                b => b(11), 
                                eq => eq_16bit(11),
                                c_in => carry(11), 
                                f_out => f_out(11), 
                                c_out => carry(12));

    u12: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(12), 
                                b => b(12), 
                                eq => eq_16bit(12),
                                c_in => carry(12), 
                                f_out => f_out(12), 
                                c_out => carry(13));

    u13: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(13), 
                                b => b(13), 
                                eq => eq_16bit(13),
                                c_in => carry(13), 
                                f_out => f_out(13), 
                                c_out => carry(14));

    u14: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(14), 
                                b => b(14), 
                                eq => eq_16bit(14),
                                c_in => carry(14), 
                                f_out => f_out(14), 
                                c_out => carry(15));

    u15: alu_bitslice port map (x_3 => x_3, 
                                x_2 => x_2, 
                                x_1 => x_1, 
                                x_0 => x_0, 
                                op_0 => op_0, 
                                a => a(15), 
                                b => b(15), 
                                eq => eq_16bit(15),
                                c_in => carry(15), 
                                f_out => f_out(15), 
                                c_out => carry(16));

    eq <= and_reduce(eq_16bit);

end architecture dataflow;
