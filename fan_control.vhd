library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity fan_control is
	port(
		dht11_pin: inout std_logic;
		tx: out std_logic;
		rx: in std_logic;
		fan: out std_logic;
		mode: in std_logic;
		clk: in std_logic); --24Mhz
end entity;

architecture rtl of fan_control is
	signal rx_int: integer range 0 to 15;
	signal data_out: std_logic_vector(7 downto 0);
	signal dht11_data: std_logic_vector(39 downto 0);
	signal fan_mode: integer range 0 to 3;
	signal temp: integer range 0 to 90;
	signal temp1, temp2: integer range 0 to 9;
	signal uart_temp1, uart_temp2: std_logic_vector(7 downto 0);
	
	component dht11 is
		port(
			clk: in std_logic;
			DHT11_pin: inout std_logic; 
			DHT11_data: out std_logic_vector(40-1 downto 0));
	end component;
	
	component uart_tx is
		port(
			clk: in std_logic;
			data0, data1: in std_logic_vector(7 downto 0);
			tx: out std_logic);
	end component;
	
	component uart_rx is
		port(
			clk: in std_logic;
			data_out: out std_logic_vector(7 downto 0);
			rx: in std_logic);
	end component;
	
	component pwm_control is
		port(
			clk: in std_logic;
			fan_mode: in integer range 0 to 3;
			fan: out std_logic);
	end component;
begin
	rx_int <= conv_integer(data_out);
	temp <= conv_integer(dht11_data(23 downto 16));
	temp1 <= temp/10;
	temp2 <= temp - (temp1*10);
	uart_temp1 <= std_logic_vector ("0011" & CONV_STD_LOGIC_VECTOR(temp1,4));
	uart_temp2 <= std_logic_vector ("0011" & CONV_STD_LOGIC_VECTOR(temp2,4));
	
	set_mode: process(clk)
	begin
		if mode = '0' then
			if temp<25 then
				fan_mode <= 0;
			elsif temp<30 then
				fan_mode <= 1;
			elsif temp<35 then
				fan_mode <= 2;
			else
				fan_mode <= 3;
			end if;
		else
			fan_mode <= rx_int;
		end if;
	end process;
	
	dieu_khien_quat: pwm_control port map(clk, fan_mode, fan);
	doc_dht11: dht11 port map(clk, dht11_pin, dht11_data);
	truyen_uart: uart_tx port map(clk,uart_temp1, uart_temp2, tx);
	nhan_uart: uart_rx port map(clk, data_out, rx);
end architecture;