library ieee;
use ieee.std_logic_1164.all;

entity DHT11 is
    port(
        clk : in std_logic ;
        DHT11_pin: inout std_logic; 
        DHT11_data: out std_logic_vector(39 downto 0)); 
end entity;

architecture get_data of DHT11 is
	constant delay_18_ms: positive := 18*10**6/42+1; -- 1 xung clk la 42ns
	constant time_80_us: positive := 80*10**3/42+1; 
	constant time_30_us: positive := 30*10**3/42+1;
	constant max_delay: positive := 40000000;
	signal edge_check : std_logic_vector(0 to 2); 
	type state_type is (reset,start,cho_phan_hoi_1,cho_phan_hoi_2,cho_phan_hoi_3,start_DHT11,nhan_bit,end_DHT11);
	signal state : state_type; 
	signal delay_counter : natural range 0 to max_delay; 
	signal data_out : std_logic_vector (39 downto 0);
	signal bus_rising_edge, bus_falling_edge : boolean;
	signal number_bit : natural range 0 to 40; 
	signal oe: std_logic;  -- chon che do gui du lieu cho DHT11 hay nhan du lieu tu DHT11
	 
begin
	process(clk)
	begin
		if rising_edge(clk) then
			edge_check <= to_x01(DHT11_pin)&edge_check(0 to 1);
      end if;
   end process;

   bus_rising_edge <= edge_check(1 to 2) = "10";
   bus_falling_edge <= edge_check(1 to 2) = "01";

   process (clk) begin
		if rising_edge(clk) then
			case(state) is
				when reset =>
					if delay_counter = 0 then 
						number_bit <= 40;
						oe <= '1'; 
						delay_counter <= delay_18_ms;
						state <= start; 
				   else
						delay_counter <= delay_counter - 1;                    
               end if;     
				when start =>  -- gui tin hieu '1' trong 18ms de kich hoat DHT11
				  if delay_counter = 0 then 
						oe <= '0'; 
						state <= cho_phan_hoi_1;
				  else 
						delay_counter <= delay_counter -1;
				  end if ;
				when cho_phan_hoi_1 => -- cho phan hoi tu DHT11
				  if bus_falling_edge then  
						state <= cho_phan_hoi_2;
				  end if; 
				when cho_phan_hoi_2 => -- cho phan hoi tu DHT11
				  if bus_rising_edge then 
						state <= cho_phan_hoi_3;
				  end if;
				when cho_phan_hoi_3 => -- cho phan hoi tu DHT11 
				  if bus_falling_edge then 
						state <= start_DHT11;
				  end if;
				when start_DHT11 => -- 	chuan bi cho qua trinh doc du lieu                
				  if bus_rising_edge then
						delay_counter <= 0;
						state <= nhan_bit;
				  elsif number_bit = 0 then 
						state <= end_DHT11;
				  end if;
				when nhan_bit => -- nhan 1 bit du DHT11
				  if bus_falling_edge then
						number_bit <= number_bit - 1;
						if (delay_counter < time_30_us) then -- chan data la '1' trong khoang 26-28us thi bit nhan duoc la '0'
							 data_out <= data_out(38 downto 0) & '0';
						elsif (delay_counter < time_80_us) then -- chan data la '1' trong khoang 70us thi bit nhan duoc la '1' 
							 data_out <= data_out(38 downto 0) & '1'; 
						end if; 
						state <= start_DHT11; 
				  end if;
				  delay_counter <= delay_counter + 1;
				when end_DHT11 =>  
				  if delay_counter = 0 then 
						delay_counter <= max_delay;
						state <= reset;
				  else 
						DHT11_data <= data_out;
						delay_counter <= delay_counter - 1; 
				  end if;
            end case;
        end if; 
    end process regis_state; 
    DHT11_pin <= '0' when oe ='1' else 'Z';
end architecture;