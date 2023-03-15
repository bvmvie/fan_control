library ieee;
use ieee.std_logic_1164.all;

entity fan_control_testbench is
end entity;

architecture rlt of fan_control_testbench is
	component dht11
		port(
        clk : in std_logic ;
        DHT11_pin: inout std_logic; 
        DHT11_data: out std_logic_vector(40-1 downto 0)); 
	end component;
	
	signal clk : std_logic := '0' ;
	signal DHT11_pin: std_logic := '0'; 
   signal DHT11_data: std_logic_vector(40-1 downto 0) := "0000000000000000000000000000000000000000";
begin
	gan: dht11 port map(clk, dht11_pin, dht11_data);
	clk_gen: process
	begin
		wait for 10 ns; clk <= not clk;
	end process;
	sim: process
	begin
		wait for 18 ms;
		
	end process;
end architecture;