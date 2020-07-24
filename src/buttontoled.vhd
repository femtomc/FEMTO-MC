entity buttonToLED is
  port (pb1, pb2: in bit;
        led1, led2: out bit);
end entity buttonToLED;

-- The pushbuttons are active-low (i.e., the signals are normally high and
--      become low when the pushbuttons are pressed).  They *are* debounced.

-- The individual LEDs are illuminated when driven with a high signal.

-- Assign pins as follows on the DE2-70:
--      Signal     Pin       Device
--      led1       PIN_AJ7   LEDR17 leftmost red LED
--      led2       PIN_AD8   LEDR16 second to leftmost red LED
--      pb1        PIN_U29   KEY3 leftmost pushbutton
--      pb2        PIN_U30   KEY2 second to leftmost pushbutton

architecture behav of buttonToLED is
  attribute chip_pin: string;
  attribute chip_pin of led1: signal is "AC17";
  attribute chip_pin of led2: signal is "AA15";
  attribute chip_pin of pb1: signal is "N21";
  attribute chip_pin of pb2: signal is "R24";
begin
  buttonToLED_behavior: process(pb1, pb2) is
  begin
    led1 <= pb1;
    led2 <= pb2;
  end process buttonToLED_behavior;
end architecture behav;