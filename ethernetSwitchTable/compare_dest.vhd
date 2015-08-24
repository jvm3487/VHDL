library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity compare_dest is
	port(
		clock				:	in	 std_logic;
		reset				:	in	 std_logic;
		natural_reset  : in std_logic;
		cd_enanble		:	in	 std_logic;
		MAC_dest			:	in  std_logic_vector(47 downto 0);
		fromTable1		:	in	 std_logic_vector(50 downto 0);
		fromTable2		:	in	 std_logic_vector(50 downto 0);
		index1			:	out std_logic_vector(4 downto 0);
		index2			:	out std_logic_vector(4 downto 0);
		results			:	out std_logic_vector(1 downto 0);
		outPort			:	out std_logic_vector(1 downto 0);
		outAdd			:	out std_logic_vector(47 downto 0);
		outIndex 		:  out std_logic_vector(4 downto 0);
		outValid			:	out std_logic;
		outPort_saved 	: 	out std_logic_vector(1 downto 0);
		results_saved	:	out std_logic_vector(1 downto 0);
		wr_en				:	out std_logic);
end compare_dest;


architecture comp_dst_arch of compare_dest is

	component addrMux is
		port(
			a	:	in	std_logic_vector(47 downto 0);
			b	:	in std_logic_vector(47 downto 0);
			s	:	in	std_logic;
			o	:	out std_logic_vector(47 downto 0));
	end component;

		signal	idx1				:	unsigned(4 downto 0);
		signal	idx2				:	unsigned(4 downto 0);
		signal	in1				:	std_logic_vector(50 downto 0);
		signal	in2				:	std_logic_vector(50 downto 0);
		signal	src				:	std_logic_vector(47 downto 0);
		signal	done				:	std_logic;
		signal	found				:	std_logic;
		signal	series			:	std_logic;
		signal	outPort_inter	:	std_logic_vector(1 downto 0);
		signal	results_inter	:	std_logic_vector(1 downto 0);

begin
	amux	:	addrMux port map(in2(49 downto 2),in1(49 downto 2),series,outAdd);
	
	index1 <= std_logic_vector(idx1);
	index2 <= std_logic_vector(idx2);
	in1 <= fromTable1;
	in2 <= fromTable2;
	src <= mac_dest;
	results_inter(1) <= done;
	results_inter(0) <= found;
	outPort <= outPort_inter;
	results <= results_inter;
	
	--This is needed to save the results and port in case it is found because it takes additional cycles
	--for the FSM to output complete
	process(clock, natural_reset, results_inter, outPort_inter)
	begin
		if (natural_reset ='1') then
			results_saved <= "00";
			outPort_saved <= "00";
		elsif (clock'event and clock = '1') then
			results_saved <= results_inter;
			outPort_saved <= outPort_inter;
		end if;
	end process;
	
	process(clock,reset,idx1,idx2,done,cd_enanble)
	begin	
			if reset = '1' then 
				idx1 <= "00000";
				idx2 <= "01111";
			elsif clock'EVENT and clock = '1' and done = '0'	then 
				if (cd_enanble = '1') then
					idx1 <= idx1 + "00001";
					idx2 <= idx2 + "00001";
				else 
					idx1 <= idx1;
					idx2 <= idx2;
				end if;
			end if;
	end process;

	process(in1,in2,idx1,idx2,src,done,found,series,cd_enanble)
	begin
		if cd_enanble = '1' then
			if ((idx1 < 17) and ((idx2-1) < 32)) then 
				if (in1(49 downto 2) = src and in1(49 downto 2) /= "000000000000000000000000000000000000000000000000") then
					if in1(50) = '0' then
						wr_en <= '1';
						outValid <= '1';
						done <= '1';
						found <= '1';
						series <= '0';
					else
						wr_en <= '0';
						outValid <= '0';
						done <= '1';
						found <= '1';
						series <= '0';					
					end if;
				elsif (in2(49 downto 2) = src and in2(49 downto 2) /= "000000000000000000000000000000000000000000000000") then
					if in2(50) = '0' then
						wr_en <= '1';
						outValid <= '1';
						done <= '1';
						found <= '1';
						series <= '1';
					else
						wr_en <= '0';
						outValid <= '0';
						done <= '1';
						found <= '1';
						series <= '1';					
					end if;
				else
					wr_en <= '0';
					outValid <= '0';
					done <= '0';
					found <= '0';
					series <= '0';
				end if;	
			else
				wr_en <= '0';
				outValid <= '0';
				done <= '1';
				found <= '0';
				series <= '0';
			end if;
		else
			wr_en <= '0';
			outValid <= '0';
			done <= '0';
			found <= '0';
			series <= '0';
		end if;
	end process;
	
	process(in1, idx1, in2, idx2, series)
	begin
		if series = '1' then 
			outPort_inter <= in2(1 downto 0);
			outIndex <= std_logic_vector(idx2-1);
		else 
			outPort_inter <= in1(1 downto 0);
			outIndex <= std_logic_vector(idx1-1);
		end if;
	end process;

end architecture;