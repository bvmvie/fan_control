library ieee;
use ieee.std_logic_1164.all;

entity pwm_control is
	port(
		clk: in std_logic;
		fan_mode: in integer range 0 to 3;
		fan: out std_logic);
end entity;

architecture rtl of pwm_control is
	signal max_count: integer range 0 to 1000 := 0;
	signal count: integer range 0 to 999 := 0;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			case fan_mode is
				when 0 => max_count <= 0;
				when 1 => max_count <= 300;
				when 2 => max_count <= 700;
				when 3 => max_count <= 1000;
				when others => max_count <= 0;
			end case;
			if count < max_count then
				fan <= '1';
			else
				fan <= '0';
			end if;
			count <= count + 1;
		end if;	
	end process;
end architecture;