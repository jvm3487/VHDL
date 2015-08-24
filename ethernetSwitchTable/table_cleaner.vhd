library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_primitives_components.all;

entity table_cleaner is
port(
	clock, reset					: in std_logic;
	vld_in							: in std_logic; -- this signal and the next one signal the frame is over
	table_subsystem_rdy			: in std_logic; 
	write_en							: in std_lOGIC;
	write_vld_bit					: in std_lOGIC; -- this signal determines if the FSM is writing a new value to the table or deleting a value from the table
	write_index						: in std_logic_vector(4 downto 0);
	cmpr_destination_done		: in std_LOGIC;
	cmpr_destination_found		: in std_logic;
	read_dest_index				: in std_lOGIC_vector(4 downto 0);
	cmpr_source_done				: in std_lOGIC;
	cmpr_source_found				: in std_logic;
	read_source_index				: in std_lOGIC_vector(4 downto 0);
	LRU_delete_vld					: out std_lOGIC;
	LRU_index						: out std_lOGIC_vector(4 downto 0);
	Second_LRU_index				: out std_lOGIC_vector(4 downto 0));
end table_cleaner;

architecture basic of table_cleaner is

component tableCleanReg2port PORT
	(
		clock			: IN STD_LOGIC  := '1';
		data			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		enable		: IN STD_LOGIC  := '1';
		rdaddress	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		wraddress	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		wren			: IN STD_LOGIC  := '0';
		q				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

type state_type is (A, B, C, D, E);
	signal state_reg, state_next: state_type;
	signal reg_address_read_in				: std_logic_vector(4 downto 0);
	signal reg_address_read_in_value		: unsigned (4 downto 0);
	signal reg_address_read_out			: std_lOGIC_vector(4 downto 0);
	signal reg_address_read_out_value 	: unsigned (4 downto 0);
	signal reg_address_write				: std_logic_vector(4 downto 0);
	signal init_done							: std_logic;
	signal table_data_in						: std_logic_vector(31 downto 0);
	signal table_data_in_value				: unsigned (31 downto 0);
	signal table_data_out					: std_logic_vector(31 downto 0);
	signal table_data_out_value			: unsigned (31 downto 0);
	signal LRU_counter_in					: std_lOGIC_vector(31 downto 0);
	signal LRU_counter_out					: std_logic_vector(31 downto 0);
	signal LRU_index_in						: std_logic_vector(4 downto 0);
	signal LRU_index_out						: std_lOGIC_vector(4 downto 0);
	signal LRU_expired_out					: std_logic;
	signal LRU_expired_in					: std_logic;
	signal Second_LRU_counter_in			: std_lOGIC_vector(31 downto 0);
	signal Second_LRU_counter_out			: std_logic_vector(31 downto 0);
	signal Second_LRU_index_in				: std_logic_vector(4 downto 0);
	signal Second_LRU_index_out			: std_lOGIC_vector(4 downto 0);
	signal read_vld_dest						: std_LOGIC;
	signal read_vld_source					: std_lOGIC;

begin

--these signals come from the compare subsystems
read_vld_dest <= cmpr_destination_done AND cmpr_destination_found;
read_vld_source <= cmpr_source_done AND cmpr_source_found;

--these lines convert between different types
reg_address_read_out_value <= unsigned(reg_address_read_out);
reg_address_read_in <= std_LOGIC_VECTOR(reg_address_read_in_value);
table_data_out_value <= unsigned(table_data_out);

process(clock, reset, state_next, reg_address_read_in_value)
begin
	if (reset ='1') then
		state_reg <= A;
	elsif (clock'event and clock = '1') then
		state_reg <= state_next;
	end if;
end process;

process(state_reg, init_done, write_en, read_vld_dest, read_vld_source, vld_in, table_subsystem_rdy)
begin
case state_reg is
	when A =>
		if (init_done = '0') then
			state_next <= A;
		else
			state_next <= B;
		end if;

	when B =>
		if (write_en = '1') then
			state_next <= B;
		elsif (read_vld_dest = '1') then
			state_next <= C;
		elsif (read_vld_source = '1') then
			state_next <= D;
		else
			state_next <= B;
		end if;
		
	when C =>
		if (vld_in = '1' and table_subsystem_rdy = '1') then
			state_next <= B;
		elsif (write_en = '1') then
			state_next <= C;
		elsif (read_vld_source = '1') then
			state_next <= E;
		else
			state_next <= C;
		end if;
			

	when D =>
		if (vld_in = '1' and table_subsystem_rdy = '1') then
			state_next <= B;
		elsif (write_en = '1') then
			state_next <= D;
		elsif (read_vld_dest = '1') then
			state_next <= E;
		else
			state_next <= D;
		end if;

	when E =>
		if (vld_in = '1' and table_subsystem_rdy = '1') then
			state_next <= B;
		else
			state_next <= E;
		end if;
end case;
end process;

process (state_reg, reg_address_read_in_value, reg_address_read_out_value, reg_address_read_out, reg_address_write, write_en, write_index, read_vld_dest, read_dest_index, read_vld_source, read_source_index, LRU_index_out, LRU_counter_out, LRU_expired_out, Second_LRU_counter_out, Second_LRU_index_out, table_data_out, table_data_out_value, table_data_in, table_data_in_value, write_vld_bit)
begin

--default values -> generally no change in the registers
init_done <= '0';
reg_address_read_in_value <= reg_address_read_out_value; --will only increment one later if it is not a read or write
reg_address_write <= reg_address_read_out; --defaults to writing to the same address as was read out
table_data_in <= table_data_out; --the following signals default to no change
table_data_in_value <= unsigned(table_data_in);
LRU_counter_in <= LRU_counter_out;
LRU_index_in <= LRU_index_out;
LRU_expired_in <= LRU_expired_out;
Second_LRU_counter_in <= Second_LRU_counter_out;
Second_LRU_index_in <= Second_LRU_index_out;

if (state_reg = A) then --initialize the ram to all zeros
	table_data_in <= (others => '0');
	reg_address_read_in_value <= reg_address_read_out_value + "00001";
	if (reg_address_read_out = "11111") then
		init_done <= '1';
	end if;
end if;
-- states where write is possible
if (state_reg = B or state_reg = C or state_reg = D or state_reg = E) then
	if (write_en = '1' or (read_vld_dest = '1' and (state_reg = B or state_reg = D)) or (read_vld_source = '1' and (state_reg = B or state_reg = C))) then --read or write
		
		table_data_in(30 downto 0) <= (others => '0'); --information has just been used
		table_data_in(31) <= '1'; --valid bit
		
		if (write_en = '1') then  --Main FSM writes to register
			reg_address_write <= write_index;
			if (write_vld_bit = '0') then --Checks if its deleting from the table instead of adding
				table_data_in(31) <= '0';
			end if;
		
		elsif (read_vld_dest = '1' and (state_reg = B or state_reg = D)) then --read for the destination address
			reg_address_write <= read_dest_index;
		
		else --read from source -> must be in state B or C
			reg_address_write <= read_source_index;
		
		end if;
		
		--below is code for the queue update after read or write
		if (reg_address_write = LRU_index_out) then -- moves the second thing in the buffer up if match LRU
			LRU_counter_in <= Second_LRU_counter_out;
			LRU_index_in <= Second_LRU_index_out;
			if (Second_LRU_counter_out(30) = '1' or Second_LRU_counter_out(29) = '1' or Second_LRU_counter_out(28) = '1') then --expired logic is approximately 344 seconds
				LRU_expired_in <= '1';
			else
				LRU_expired_in <= '0';
			end if;
			Second_LRU_counter_in <= (others => '0'); -- second element in the buffer is no longer valid
		elsif (reg_address_write = Second_LRU_index_out) then --emptys the second thing in the buffer if a match
			Second_LRU_counter_in <= (others => '0');
		end if;
		
	else -- not read or write -> increment counter and do compare logic to update buffers
		
		reg_address_read_in_value <= reg_address_read_out_value + "00001"; --move on to the next elment
		if (table_data_out(31) = '1') then --only increments the value if the element in the table is valid
			table_data_in_value <= table_data_out_value + "00000000000000000000000000000001"; --add one to current element 
			table_data_in <= std_LOGIC_VECTOR(table_data_in_value);
		end if;
		
		--update LRU index, counter, and expired bit
		if ((LRU_expired_out = '0' and table_data_out(31) = '0') or (table_data_out(31) = '1' and LRU_counter_out(31) = '1' and (table_data_out(30 downto 0) > LRU_counter_out(30 downto 0))) or (table_data_out(30) = '1' or table_data_out(29) = '1' or table_data_out(28)='1')) then -- fill the first element in buffer
			LRU_counter_in(31 downto 0) <= table_data_out(31 downto 0);
			LRU_index_in <= reg_address_read_out;
			if (table_data_out(30) = '1' or table_data_out(29) = '1' or table_data_out(28)='1') then --expired logic assumes approx 344 seconds
				LRU_expired_in <= '1';
			else
				LRU_expired_in <= '0';
			end if;
			if (LRU_index_out /= reg_address_read_out) then -- move old data to second place in buffer
				Second_LRU_counter_in <= LRU_counter_out;
				Second_LRU_index_in <= LRU_index_out;
			end if;
		
		-- not good enough for first in queue but good enough for second in queue
		elsif ((Second_LRU_counter_out(30) = '0' and Second_LRU_counter_out(29) = '0' and Second_LRU_counter_out(28)='0' and table_data_out(31) = '0') or (table_data_out(31) = '1' and LRU_counter_out(31) = '1' and table_data_out(30 downto 0) > Second_LRU_counter_out(30 downto 0))) then --not good enough for first LRU but good enough for second
			if (LRU_index_out /= reg_address_read_out) then -- prevents same index as first buffer element
				Second_LRU_counter_in(31 downto 0) <= table_data_out(31 downto 0);
				Second_LRU_index_in <= reg_address_read_out;
			end if;
		end if;
		
	end if; --not read or write
end if; -- states B, C, D, or E
end process;

--This defines the outputs of this componenet of the subsystem
LRU_delete_vld <= LRU_expired_out;
LRU_index <= LRU_index_out;
Second_LRU_index <= Second_LRU_index_out;

--The next five DFFs are for the registers at the end of the compare logic
LRU_Index_dff: for i in 4 downto 0 generate
LRU_Indx : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => LRU_index_in(i),
q   => LRU_index_out(i));
end generate LRU_Index_dff;

LRU_Counter_dff: for i in 31 downto 0 generate
LRU_Cntr : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => LRU_counter_in(i),
q   => LRU_counter_out(i));
end generate LRU_Counter_dff;

LRU_Expr : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => LRU_expired_in,
q   => LRU_expired_out);

Second_LRU_Index_dff: for i in 4 downto 0 generate
Second_LRU_Indx : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => Second_LRU_index_in(i),
q   => Second_LRU_index_out(i));
end generate Second_LRU_Index_dff;

Second_LRU_Counter_dff: for i in 31 downto 0 generate
Second_LRU_Cntr : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => Second_LRU_counter_in(i),
q   => Second_LRU_counter_out(i));
end generate Second_LRU_Counter_dff;

--This dff stores the old register read address between cycles
RegAddress_dff: for i in 4 downto 0 generate
RegAdd : dff port map (
clk => clock,
clrn => not(reset),
prn => '1',
d   => reg_address_read_in(i),
q   => reg_address_read_out(i));
end generate RegAddress_dff;

--This is for the 32 entries x 32 bit RAM table 
ramCleanerReg: tableCleanReg2port port map(
	clock		=> clock,
	data		=> table_data_in,
	enable		=> '1',
	rdaddress	=> reg_address_read_in,
	wraddress	=> reg_address_write,
	wren		=> '1',
	q		=> table_data_out
);
end basic;