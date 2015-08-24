library ieee;
use ieee.std_logic_1164.all;

entity reg_file is
	port(
		clk		:	in	std_logic;
		reset		:	in	std_logic;
		wr_en		:	in	std_logic;
		r_add_1	:	in std_logic_vector(4 downto 0);
		r_add_2	:	in	std_logic_vector(4 downto 0);
		w_add		:	in	std_logic_vector(4 downto 0);
		w_valid	:	in std_logic;
		w_port	:	in std_logic_vector(1 downto 0);
		w_info	:	in	std_logic_vector(47 downto 0);
		r_data_1	:	out	std_logic_vector(50 downto 0);
		r_data_2	:	out	std_logic_vector(50 downto 0));
end reg_file;



architecture arch of reg_file is
	constant w : natural := 5;
	constant b : natural := 51;
	
	type reg_file_type is array(2**w - 1 downto 0) of std_logic_vector(b - 1 downto 0);
	
	signal array_reg 		: reg_file_type;
	signal array_next		:	reg_file_type;
	signal en				:	std_logic_vector(2**w - 1 downto 0);
	signal w_data			:	std_logic_vector(50 downto 0);
	

begin
	w_data(50) <= w_valid;
	w_data(49 downto 2) <= w_info;
	w_data(1 downto 0) <= w_port;

--register
	process(clk,reset)
	begin
		if(reset = '1') then	
			array_reg(31) <= (others => '0');
			array_reg(30) <= (others => '0');
			array_reg(29) <= (others => '0');
			array_reg(28) <= (others => '0');
			array_reg(27) <= (others => '0');
			array_reg(26) <= (others => '0');
			array_reg(25) <= (others => '0');
			array_reg(24) <= (others => '0');
			array_reg(23) <= (others => '0');
			array_reg(22) <= (others => '0');
			array_reg(21) <= (others => '0');
			array_reg(20) <= (others => '0');
			array_reg(19) <= (others => '0');
			array_reg(18) <= (others => '0');
			array_reg(17) <= (others => '0');
			array_reg(16) <= (others => '0');
			array_reg(15) <= (others => '0');
			array_reg(14) <= (others => '0');
			array_reg(13) <= (others => '0');
			array_reg(12) <= (others => '0');
			array_reg(11) <= (others => '0');
			array_reg(19) <= (others => '0');
			array_reg(9) <= (others => '0');
			array_reg(8) <= (others => '0');
			array_reg(7) <= (others => '0');
			array_reg(6) <= (others => '0');
			array_reg(5) <= (others => '0');
			array_reg(4) <= (others => '0');
			array_reg(3) <= (others => '0');
			array_reg(2) <= (others => '0');
			array_reg(1) <= (others => '0');
			array_reg(0) <= (others => '0');
			
		elsif (clk'event and clk = '1') then
			array_reg(31) <= (others => '0');
			array_reg(31) <= 	array_next(31);
			array_reg(30) <= 	array_next(30);
			array_reg(29) <=  array_next(29);
			array_reg(28) <=  array_next(28);
			array_reg(27) <=  array_next(27);
			array_reg(26) <=  array_next(26);
			array_reg(25) <=  array_next(25);
			array_reg(24) <=  array_next(24);
			array_reg(23) <=  array_next(23);
			array_reg(22) <=  array_next(22);
			array_reg(21) <=  array_next(21);
			array_reg(20) <=  array_next(20);
			array_reg(19) <=  array_next(19);
			array_reg(18) <=  array_next(18);
			array_reg(17) <=  array_next(17);
			array_reg(16) <=  array_next(16);
			array_reg(15) <=  array_next(15);
			array_reg(14) <=  array_next(14);
			array_reg(13) <=  array_next(13);
			array_reg(12) <=  array_next(12);
			array_reg(11) <=  array_next(11);
			array_reg(10) <=  array_next(10);
			array_reg(9) <=  array_next(9);
			array_reg(8) <=  array_next(8);
			array_reg(7) <=  array_next(7);
			array_reg(6) <=  array_next(6);
			array_reg(5) <=  array_next(5);
			array_reg(4) <=  array_next(4);
			array_reg(3) <=  array_next(3);
			array_reg(2) <=  array_next(2);
			array_reg(1) <=  array_next(1);
			array_reg(0) <=  array_next(0);
		end if;
	end process;
	
	
	process(array_reg,en,w_data)
	begin
		array_next(31) <= array_reg(31);
		array_next(30) <= array_reg(30);
		array_next(29) <= array_reg(29);
		array_next(28) <= array_reg(28);
		array_next(27) <= array_reg(27);
		array_next(26) <= array_reg(26);
		array_next(25) <= array_reg(25);
		array_next(24) <= array_reg(24);
		array_next(23) <= array_reg(23);
		array_next(22) <= array_reg(22);
		array_next(21) <= array_reg(21);
		array_next(20) <= array_reg(20);
		array_next(19) <= array_reg(19);
		array_next(18) <= array_reg(18);
		array_next(17) <= array_reg(17);
		array_next(16) <= array_reg(16);
		array_next(15) <= array_reg(15);
		array_next(14) <= array_reg(14);
		array_next(13) <= array_reg(13);
		array_next(12) <= array_reg(12);
		array_next(11) <= array_reg(11);
		array_next(10) <= array_reg(10);
		array_next(9) <= array_reg(9);
		array_next(8) <= array_reg(8);
		array_next(7) <= array_reg(7);
		array_next(6) <= array_reg(6);
		array_next(5) <= array_reg(5);
		array_next(4) <= array_reg(4);
		array_next(3) <= array_reg(3);
		array_next(2) <= array_reg(2);
		array_next(1) <= array_reg(1);
		array_next(0) <= array_reg(0);
		
		if en(31) = '1' then
			array_next(31) <= w_data;
		end if;
		
		if en(30) = '1' then
			array_next(30) <= w_data;
		end if;
		
		if en(29) = '1' then
			array_next(29) <= w_data;
		end if;
		
		if en(28) = '1' then
			array_next(28) <= w_data;
		end if;
		
		if en(27) = '1' then
			array_next(27) <= w_data;
		end if;
		
		if en(26) = '1' then
			array_next(26) <= w_data;
		end if;
		
		if en(25) = '1' then
			array_next(25) <= w_data;
		end if;
		
		if en(24) = '1' then
			array_next(24) <= w_data;
		end if;
		
		if en(23) = '1' then
			array_next(23) <= w_data;
		end if;
		
		if en(22) = '1' then
			array_next(22) <= w_data;
		end if;
		
		if en(21) = '1' then
			array_next(21) <= w_data;
		end if;
		
		if en(20) = '1' then
			array_next(20) <= w_data;
		end if;
		
		if en(19) = '1' then
			array_next(19) <= w_data;
		end if;
		
		if en(18) = '1' then
			array_next(18) <= w_data;
		end if;
		
		if en(17) = '1' then
			array_next(17) <= w_data;
		end if;
		
		if en(16) = '1' then
			array_next(16) <= w_data;
		end if;
		
		if en(15) = '1' then
			array_next(15) <= w_data;
		end if;
		
		if en(14) = '1' then
			array_next(14) <= w_data;
		end if;
		
		if en(13) = '1' then
			array_next(13) <= w_data;
		end if;
		
		if en(12) = '1' then
			array_next(12) <= w_data;
		end if;
		
		if en(11) = '1' then
			array_next(11) <= w_data;
		end if;
		
		if en(10) = '1' then
			array_next(10) <= w_data;
		end if;
		
		if en(9) = '1' then
			array_next(9) <= w_data;
		end if;
		
		if en(8) = '1' then
			array_next(8) <= w_data;
		end if;
		
		if en(7) = '1' then
			array_next(7) <= w_data;
		end if;
		
		if en(6) = '1' then
			array_next(6) <= w_data;
		end if;
		
		if en(5) = '1' then
			array_next(5) <= w_data;
		end if;
		
		if en(4) = '1' then
			array_next(4) <= w_data;
		end if;
		
		if en(3) = '1' then
			array_next(3) <= w_data;
		end if;
		
		if en(2) = '1' then
			array_next(2) <= w_data;
		end if;
		
		if en(1) = '1' then
			array_next(1) <= w_data;
		end if;
		
		if en(0) = '1' then
			array_next(0) <= w_data;
		end if;
	end process;
	
	
	
	process(wr_en,w_add)
	begin
		if(wr_en = '0') then
			en <= (others=>'0');
		else
			case w_add	 is
				when "00000" => en <= "00000000000000000000000000000001";
				when "00001" => en <= "00000000000000000000000000000010";
				when "00010" => en <= "00000000000000000000000000000100";
				when "00011" => en <= "00000000000000000000000000001000";
				when "00100" => en <= "00000000000000000000000000010000";
				when "00101" => en <= "00000000000000000000000000100000";
				when "00110" => en <= "00000000000000000000000001000000";
				when "00111" => en <= "00000000000000000000000010000000";
				when "01000" => en <= "00000000000000000000000100000000";
				when "01001" => en <= "00000000000000000000001000000000";
				when "01010" => en <= "00000000000000000000010000000000";
				when "01011" => en <= "00000000000000000000100000000000";
				when "01100" => en <= "00000000000000000001000000000000";
				when "01101" => en <= "00000000000000000010000000000000";
				when "01110" => en <= "00000000000000000100000000000000";
				when "01111" => en <= "00000000000000001000000000000000";
				when "10000" => en <= "00000000000000010000000000000000";
				when "10001" => en <= "00000000000000100000000000000000";
				when "10010" => en <= "00000000000001000000000000000000";
				when "10011" => en <= "00000000000010000000000000000000";
				when "10100" => en <= "00000000000100000000000000000000";
				when "10101" => en <= "00000000001000000000000000000000";
				when "10110" => en <= "00000000010000000000000000000000";
				when "10111" => en <= "00000000100000000000000000000000";
				when "11000" => en <= "00000001000000000000000000000000";
				when "11001" => en <= "00000010000000000000000000000000";
				when "11010" => en <= "00000100000000000000000000000000";
				when "11011" => en <= "00001000000000000000000000000000";
				when "11100" => en <= "00010000000000000000000000000000";
				when "11101" => en <= "00100000000000000000000000000000";
				when "11110" => en <= "01000000000000000000000000000000";
				when "11111" => en <= "10000000000000000000000000000000";
			end case;
		end if;
	
	end process;

	
-- Read Regs
	process(clk,r_add_1,r_add_2,array_reg)
	begin
		if (clk'event and clk = '1') then
			case r_add_1 is
				 when "11111" => r_data_1 <= array_reg(31);
				 when "11110" => r_data_1 <= array_reg(30);
				 when "11101" => r_data_1 <= array_reg(29);
				 when "11100" => r_data_1 <= array_reg(28);
				 when "11011" => r_data_1 <= array_reg(27);
				 when "11010" => r_data_1 <= array_reg(26);
				 when "11001" => r_data_1 <= array_reg(25);
				 when "11000" => r_data_1 <= array_reg(24);
				 when "10111" => r_data_1 <= array_reg(23);
				 when "10110" => r_data_1 <= array_reg(22);
				 when "10101" => r_data_1 <= array_reg(21);
				 when "10100" => r_data_1 <= array_reg(20);
				 when "10011" => r_data_1 <= array_reg(19);
				 when "10010" => r_data_1 <= array_reg(18);
				 when "10001" => r_data_1 <= array_reg(17);
				 when "10000" => r_data_1 <= array_reg(16);
				 when "01111" => r_data_1 <= array_reg(15);
				 when "01110" => r_data_1 <= array_reg(14);
				 when "01101" => r_data_1 <= array_reg(13);
				 when "01100" => r_data_1 <= array_reg(12);
				 when "01011" => r_data_1 <= array_reg(11);
				 when "01010" => r_data_1 <= array_reg(10);
				 when "01001" => r_data_1 <= array_reg(9);
				 when "01000" => r_data_1 <= array_reg(8);
				 when "00111" => r_data_1 <= array_reg(7);
				 when "00110" => r_data_1 <= array_reg(6);
				 when "00101" => r_data_1 <= array_reg(5);
				 when "00100" => r_data_1 <= array_reg(4);
				 when "00011" => r_data_1 <= array_reg(3);
				 when "00010" => r_data_1 <= array_reg(2);
				 when "00001" => r_data_1 <= array_reg(1);
				 when "00000" => r_data_1 <= array_reg(0);
			end case;
			
			case r_add_2 is
				 when "11111" => r_data_2 <= array_reg(31);
				 when "11110" => r_data_2 <= array_reg(30);
				 when "11101" => r_data_2 <= array_reg(29);
				 when "11100" => r_data_2 <= array_reg(28);
				 when "11011" => r_data_2 <= array_reg(27);
				 when "11010" => r_data_2 <= array_reg(26);
				 when "11001" => r_data_2 <= array_reg(25);
				 when "11000" => r_data_2 <= array_reg(24);
				 when "10111" => r_data_2 <= array_reg(23);
				 when "10110" => r_data_2 <= array_reg(22);
				 when "10101" => r_data_2 <= array_reg(21);
				 when "10100" => r_data_2 <= array_reg(20);
				 when "10011" => r_data_2 <= array_reg(19);
				 when "10010" => r_data_2 <= array_reg(18);
				 when "10001" => r_data_2 <= array_reg(17);
				 when "10000" => r_data_2 <= array_reg(16);
				 when "01111" => r_data_2 <= array_reg(15);
				 when "01110" => r_data_2 <= array_reg(14);
				 when "01101" => r_data_2 <= array_reg(13);
				 when "01100" => r_data_2 <= array_reg(12);
				 when "01011" => r_data_2 <= array_reg(11);
				 when "01010" => r_data_2 <= array_reg(10);
				 when "01001" => r_data_2 <= array_reg(9);
				 when "01000" => r_data_2 <= array_reg(8);
				 when "00111" => r_data_2 <= array_reg(7);
				 when "00110" => r_data_2 <= array_reg(6);
				 when "00101" => r_data_2 <= array_reg(5);
				 when "00100" => r_data_2 <= array_reg(4);
				 when "00011" => r_data_2 <= array_reg(3);
				 when "00010" => r_data_2 <= array_reg(2);
				 when "00001" => r_data_2 <= array_reg(1);
				 when "00000" => r_data_2 <= array_reg(0);
			end case;
		end if;
end process;	

end architecture;
			