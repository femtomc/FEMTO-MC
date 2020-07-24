library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
library cscie93;
use work.femto_mc.all;

entity femto_mc_cpu is
    port (
             -- CLOCK
             clk50mhz : in std_logic;

             -- PS/2 PORT
             ps2_clk   : in std_logic;
             ps2_data  : in std_logic;

             -- LCD
             lcd_en    : out std_logic;
             lcd_on    : out std_logic;
             lcd_rs    : out std_logic;
             lcd_rw    : out std_logic;
             lcd_db    : inout std_logic_vector(7 downto 0);

             -- RS232
             rs232_rxd : in std_logic;
             rs232_txd : out std_logic;
             rs232_cts : out std_logic;

             -- SSRAM interface
             sram_dq   : inout std_logic_vector(15 downto 0);
             sram_addr : out std_logic_vector (18 downto 0);
             sram_ce_N : out std_logic;
             sram_oe_N : out std_logic;
             sram_we_N : out std_logic;
             sram_ub_N : out std_logic;
             sram_lb_N : out std_logic;

             hex4bank_high : out std_logic_vector(13 downto 0);
             hex4bank_low : out std_logic_vector(13 downto 0);
             my_mem_reset : in std_ulogic;
             my_clock_step : in std_ulogic;
             my_mem_suspend : in std_ulogic;
             my_clock_hold : in std_ulogic;

             debug_current_state : out std_logic_vector(27 downto 0);
             debug_hexDisplay : in std_ulogic := '0';

             -- CPU
             switch_arr : in std_logic_vector(14 downto 0);
             led_arr : out std_logic_vector(17 downto 0);
             my_pc_reset : in std_ulogic;
             out_reg_1 : out std_logic;
             out_reg_2 : out std_logic;
             out_src1 : out std_logic;
             out_src2: out std_logic;
             out_alu_out : out std_logic_vector(3 downto 0)
         );
end;

architecture dataflow of femto_mc_cpu is

    -- Memory subsystem
    attribute chip_pin : string;

    attribute chip_pin of clk50mhz : signal is "Y2";

    attribute chip_pin of ps2_clk : signal is "G6";
    attribute chip_pin of ps2_data : signal is "H5";

    attribute chip_pin of lcd_on : signal is "L5";
    attribute chip_pin of lcd_en : signal is "L4";
    attribute chip_pin of lcd_rw : signal is "M1";
    attribute chip_pin of lcd_rs : signal is "M2";
    attribute chip_pin of lcd_db : signal is "M5,M3,K2,K1,K7,L2,L1,L3";

    attribute chip_pin of rs232_rxd : signal is "G12";
    attribute chip_pin of rs232_txd : signal is "G9";
    attribute chip_pin of rs232_cts : signal is "G14";

    attribute chip_pin of sram_dq : signal is "AG3,AF3,AE4,AE3,AE1,AE2,AD2,AD1,AF7,AH6,AG6,AF6,AH4,AG4,AF4,AH3";
    attribute chip_pin of sram_addr : signal is "T8,AB8,AB9,AC11,AB11,AA4,AC3,AB4, AD3, AF2, T7, AF5, AC5, AB5, AE6, AB6, AC7, AE7, AD7, AB7";

    attribute chip_pin of sram_ce_N : signal is "AF8";
    attribute chip_pin of sram_oe_N : signal is "AD5";
    attribute chip_pin of sram_we_N : signal is "AE8";
    attribute chip_pin of sram_ub_N : signal is "AC4";
    attribute chip_pin of sram_lb_N : signal is "AD4";

    attribute chip_pin of hex4bank_high : signal is "Y19,AF23,AD24,AA21,AB20,U21,V21,W28,W27,Y26,W26,Y25,AA26,AA25";
    attribute chip_pin of hex4bank_low : signal is "U24,U23,W25,W22,W21,Y22,M24,H22,J22,L25,L26,E17,F22,G18";

    attribute chip_pin of debug_current_state : signal is "AA14,AG18,AF17,AH17,AG17,AE17,AD17,AC17,AA15,AB15,AB17,AA16,AB16,AA17,AH18,AF18,AG19,AH19,AB18,AC18,AD18,AE18,AF19,AE19,AH21,AG21,AA19,AB19";

    attribute chip_pin of my_pc_reset : signal is "M23";
    attribute chip_pin of my_mem_reset : signal is "M21";
    attribute chip_pin of my_clock_step : signal is "N21";
    attribute chip_pin of my_mem_suspend : signal is "Y24";
    attribute chip_pin of my_clock_hold : signal is "Y23";
    attribute chip_pin of switch_arr : signal is "AA22,AA23,AA24,AB23,AB24,AC24,AB25,AC25,AB26,AD26,AC26,AB27,AD27,AC27,AC28";

    signal sysclk1 : std_ulogic;
    signal sysclk2 : std_ulogic;

    signal my_mem_data_write : std_logic_vector(31 downto 0);
    signal my_mem_rw : std_ulogic := '0';
    signal my_mem_addressready : std_ulogic := '0';
    signal my_clock_divide_limit : std_logic_vector(19 downto 0) := "00001000000000000010";
    signal my_mem_data_read : std_logic_vector(31 downto 0);
    signal my_mem_dataready_inv : std_ulogic := '0';
    signal my_serial_character_ready : std_ulogic;
    signal my_ps2_character_ready : std_ulogic;
    signal hex4bank_input : std_logic_vector(15 downto 0);

    attribute chip_pin of debug_hexDisplay : signal is "AB28";

    -- CPU
    type CPUState is (
    R_Step1,
    R_Step2,
    R_Step3,
    R_Step4_5,
    R_Step6,
    R_Step8,
    W_Step1,
    W_Step2,
    W_Step3,
    W_Step4_5,
    W_Step7_8_9,
    IDLE,
    ReadMemInstr,
    OpALUadd,
    OpALUlog,
    OpMemInstr,
    OpShiftLeft,
    OpShiftRight,
    OpALUlui,
    OpALUaddi,
    OpBEQ,
    OpJUMP,
    ErrorState);

    signal debug_current_state_asVector_1 : std_logic_vector(3 downto 0);
    signal debug_current_state_asVector_2 : std_logic_vector(3 downto 0);

    signal current_state : CPUState := IDLE;

    signal counter : std_logic_vector(15 downto 0) := "0000000000000000";
    signal next_counter : std_logic_vector(15 downto 0) := "0000000000000000";
    signal mux_counter : std_logic_vector(15 downto 0) := "0000000000000000";
    signal pc_write : std_ulogic;
    signal beq_or_jump : std_logic_vector(1 downto 0) := "00";

    signal my_mem_addr : std_logic_vector(15 downto 0);
    signal mem_addr_line : std_ulogic := '1';
    signal mem_instr_func : std_logic_vector(3 downto 0);
    signal alu_or_reg_to_mem : std_ulogic := '0';

    signal current_instr : std_logic_vector(15 downto 0);
    signal immed_trans : std_logic_vector(15 downto 0);

    signal left_shift_lui_addi : std_logic_vector(15 downto 0);

    signal select_mem_shift_jump_alu : std_logic_vector(1 downto 0) := "00";
    signal data_to_reg_arr : std_logic_vector(15 downto 0);
    signal state_reg_write : std_ulogic;
    signal mem_write_to_reg : std_ulogic;
    signal reg_write : std_ulogic;
    signal ir_write : std_ulogic := '0';
    signal src1 : std_logic_vector(3 downto 0);
    signal src2 : std_logic_vector(3 downto 0);
    signal write_addr : std_logic_vector(3 downto 0);
    signal src1_out : std_logic_vector(15 downto 0);
    signal src2_out : std_logic_vector(15 downto 0);

    signal addi_lui_or_noop : std_ulogic := '0';
    signal add_or_log : std_ulogic := '1';
    signal addi_or_lui : std_ulogic := '0';
    signal mux_src2 : std_logic_vector(15 downto 0);
    signal mux_src1 : std_logic_vector(15 downto 0);
    signal mux_func_0 : std_ulogic;
    signal mux_func_1 : std_ulogic;
    signal mux_func_2 : std_ulogic;
    signal mux_func_3 : std_ulogic;
    signal eq : std_ulogic := '0';
    signal alu_out : std_logic_vector(15 downto 0);

    signal shift_direction : std_ulogic := '0';
    signal shift_magnitude : std_logic_vector(3 downto 0);
    signal shift_out : std_logic_vector(15 downto 0);

    -- Debug
    signal reg_arr_0 : std_logic_vector(15 downto 0);
    signal reg_arr_1 : std_logic_vector(15 downto 0);
    signal reg_arr_2 : std_logic_vector(15 downto 0);
    signal reg_arr_3 : std_logic_vector(15 downto 0);
    signal reg_arr_4 : std_logic_vector(15 downto 0);
    signal reg_arr_5 : std_logic_vector(15 downto 0);
    signal reg_arr_6 : std_logic_vector(15 downto 0);
    signal reg_arr_7 : std_logic_vector(15 downto 0);
    signal reg_arr_8 : std_logic_vector(15 downto 0);
    signal reg_arr_9 : std_logic_vector(15 downto 0);
    signal reg_arr_10 : std_logic_vector(15 downto 0);
    signal reg_arr_11 : std_logic_vector(15 downto 0);
    signal reg_arr_12 : std_logic_vector(15 downto 0);
    signal reg_arr_13 : std_logic_vector(15 downto 0);
    signal reg_arr_14 : std_logic_vector(15 downto 0);
    signal reg_arr_15 : std_logic_vector(15 downto 0);
    signal enable_reg : std_logic_vector(15 downto 0);

    signal something_into_regs : std_ulogic;

    attribute chip_pin of out_reg_1 : signal is "E21";
    attribute chip_pin of out_src1 : signal is "E22";
    attribute chip_pin of out_reg_2 : signal is "E25";
    attribute chip_pin of out_src2 : signal is "E24";
    attribute chip_pin of out_alu_out : signal is "G21,G22,G20,H21";

    attribute chip_pin of led_arr : signal is "H15,G16,G15,F15,H17,J16,H16,J15,G17,J17,H19,J19,E18,F18,F21,E19,F19,G19";

begin
    -- Components.
    mem : cscie93.memory_controller port map (
                                                 clk50mhz => clk50mhz,
                                                 mem_addr => "00000" & my_mem_addr,
                                                 mem_data_write => my_mem_data_write,
                                                 mem_rw => my_mem_rw,
                                                 mem_sixteenbit => '1',
                                                 mem_thirtytwobit => '0',
                                                 mem_addressready => my_mem_addressready,
                                                 mem_reset => not(my_mem_reset),
                                                 ps2_clk => ps2_clk,
                                                 ps2_data => ps2_data,
                                                 clock_hold => my_clock_hold,
                                                 clock_step => my_clock_step,
                                                 clock_divide_limit => my_clock_divide_limit,
                                                 mem_suspend => my_mem_suspend,
                                                 lcd_en => lcd_en,
                                                 lcd_on => lcd_on,
                                                 lcd_rs => lcd_rs,
                                                 lcd_rw => lcd_rw,
                                                 lcd_db => lcd_db,
                                                 mem_data_read => my_mem_data_read,
                                                 mem_dataready_inv => my_mem_dataready_inv,
                                                 sysclk1 => sysclk1,
                                                 sysclk2 => sysclk2,
                                                 rs232_rxd => rs232_rxd,
                                                 rs232_txd => rs232_txd,
                                                 rs232_cts => rs232_cts,
                                                 sram_dq => sram_dq,
                                                 sram_ce_N => sram_ce_N,
                                                 sram_oe_N => sram_oe_N,
                                                 sram_we_N => sram_we_N,
                                                 sram_ub_N => sram_ub_N,
                                                 sram_lb_N => sram_lb_N,
                                                 serial_character_ready => my_serial_character_ready,
                                                 ps2_character_ready => my_ps2_character_ready
                                             );

    -- PC + IR
    pc_increment : adder_16bit port map (a => counter,
                                         b => "0000000000000010",
                                         c => mux_counter);

    with beq_or_jump & eq select
        next_counter <= src1_out when "011",
                        std_logic_vector(unsigned(src2_out) + 1) when "100",
                        std_logic_vector(unsigned(src2_out) + 1) when "101",
                        mux_counter when others;

    with current_state select
        pc_write <= '1' when OpALUadd | OpALUlog | OpShiftLeft | OpShiftRight | OpALUlui | OpALUaddi | OpBEQ | OpMemInstr | OpJUMP,
                    '0' when others;

    pc : regstd16 port map ( clk => sysclk1,
                             en => pc_write,
                             reset => not(my_pc_reset),
                             d => next_counter,
                             q => counter
                         );

    ir : regstd16 port map ( clk => sysclk1,
                             en => ir_write,
                             reset => not(my_pc_reset),
                             d => my_mem_data_read(15 downto 0),
                             q => current_instr);

    -- GPRs
    reg_arr : work.reg_arr_16bit port map ( clk => sysclk1,
                                            en => reg_write,
                                            reset => not(my_mem_reset),
                                            data => data_to_reg_arr,
                                            reg_w_addr => src1,
                                            reg_a_addr => src1,
                                            reg_b_addr => src2,
                                            reg_a => src1_out,
                                            reg_b => src2_out,

                                       -- Debug
                                            debug_0 => reg_arr_0,
                                            debug_1 => reg_arr_1,
                                            debug_2 => reg_arr_2,
                                            debug_3 => reg_arr_3,
                                            debug_4 => reg_arr_4,
                                            debug_5 => reg_arr_5,
                                            debug_6 => reg_arr_6,
                                            debug_7 => reg_arr_7,
                                            debug_8 => reg_arr_8,
                                            debug_9 => reg_arr_9,
                                            debug_10 => reg_arr_10,
                                            debug_11 => reg_arr_11,
                                            debug_12 => reg_arr_12,
                                            debug_13 => reg_arr_13,
                                            debug_14 => reg_arr_14,
                                            debug_15 => reg_arr_15,
                                            debug_enable => enable_reg
                                        );

    src1 <= current_instr(11 downto 8);
    src2 <= current_instr(7 downto 4);

    -- ALU
    with current_state select
        mux_func_0 <= '0' when OpALUlui | OpALUaddi,
                      current_instr(0) when others;

    with current_state select
        mux_func_1 <= '0' when OpALUlui | OpALUaddi,
                      current_instr(1) when others;

    with current_state select
        mux_func_2 <= '0' when OpALUlui | OpALUaddi,
                      current_instr(2) when others;

    with current_state select
        mux_func_3 <= '0' when OpALUlui | OpALUaddi,
                      current_instr(3) when others;

    alu : work.alu port map ( a => mux_src1,
                              b => mux_src2,
                              x_3 => mux_func_3,
                              x_2 => mux_func_2,
                              x_1 => mux_func_1,
                              x_0 => mux_func_0,
                              op_0 => add_or_log,
                              eq => eq,
                              f_out => alu_out
                          );

    -- Barrel shifter
    bs : barrel_shifter_16bit port map (
                                           input => src1_out,
                                           shift => src2_out,
                                           direction => shift_direction,
                                           output => shift_out
                                       );

    -- Sequencer.
    sequencer : process is
        variable next_state : CPUState;
        variable process_alu_or_reg_to_mem : std_ulogic;
        variable process_ir_comms : std_ulogic := '0';
        variable process_ir_write : std_ulogic := '0';
        variable process_mem_addr_line : std_ulogic := '1';
        variable process_mem_rw : std_ulogic := '0';
        variable process_write_to_gpr : std_ulogic := '0';
        variable process_reg_write : std_ulogic := '0';
    begin
        wait until falling_edge(sysclk1);
        case current_state is
            -- Mem handshake.
            when R_Step1 => 
                if my_mem_dataready_inv = '0' then
                    next_state := R_Step1;
                else
                    next_state := R_Step2;
                end if;

            when R_Step2 =>
                next_state := R_Step3;

            when R_Step3 =>
                next_state := R_Step4_5;

            when R_Step4_5 =>
                if my_mem_dataready_inv = '1' then
                    next_state := R_Step4_5;
                else
                    next_state := R_Step6;
                end if;

            when R_Step6 =>
                process_mem_addr_line := '0';
                if process_ir_comms = '1' then
                    process_ir_write := '1';
                    next_state := R_Step8;
                else
                    if process_write_to_gpr = '1' then
                        process_reg_write := '1';
                        next_state := R_Step8;
                    else
                        next_state := R_Step8;
                    end if;
                end if;

            when R_Step8 =>
                process_ir_write := '0';
                process_reg_write := '0';
                process_write_to_gpr := '0';
                if process_ir_comms = '1' then
                    process_ir_comms := '0';
                    case current_instr(15 downto 12) is
                        when "1000" => 
                            next_state := OpALUadd;

                        when "1001" =>
                            next_state := OpALUlog;

                        when "0001" =>
                            next_state := OpMemInstr;

                        when "0010" =>
                            next_state := OpBEQ;

                        when "0011" =>
                            next_state := OpJUMP;

                        when "0100" =>
                            next_state := OpShiftLeft;

                        when "0101" =>
                            next_state := OpShiftRight;

                        when "0000" =>
                            next_state := OpALUlui;

                        when "1010" =>
                            next_state := OpALUaddi;

                        when others =>
                            next_state := ErrorState;
                    end case;
                else
                    next_state := ReadMemInstr;
                end if;

            when W_Step1 =>
                if my_mem_dataready_inv = '0' then
                    next_state := W_Step1;
                else
                    next_state := W_Step2;
                end if;

            when W_Step2 =>
                next_state := W_Step3;

            when W_Step3 =>
                next_state := W_Step4_5;

            when W_Step4_5 =>
                if my_mem_dataready_inv = '1' then
                    next_state := W_Step4_5;
                else
                    next_state := W_Step7_8_9;
                end if;

            when W_Step7_8_9 =>
                if my_mem_dataready_inv = '0' then
                    next_state := W_Step7_8_9;
                else
                    next_state := ReadMemInstr;
                end if;

            -- Other CPU states
            when IDLE =>
                next_state := ReadMemInstr;

            when ReadMemInstr =>
                process_mem_rw := '0';
                process_mem_addr_line := '1';
                process_alu_or_reg_to_mem := '0';
                process_ir_comms := '1';
                next_state := R_Step1;

            when OpALUadd => 
                next_state := ReadMemInstr;

            when OpMemInstr =>
                process_alu_or_reg_to_mem := '1';
                case current_instr(3 downto 0) is
                    when "0001" =>
                        process_mem_rw := '1';
                        next_state := W_Step1;
                    when "0000" =>
                        process_mem_rw := '0';
                        process_write_to_gpr := '1';
                        next_state := R_Step1;
                    when others =>
                        next_state := ReadMemInstr;
                end case;

            when OpShiftLeft =>
                next_state := ReadMemInstr;

            when OpShiftRight =>
                next_state := ReadMemInstr;

            when OpALUlui =>
                next_state := ReadMemInstr;

            when OpALUaddi =>
                next_state := ReadMemInstr;

            when OpBEQ =>
                next_state := ReadMemInstr;

            when OpJUMP =>
                next_state := ReadMemInstr;

            when ErrorState =>
                next_state := ErrorState;

            when others =>
                next_state := ReadMemInstr;
        end case;

        alu_or_reg_to_mem <= process_alu_or_reg_to_mem;
        ir_write <= process_ir_write;
        my_mem_rw <= process_mem_rw;
        mem_write_to_reg <= process_reg_write;
        mem_addr_line <= process_mem_addr_line;
        current_state <= next_state;

    end process sequencer;

    -- Debug.
    hex7 : hexDigit port map ( encoding => debug_current_state_asVector_1, 
                               digit => debug_current_state(27 downto 21));

    hex6 : hexDigit port map ( encoding => debug_current_state_asVector_2, 
                               digit => debug_current_state(20 downto 14));

    hex5 : hexDigit port map ( encoding => "000" & my_serial_character_ready, 
                               digit => debug_current_state(13 downto 7));

    hex4 : hexDigit port map ( encoding => "000" & ir_write,
                               digit => debug_current_state(6 downto 0));

    hex3 : hexDigit port map (encoding => hex4bank_input(15 downto 12),
                              digit => hex4bank_high(13 downto 7));

    hex2 : hexDigit port map (encoding => hex4bank_input(11 downto 8),
                              digit => hex4bank_high(6 downto 0));

    hex1 : hexDigit port map (encoding => hex4bank_input(7 downto 4),
                              digit => hex4bank_low(13 downto 7));

    hex0 : hexDigit port map (encoding => hex4bank_input(3 downto 0),
                              digit => hex4bank_low(6 downto 0));

    with debug_hexDisplay & switch_arr select
        hex4bank_input <= my_mem_addr when "0000000000000000",
                          current_instr(15 downto 0) when "1000000000000000",
                          "0" & counter(15 downto 1) when "1000000000000001",
                          alu_out when "1000000000000010",
                          src1_out when "1000000000000100",
                          src2_out when "1000000000001000",
                          data_to_reg_arr when "1000000000010000",
                          my_mem_data_read(15 downto 0) when "1000000000100000",
                          shift_out(15 downto 0) when "1000000001000000",
                          immed_trans when "1000000010000000",
                          current_instr when others;

    something_into_regs <= or_reduce(data_to_reg_arr);

    with debug_hexDisplay & switch_arr select
        led_arr <= my_mem_rw & something_into_regs & reg_arr_0 when "0000000000000000",
                   my_mem_rw & something_into_regs & reg_arr_1 when "0000000000000001",
                   my_mem_rw & something_into_regs & reg_arr_2 when "0000000000000010",
                   my_mem_rw & something_into_regs & reg_arr_3 when "0000000000000100",
                   my_mem_rw & something_into_regs & reg_arr_4 when "0000000000001000",
                   my_mem_rw & something_into_regs & reg_arr_5 when "0000000000010000",
                   my_mem_rw & something_into_regs & reg_arr_6 when "0000000000100000",
                   my_mem_rw & something_into_regs & reg_arr_7 when "0000000001000000",
                   my_mem_rw & something_into_regs & reg_arr_8 when "0000000010000000",
                   my_mem_rw & something_into_regs & reg_arr_9 when "0000000100000000",
                   my_mem_rw & something_into_regs & reg_arr_10 when "0000001000000000",
                   my_mem_rw & something_into_regs & reg_arr_11 when "0000010000000000",
                   my_mem_rw & something_into_regs & reg_arr_12 when "0000100000000000",
                   my_mem_rw & something_into_regs & reg_arr_13 when "0001000000000000",
                   my_mem_rw & something_into_regs & reg_arr_14 when "0010000000000000",
                   my_mem_rw & something_into_regs & reg_arr_15 when "0100000000000000",
                   my_mem_rw & something_into_regs & enable_reg when "0000000000000011",
                   my_mem_rw & something_into_regs & "00" & pc_write & beq_or_jump(1 downto 0) & mem_addr_line & alu_or_reg_to_mem & select_mem_shift_jump_alu(1 downto 0) & reg_write & addi_lui_or_noop & add_or_log & addi_or_lui & eq & shift_direction & ir_write when others;

    out_reg_1 <= or_reduce(src1_out);
    out_src1 <= or_reduce(src1);
    out_reg_2 <= or_reduce(src2_out);
    out_src2 <= or_reduce(src2);
    out_alu_out <= alu_out(3 downto 0);

    with current_state select
        debug_current_state_asVector_1 <= x"0" when ReadMemInstr,
                                          x"1" when OpALUadd,
                                          x"2" when OpALUlog,
                                          x"3" when OpMemInstr,
                                          x"4" when OpShiftRight | OpShiftLeft,
                                          x"5" when OpALUlui,
                                          x"6" when OpALUaddi,
                                          x"7" when OpBEQ,
                                          x"8" when OpJUMP,
                                          x"9" when IDLE,
                                          x"f" when ErrorState,
                                          x"a" when others;

    with current_state select
        debug_current_state_asVector_2 <= x"0" when R_Step1,
                                          x"1" when R_Step2,
                                          x"2" when R_Step3,
                                          x"3" when R_Step4_5,
                                          x"4" when R_Step6,
                                          x"5" when R_Step8,
                                          x"6" when W_Step1,
                                          x"7" when W_Step2,
                                          x"8" when W_Step3,
                                          x"9" when W_Step4_5,
                                          x"f" when ErrorState,
                                          x"a" when others;

        -- Combinational.
    with current_state select
        beq_or_jump <= "10" when OpJUMP,
                       "01" when OpBEQ,
                       "00" when others;

    with current_state select
        state_reg_write <= '1' when OpALUadd | OpALUlog | OpALUlui | OpALUaddi | OpShiftLeft | OpShiftRight | OpJUMP,
                           '0' when others;

    reg_write <= or_reduce(state_reg_write & mem_write_to_reg);

    with current_state select
        select_mem_shift_jump_alu <= "10" when OpShiftLeft | OpShiftRight,
                                     "11" when OpJUMP,
                                     "01" when R_Step1 | R_Step2 | R_Step4_5 | R_Step6 | R_Step8,
                                     "00" when others;

    with current_state select
        shift_direction <= '1' when OpShiftLeft,
                           '0' when others;

    with current_state select
        add_or_log <= '0' when OpALUadd | OpALUlui | OpALUaddi,
                      '1' when others;

    with select_mem_shift_jump_alu select
        data_to_reg_arr <=  counter when "11",
                            shift_out when "10",
                            my_mem_data_read(15 downto 0) when "01",
                            alu_out when "00";

    with alu_or_reg_to_mem select
        my_mem_data_write <= "0000000000000000" & alu_out when '0',
                             "0000000000000000" & src1_out when others;

    with addi_lui_or_noop select
        mux_src2 <= immed_trans when '1',
                    src2_out when others;

    with current_state select
        addi_lui_or_noop <= '1' when OpALUlui | OpALUaddi,
                            '0' when others;

    with addi_or_lui & beq_or_jump select
        mux_src1 <= "0000000000000000" when "100",
                    "0000000000000000" when "110",
                    "0000000000000000" when "111",
                    "0000000000000000" when "101",
                    "000000000000" & immed_trans(3 downto 0) when "001",
                    src1_out when others;

    with current_state select
        addi_or_lui <= '1' when OpALUlui,
                       '0' when others;

    with addi_or_lui select
        immed_trans <= current_instr(7 downto 0) & "00000000" when '1',
                       "00000000" & current_instr(7 downto 0) when others;

    -- Memory handshake control.
    with mem_addr_line select
        my_mem_addr <= counter when '1',
                       src2_out(14 downto 0) & '0' when others;

    with current_state select
        my_mem_addressready <= '0' when R_Step1 | R_Step2 | R_Step8 | W_Step1 | W_Step2 | W_Step7_8_9,
                               '1' when R_Step3 | R_Step4_5 | R_Step6 | W_Step3 | W_Step4_5,
                               '-' when others;

end architecture dataflow;
