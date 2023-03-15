library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
	port(
		clk: in std_logic;
		clk_9600: out std_logic);
end entity;

architecture rtl of clk_div is
	signal count: integer range 0 to 2604 := 0;
	signal temp: std_logic := '0';
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			count <= count + 1;
			if (count = 1250) then
				temp <= not temp;
				count <= 0;
			end if;
		end if;
	end process;
	clk_9600 <= temp;
end architecture;