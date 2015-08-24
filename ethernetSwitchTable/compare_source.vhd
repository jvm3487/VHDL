library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compare_source is
	port(
		clock					:	in	 std_logic;
		reset					:	in	 std_logic;
		cs_enable			:	in	std_logic;
		MAC_source			:	in  std_logic_vector(47 downto 0);
		Source_port			: 	in  std_logic_vector(1 downto 0);
		fromTable1			:	in	 std_logic_vector(50 downto 0);
		fromTable2			:	in	 std_logic_vector(50 downto 0);
		index1				:	out std_logic_vector(4 downto 0);
		index2				:	out std_logic_vector(4 downto 0);
		results				:	out std_logic_vector(2 downto 0);
		src_working_valid : out std_logic; 
		outIndex				:	out std_logic_vector(4 downto 0);
		outData				:	out std_logic_vector(47 downto 0);
		outPort				:	out std_logic_vector(1 downto 0);
		wr_en					:	out std_logic);
end compare_source;


architecture comp_src_arch of compare_source is

	
	component addrMux is
		port(
			a	:	in	std_logic_vector(47 downto 0);
			b	:	in std_logic_vector(47 downto 0);
			s	:	in	std_logic;
			o	:	out std_logic_vector(47 downto 0));
	end component;
	
	component portMux is
		port(
			a	:	in	std_logic_vector(1 downto 0);
			b	:	in std_logic_vector(1 downto 0);
			s	:	in	std_logic;
			o	:	out std_logic_vector(1 downto 0));
	end component;

		signal	idx1				:	unsigned(4 downto 0);
		signal	idx2				:	unsigned(4 downto 0);
		signal	in1				:	std_logic_vector(50 downto 0);
		signal	in2				:	std_logic_vector(50 downto 0);
		signal	src				:	std_logic_vector(47 downto 0);
		signal	inPort			:	std_logic_vector(1 downto 0);
		signal	outPort_inter	:	std_logic_vector(1 downto 0);
		signal	done				:	std_logic;
		signal   same				:	std_logic;
		signal	found				:	std_logic;
		signal	series			:	std_logic;
		signal	check_valid_1 	: std_logic;
		signal	check_add_1		: std_logic_vector(47 downto 0);
		signal	check_port_1 	: std_logic_vector(1 downto 0);
		signal	check_valid_2 	: std_logic;
		signal	check_add_2		: std_logic_vector(49 downto 2);
		signal	check_port_2 	: std_logic_vector(1 downto 0);
		signal	en					: std_logic;

begin
	index1 <= std_logic_vector(idx1);
	index2 <= std_logic_vector(idx2);
	in1 <= fromTable1;
	in2 <= fromTable2;
	src <= mac_source;
	inPort <= source_port;
	results(2) <= done;
	results(1) <= found;
	results(0) <= same;
	wr_en <= en;
	
	check_valid_1 <= in1(50);
	check_add_1	<= in1(49 downto 2);
	check_port_1 <= in1(1 downto 0);
	check_valid_2 <= in2(50);
	check_add_2	<= in2(49 downto 2);
	check_port_2 <= in2(1 downto 0);
	
	outPort <= outPort_inter when (same = '1') else inPort;
	
	pmux : portMux port map(check_port_2,check_port_1,series,outPort_inter);
	amux : addrMux port map(check_add_2,check_add_1,series,outData);
	
	process(clock,reset,idx1,idx2,done,cs_enable)
	begin
			if reset = '1' then 
				idx1 <= "00000"; -- Start index 1 at 0
				idx2 <= "01111"; --  Start index 2 at 16
			elsif clock'EVENT and clock = '1' and done = '0'	then 
				if (cs_enable = '1') then
					idx1 <= idx1 + "00001"; -- Every clock, increment by 1
					idx2 <= idx2 + "00001";
				else
					idx1 <= idx1;
					idx2 <= idx2;
				end if;	
			end if;
	end process;

	process(in1,in2,idx1,idx2,src,inPort,done,same,found,series, cs_enable,check_add_1,check_add_2,check_port_1,check_port_2,check_valid_1,check_valid_2,en)
	begin
		if cs_enable = '1' then
			src_working_valid <= '1';
			if idx1 < 17 and idx2-1 < 32 then 
				if (check_add_1 = src and in1(49 downto 2) /= "000000000000000000000000000000000000000000000000") then
					if check_port_1 = inPort then 
						if check_valid_1 = '0' then
							en <= '1';
							done <= '1';
							found <= '1';
							same <= '1';
							series <= '0';
						else
							en <= '0';
							done <= '1';
							found <= '1';
							same <= '1';
							series <= '0';
						end if;
					else
						en <= '1';
						done <= '1';
						found <= '1';
						same <= '0';
						series <= '0';
					end if;
				elsif (in2(49 downto 2) = src and in2(49 downto 2) /= "000000000000000000000000000000000000000000000000") then
						if in2(1 downto 0) = inPort then
							if check_valid_2 = '0' then
								en <= '1';
								done <= '1';
								found <= '1';
								same <= '1';
								series <= '1';
							else
								en <= '0';
								done <= '1';
								found <= '1';
								same <= '1';
								series <= '1';
							end if;
						else
							en <= '1';
							done <= '1';
							found <= '1';
							same <= '0';
							series <= '1';
					end if;
				else
					en <= '0';
					done <= '0';
					found <= '0';
					same <= '0';
					series <= '0';
				end if;	
			else
				en <= '0';
				done <= '1';
				found <= '0';
				same <= '0';
				series <= '0';
		end if;
	else
		en <= '0';
		done <= '0';
		found <= '0';
		same <= '0';
		series <= '0';
		src_working_valid <= '0';
	end if;
end process;
	
	process(idx1,idx2,series)
	begin
		if series = '1' then 
			outIndex <= std_logic_vector(idx2-1);
		else 
			outIndex <= std_logic_vector(idx1-1);
		end if;

	end process;

end architecture;