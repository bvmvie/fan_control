library ieee;
use ieee.std_logic_1164.all;

entity fan_control is
	port(
		clk: in std_logic;
		led: out std_logic_vector(7 downto 0);
		fan, g: out std_logic := '0');
end entity;

architecture rtl of fan_control is
begin
	fan <= '1';
	g <= '0';
	led <= "11100111";
end architecture;