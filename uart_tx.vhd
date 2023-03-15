library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
	port(
		clk: in std_logic;
		data0, data1: in std_logic_vector;
		tx: out std_logic);
end entity;

architecture rtl of uart_tx is
	type state_uart is (idle, start_bit, data_bit, stop_bit);
	signal clk_9600: std_logic;
	signal data_count: integer range 0 to 9 := 0;
	signal delay: integer range 0 to 200000 := 0;
	signal switch_data: integer range 0 to 3 := 0;
	signal suart: state_uart := idle;
	signal data: std_logic_vector(7 downto 0);
	component clk_div is
		port(
			clk: in std_logic;
			clk_9600: out std_logic);
	end component;
begin
	chia_tan: clk_div port map(clk, clk_9600);
	process(clk_9600)
	begin
		if (rising_edge(clk_9600)) then
			case suart is
				when idle =>
					if (switch_data=0) then
						data <= data0;
					elsif (switch_data=1) then
						data <= data1;
					else
						data <= "00100000";
					end if;
					data_count <= 0;
					tx <= '1';
					suart <= start_bit;
				when start_bit =>
					if switch_data = 3 then
						switch_data <= 0;
					else
						switch_data <= switch_data +1;
					end if;
					tx <= '0';
					suart <= data_bit;
				when data_bit =>
					tx <= data(data_count);
					data_count <= data_count + 1;
					if (data_count>=7) then
						suart <= stop_bit;
					end if;
				when stop_bit =>
					tx <= '1';
					delay <= delay + 1;
					if (delay = 2000) then
						delay <= 0;
						data_count <= 0;
						suart <= idle;
					end if;
				when others =>
					data_count <= 0;
			end case;
		end if;	
	end process;
end architecture;
	