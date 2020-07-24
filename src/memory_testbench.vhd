library ieee;
use ieee.std_logic_1164.all;
library cscie93;
use work.femto_mc.all;

-- Submission.
entity memory_testbench is
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

             debug_current_state : out std_logic_vector(6 downto 0);
             debug_hexDisplay : in std_ulogic := '0'
         );
end;

architecture default of memory_testbench is
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

    attribute chip_pin of debug_current_state : signal is "AA14,AG18,AF17,AH17,AG17,AE17,AD17";
    -- attribute chip_pin of debug_hexDisplay : signal is "AB28";

    attribute chip_pin of my_clock_step : signal is "N21";
    attribute chip_pin of my_mem_reset : signal is "R24";
    attribute chip_pin of my_mem_suspend : signal is "Y23";
    attribute chip_pin of my_clock_hold : signal is "Y24";

    signal sysclk1 : std_ulogic;
    signal sysclk2 : std_ulogic;

    signal my_mem_addr : std_ulogic_vector(15 downto 0);
    signal my_mem_data_write : std_ulogic_vector(31 downto 0);
    signal my_mem_rw : std_ulogic;
    signal my_mem_addressready : std_ulogic;
    signal my_clock_divide_limit : std_logic_vector(19 downto 0) := "11111111111111111110";
    signal my_mem_data_read : std_logic_vector(31 downto 0);
    signal my_mem_dataready_inv : std_ulogic;
    signal my_serial_character_ready : std_ulogic;
    signal my_ps2_character_ready : std_ulogic;

    signal reg_value : std_logic_vector(15 downto 0);
    signal hex4bank_input : std_logic_vector(15 downto 0);
    type MemState is (R_Step1, R_Step2, R_Step3, R_Step4_5, R_Step6, R_Step8, W_Step1, W_Step2, W_Step3, W_Step4_5,W_Step7_8_9);

    signal current_state : MemState := R_Step1;
    signal reg_write : std_ulogic := '0';
    signal debug_current_state_asVector : std_logic_vector(3 downto 0);

begin

    mem : cscie93.memory_controller port map (
                                                 clk50mhz => clk50mhz,
                                                 mem_addr => to_stdlogicvector("00000" & my_mem_addr),
                                                 mem_data_write => to_stdlogicvector(my_mem_data_write),
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

    reg : regstd16 port map (clk => sysclk1,
                             en => reg_write,
                             reset => '0',
                             d => my_mem_data_read(15 downto 0),
                             q => reg_value);

    hex3 : hexDigit port map (encoding => hex4bank_input(15 downto 12),
                              digit => hex4bank_high(13 downto 7));

    hex2 : hexDigit port map (encoding => hex4bank_input(11 downto 8),
                              digit => hex4bank_high(6 downto 0));

    hex1 : hexDigit port map (encoding => hex4bank_input(7 downto 4),
                              digit => hex4bank_low(13 downto 7));

    hex0 : hexDigit port map (encoding => hex4bank_input(3 downto 0),
                              digit => hex4bank_low(6 downto 0));

    hex4bank_input <= reg_value when debug_hexDisplay = '0' else to_stdlogicvector(my_mem_addr(15 downto 0));


    -- Debug.
    hex7 : hexDigit port map ( encoding => debug_current_state_asVector, digit => debug_current_state);

    with current_state select
        debug_current_state_asVector <=
       x"0" when R_Step1,
       x"1" when R_Step2,
       x"2" when R_Step3,
       x"3" when R_Step4_5,
       x"4" when R_Step6,
       x"5" when R_Step8,
       x"6" when W_Step1,
       x"7" when W_Step2,
       x"8" when W_Step3,
       x"9" when W_Step4_5,
       x"a" when others;

       fsm : process is
           variable next_state : MemState;
       begin
           wait until falling_edge(sysclk1);
           case current_state is
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
                   next_state := R_Step8;
               when R_Step8 =>
                   next_state := W_Step1;
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
                       next_State := R_Step1;
                   end if;
           end case;

           current_state <= next_state;
       end process fsm;

       -- Combinational.
       with current_state select
           my_mem_addr <= X"1dea" when R_Step2 | R_Step3 | R_Step4_5,
                          X"0b0e" when W_Step2 | W_Step3 | W_Step4_5,
                          X"0000" when others;

       with current_state select
           my_mem_addressready <= '0' when R_Step1 | R_Step2 | R_Step8 | W_Step1 | W_Step2 | W_Step7_8_9,
                                  '1' when R_Step3 | R_Step4_5 | R_Step6 | W_Step3 | W_Step4_5,
                                  '-' when others;

       with current_state select
           my_mem_rw <= '1' when W_Step2 | W_Step3 | W_Step4_5,
                        '0' when R_Step2 | R_Step3 | R_Step4_5,
                        '-' when others;

       with current_state select
           reg_write <= '1' when R_Step6,
                        '0' when others;

end architecture default;

