library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hexDigit is
port (
	encoding: in std_ulogic_vector(3 downto 0);
	digit: out std_ulogic_vector(6 downto 0)
	);
end entity hexDigit;

architecture behav of hexDigit is
begin
	process (encoding) is 
	begin
		if encoding = "0000" then
			digit <= "1000000";
		elsif encoding = "0001" then
			digit <= "1111001";
		elsif encoding = "0010" then
			digit <= "0100100";
		elsif encoding = "0011" then
			digit <= "0110000"; 
		elsif encoding = "0100" then
			digit <= "0011001";
		elsif encoding = "0101" then
			digit <= "0010010";
		elsif encoding = "0110" then
			digit <= "0000010";
		elsif encoding = "0111" then
			digit <= "1111000";
		elsif encoding = "1000" then
			digit <= "0000000";
		elsif encoding = "1001" then
			digit <= "0011000";
		elsif encoding = "1010" then
			digit <= "0001000";
		elsif encoding = "1011" then
			digit <= "0000011";
		elsif encoding = "1100" then
			digit <= "1000110";
		elsif encoding = "1101" then
			digit <= "0100001";
		elsif encoding = "1110" then
			digit <= "0000110";
		else
			digit <= "0001110";
		end if;
	end process;
end architecture behav;
