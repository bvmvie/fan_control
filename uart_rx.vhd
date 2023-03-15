library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
	port(
		clk: in std_logic;
		data_out: out std_logic_vector(7 downto 0);
		rx: in std_logic);
end entity;

architecture rtl of uart_rx is
	signal data_count: integer range 0 to 9 := 0;
	signal count: integer range 0 to 2501 := 0;
	type state is (idle, start_bit, data_bit, stop_bit);
	signal suart: state := idle;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			case suart is
				when idle =>
					if rx='0' then
						suart <= start_bit;
					end if;
					data_count <= 0;
					count <= 0;
				when start_bit =>
					count <= count + 1;
					if count = 2499 then
						count <= 0;
						suart <= data_bit;
						data_count <= 0;
					end if;
				when data_bit =>
					count <= count + 1;
					if (count = 2499) and (data_count < 7) then
						data_count <= data_count + 1;
						count <= 0;	
					elsif (data_count >= 7) and (count = 2499) then
						suart <= stop_bit;
						count <= 0;
					end if;
					if (count = 1250) then
						data_out(data_count) <= rx;
					end if;
				when stop_bit =>
					count <= count + 1;
					if (count = 2499) then
						count <= 0;
						data_count <= 0;
						suart <= idle;
					end if;
				when others =>
					count <= 0;
					data_count <= 0;
			end case;
		end if;
	end process;
end architecture;