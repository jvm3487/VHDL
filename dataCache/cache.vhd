library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity cache is
  port (
    clk      :  in std_logic;
    rst      :  in std_logic;
    
    ready    : out std_logic;
 
    --request interface---
    addr     : in std_logic_vector (31 downto 3);
    req_vld  : in std_logic;
    req_st   : in std_logic;
    
    
    resp_hit  : out std_logic;
    resp_miss : out std_logic;
    resp_dirty: out std_logic;
    
    
    --cast_out data--
    co_vld   : out std_logic;
    co_addr  : out std_logic_vector(31 downto 4);
    --reload interface --
    rld_vld  : in std_logic;
    
    ---data interface --
    -- used for store write data (63 downto 0)
    -- and for reload data
    data_in : in std_logic_vector(127 downto 0); 
    -- used for load read data (63 downto 0)
    -- and cast out data
    data_out : out std_logic_vector(127 downto 0);
    --debug interface
    debug_sel : in std_logic_vector (3 downto 0);
    debug_info: out std_logic_vector (7 downto 0));
end cache;

architecture basic of cache is

component rcaddrSevenBit is
  generic (  
   hi: natural :=6);
  port (
     a   : in std_logic_vector (hi downto 0);  
     b   : in std_logic_vector (hi downto 0);   
     ci  : in std_logic;                               
     sum : out std_logic_vector (hi downto 0)); 
end component;

  -- for the tag array
  component tags is
    port (
      address  : in std_logic_vector(6 downto 0);
      clock    : in std_logic;
      clken    : in std_logic := '1';
      data     : in std_logic_vector (20 DOWNTO 0);
      wren     : in std_logic ;
      q        : out std_logic_vector (20 DOWNTO 0));
  end component;

  -- for the data array
  component data is
    port (
      
      address  : in std_logic_vector(6 downto 0);
      byteena  : in std_logic_vector(63 downto 0);
      clock    : in std_logic;
      data     : in std_logic_vector (511 DOWNTO 0);
      wren     : in std_logic ;
      q       : out std_logic_vector (511 DOWNTO 0));
  end component;

  -- a register (multiple DFFs together)
  component reg is
    generic (lo : integer := 0;
             hi : integer := 31);
    port (
      clk: in std_logic;
      rst: in std_logic;
      
      d : in std_logic_vector (hi downto lo);
      q : out std_logic_vector (hi downto lo);
      en : in std_logic);
  end component;
  
  signal nextCount: std_logic_vector(1 downto 0);
  signal currCount: std_logic_vector(1 downto 0);
  signal increment_count: std_logic_vector(1 downto 0);
  signal data_address: std_logic_vector(6 downto 0);
  signal byteena: std_logic_vector(63 downto 0);
  signal load_data: std_logic_vector(63 downto 0);
  signal cast_out_data: std_logic_vector(127 downto 0);
   signal savedData: std_logic_vector(63 downto 0);
  signal data_to_load: std_logic_vector(511 downto 0);
  signal data_wren: std_logic;
  signal next_bytes_enabled: std_logic_vector(7 downto 0);
  signal bytes_enabled: std_logic_vector(511 downto 0);
  signal reload_done: std_logic;
  signal almost_done: std_logic;
  signal almost_almost_done: std_logic;
  signal curr_index: std_logic_vector(6 downto 0);
signal incr: std_logic_vector(6 downto 0);
signal rdy:std_logic;
signal next_rdy:std_logic;
signal saved_tag: std_logic_vector(20 downto 0);
signal next_index: std_logic_vector(6 downto 0);
signal overflow: std_logic;
signal tag_out: std_logic_vector(20 downto 0);
  signal data_from_array : std_logic_vector(511 downto 0);
  signal next_reload_state : std_logic_vector(1 downto 0);
    signal nextState : std_logic_vector(1 downto 0);
signal reload_State : std_logic_vector(1 downto 0);
signal fullAddress: std_logic_vector(31 downto 0);
signal savedAddress: std_logic_vector(31 downto 0);
signal firstFour: std_logic; 
signal secFour: std_logic; 
signal thirdFour: std_logic;
signal fourthFour: std_logic;
signal fifthFour: std_logic;
signal firHalf: std_logic;
signal secHalf: std_logic;
signal tags_save: std_logic_vector(20 downto 0);
signal curState: std_logic_vector(1 downto 0);
signal resp_miss_dummy: std_logic;
signal tag_wren: std_logic;
signal co_vld_dummy: std_logic;
signal next_store_state: std_logic;
signal storing: std_logic;
signal co1: std_logic;
signal co2: std_logic;
signal co3: std_logic;
signal co4: std_logic;
signal resp_dirty_dummy: std_logic;
signal next_co_vld: std_logic;
signal new_tag: std_logic_vector(20 downto 0);
signal tag_address: std_logic_vector(6 downto 0);
signal co_addr_dummy: std_logic_vector(31 downto 4);
signal resp_hit_dummy: std_logic;
   
begin

initialization: for i in 6 downto 0 generate
initialization_counter : dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_index(i),
q   => curr_index(i));
end generate initialization;

tag_init_counter: rcaddrSevenBit port map(
a => curr_index(6 downto 0),
b => incr,
ci => '0',
sum => next_index(6 downto 0));


incr<= "0000000" when curr_index="1111111" else "0000001";
next_rdy <= '1' when curr_index = "1111111" else '0';

ready_dff : dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_rdy,
q   => rdy);
ready <= rdy;
----------Ready now asserted, wait for request-------------------------------------
--iterates through the two states when req_vld is high and req_st is low; otherwise waits for req_vld and a low req_st

--MODIFIED FOR STORES WITH ADDITIONAL STAte
nextState <= "01" when (req_vld = '1' and req_st = '0') else 
 "10" when (req_vld = '1' and req_st = '1') else "00";

store_state: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_store_state,
q   => storing);
 
next_store_state <= req_st when req_vld else storing;
 
 
--2 bit d flip flops to give the option to go to more than two states; currently high bit does nothing
request_state_dff: for i in 1 downto 0 generate
counter_state : dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => nextState(i),
q   => curState(i));

end generate request_state_dff;

--logic for first state
fullAddress <= (addr(31 downto 3) & "000");

saveTheAddress: reg port map(
      clk => clk,
      rst => rst, 
      d => fullAddress,
      q => savedAddress,
      en => req_vld);

tagsSave: reg generic map (hi => 20, lo => 0) port map(
clk => clk,
   rst => rst, 
   d => tag_out,
   q => saved_tag,
   en => req_vld);
--ADDED TO SAVE STORE DATA!!!!! DOES THIS LOOK RIGHT?
dataSave: reg generic map (hi => 63, lo => 0) port map(
clk => clk,
   rst => rst, 
   d => data_in(63 downto 0),
   q => savedData,
   en => req_st); 

--logic for second state
--bitwise comparison of the tags
--first check is valid bit
firstFour <= tag_out(20) AND (NOT (tag_out(18) xor savedAddress(31))) AND (NOT (tag_out(17) xor savedAddress(30))) AND (NOT (tag_out(16) xor savedAddress(29)));
secFour <= (NOT (tag_out(15) xor savedAddress(28))) AND (NOT (tag_out(14) xor savedAddress(27))) AND (NOT (tag_out(13) xor savedAddress(26))) AND (NOT (tag_out(12) xor savedAddress(25))); 
thirdFour <= (NOT (tag_out(11) xor savedAddress(24))) AND (NOT (tag_out(10) xor savedAddress(23))) AND (NOT (tag_out(9) xor savedAddress(22))) AND (NOT (tag_out(8) xor savedAddress(21)));
fourthFour <= (NOT (tag_out(7) xor savedAddress(20))) AND (NOT (tag_out(6) xor savedAddress(19))) AND (NOT (tag_out(5) xor savedAddress(18))) AND (NOT (tag_out(4) xor savedAddress(17)));
fifthFour <= (NOT (tag_out(3) xor savedAddress(16))) AND (NOT (tag_out(2) xor savedAddress(15))) AND (NOT (tag_out(1) xor savedAddress(14))) AND (NOT (tag_out(0) xor savedAddress(13)));

firHalf <= firstFour AND secFour AND thirdFour;
secHalf <= fourthFour AND fifthFour;
--outputs
resp_hit <= resp_hit_dummy;
resp_hit_dummy <= (firHalf and secHalf) when (curState = "01") OR (curState ="10") else --MODIFIED FOR STORES, DOES THIS WORK?
'1' when reload_done = '1' else '0';
resp_miss_dummy <= (NOT (firHalf AND secHalf)) when (curState = "01") or (curState = "10") else '0';
resp_miss <= resp_miss_dummy;
resp_dirty_dummy <= (tag_out(20) AND tag_out(19)) when (curState = "01" or (curState = "10")) else '0';

--this produces the data out on a hit


data_out(127 downto 64) <= cast_out_data(127 downto 64);-- when co_vld_dummy else "0000000000000000000000000000000000000000000000000000000000000000";
--data_out(63 downto 0) <= load_data; -error is not here
data_out(63 downto 0) <= cast_out_data(63 downto 0) when co_vld_dummy = '1' else load_data;

--MODIFIED FOR STORE
load_data<= data_from_array(511 downto 448) when (savedAddress(5 downto 3) = "111") else
data_from_array(447 downto 384) when (savedAddress(5 downto 3) = "110") else
data_from_array(383 downto 320) when (savedAddress(5 downto 3) = "101") else
data_from_array(319 downto 256) when (savedAddress(5 downto 3) = "100") else
data_from_array(255 downto 192) when (savedAddress(5 downto 3) = "011") else
data_from_array(191 downto 128) when (savedAddress(5 downto 3) = "010") else
data_from_array(127 downto 64) when (savedAddress(5 downto 3) = "001") else
data_from_array(63 downto 0);


--MODIFIED FOR STORE
cast_out_data<= data_from_array(127 downto 0) when co1 else
data_from_array(255 downto 128) when co2 else
data_from_array(383 downto 256) when co3 else
data_from_array(511 downto 384); 


--Counter to count the four beats of reload data-----------------------------------------------------------------------
--It is reset when we assert resp_miss
--It is incremented each time rld_vld is asserted
reload: for i in 1 downto 0 generate
reload_counter : dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_reload_state(i),
q   => reload_state(i));
end generate reload;

next_reload_state<= "00" when resp_miss_dummy = '1' else increment_count;
increment_count(0) <= rld_vld XOR reload_state(0);
increment_count(1) <= reload_state(1) XOR (rld_vld AND reload_state(0));

reload_almost_complete: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => almost_almost_done,
q   => almost_done);

reload_complete: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => almost_done,
q   => reload_done);

almost_almost_done <= (reload_state(0) AND reload_state(1)) AND rld_vld;
--Counter to count the four beats of castout data-----------------------------------------------------------------------
--It is reset 
--It is incremented each time rld_vld is asserted
--cast_out: for i in 1 downto 0 generate
--cast_out_counter : dff port map (
--clk => clk,
--clrn => NOT(rst),
--prn => '1',
--d   => next_castout_state(i),
--q   => castout_state(i));
--end generate cast_out;
--
--next_castout_state<= "00" when resp_miss_dummy = '1' and resp_dirty = '1' else increment_cast;
--increment_cast(0) <= co_vld_dummy XOR castout_state(0);
--increment_cast(1) <= castout_state(1) XOR (co_vld_dummy AND castout_state(0));
resp_dirty <= resp_dirty_dummy;

next_co_vld<= resp_miss_dummy and resp_dirty_dummy;
co_vld_dummy <= co1 OR co2 OR co3 OR co4;
co_vld <= co_vld_dummy;

CastOut1: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_co_vld,
q   => co1);

CastOut2: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => co1,
q   => co2);

CastOut3: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => co2,
q   => co3);

CastOut4: dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => co3,
q   => co4);




---MODIFIED FOR STORES
bytes_enabled(0) <= '1' when (((reload_state(0))='0' AND reload_state(1)='0' and rld_vld='1') OR (savedAddress(5 downto 3) = "000" and (curState = "10" or (reload_done = '1' and storing ='1')))) else '0';
bytes_enabled(1) <= '1' when (((reload_state(0))='0' AND reload_state(1)='0' and rld_vld='1') OR (savedAddress(5 downto 3) = "001" and (curState = "10"  or (reload_done = '1' and storing ='1')))) else '0';

bytes_enabled(2) <= '1' when (reload_state(0)='1' AND (reload_state(1) ='0' and rld_vld='1'))  OR (savedAddress(5 downto 3) = "010" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0';
bytes_enabled(3) <= '1' when (reload_state(0)='1' AND (reload_state(1) = '0' and rld_vld='1')) OR (savedAddress(5 downto 3) = "011" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0';
bytes_enabled(4) <= '1' when ((reload_state(0)='0') AND reload_state(1)='1' and rld_vld='1') OR (savedAddress(5 downto 3) = "100" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0';
bytes_enabled(5) <= '1' when ((reload_state(0)='0') AND reload_state(1)='1' and rld_vld='1') OR (savedAddress(5 downto 3) = "101" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0';
bytes_enabled(6) <= '1' when (reload_state(0)='1' AND reload_state(1)='1' and rld_vld='1')  OR (savedAddress(5 downto 3) = "110" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0'; 
bytes_enabled(7) <= '1' when (reload_state(0)='1' AND reload_state(1)='1' and rld_vld='1')  OR (savedAddress(5 downto 3) = "111" and (curState = "10"  or (reload_done = '1' and storing ='1'))) else '0'; 
byteena(7 downto 0) <= "11111111" when bytes_enabled(0) else "00000000";
byteena(15 downto 8) <= "11111111" when bytes_enabled(1) else "00000000";
byteena(23 downto 16) <= "11111111" when bytes_enabled(2) else "00000000";
byteena(31 downto 24) <= "11111111" when bytes_enabled(3) else "00000000";
byteena(39 downto 32) <= "11111111" when bytes_enabled(4) else "00000000";
byteena(47 downto 40) <= "11111111" when bytes_enabled(5) else "00000000";
byteena(55 downto 48) <= "11111111" when bytes_enabled(6) else "00000000";
byteena(63 downto 56) <= "11111111" when bytes_enabled(7) else "00000000";
--Controls when and what to write--------------------------------------------------------------------- 
dataArray: data port map(
address => data_address,
      byteena => byteena,
      clock  => clk,
      data   => data_to_load,
      wren   => data_wren,
      q    => data_from_array);

data_address <= fullAddress(12 downto 6) when (rdy ='1' and req_vld ='1') else 
savedAddress(12 downto 6);

--MODIFIED FOR STORES
data_to_load(63 downto 0) <=  savedData(63 downto 0) when (curState = "10" or reload_done = '1') else data_in(63 downto 0);
data_to_load(127 downto 64) <=  savedData(63 downto 0) when (curState = "10" or reload_done = '1') else data_in(127 downto 64);
data_to_load(191 downto 128) <=  savedData(63 downto 0) when (curState = "10" or reload_done = '1') else data_in(63 downto 0);
data_to_load(255 downto 192) <=  savedData(63 downto 0)when (curState = "10" or reload_done = '1') else data_in(127 downto 64);
data_to_load(319 downto 256) <= savedData(63 downto 0) when (curState = "10" or reload_done = '1') else data_in(63 downto 0);
data_to_load(383 downto 320) <=  savedData(63 downto 0)when (curState = "10" or reload_done = '1') else data_in(127 downto 64);
data_to_load(447 downto 384) <=  savedData(63 downto 0) when (curState = "10" or reload_done = '1') else data_in(63 downto 0);
data_to_load(511 downto 448) <=  savedData(63 downto 0)when (curState = "10" or reload_done = '1') else data_in(127 downto 64);


data_wren <= '1' when (rld_vld='1' or (curState = "10" and resp_hit_dummy = '1') or (storing='1' and reload_done='1')) else '0'; 
 --- for the tag array------
 --Should be able to write to tag array on hit or miss, whenever rld_vld is asserted
  
   tags_array: tags port map (
      address  => tag_address,
      clock    => clk,
      clken    => '1',
      data     => new_tag,
      wren     =>  tag_wren,
      q        => tag_out);

tag_wren <= '1' when(((reload_state(0)='0') and reload_state(1)='1' and rld_vld='1') OR ((rst='0') AND (rdy ='0')) OR (curState = "10" and resp_hit_dummy = '1'))else '0'; --MODIFIED FOR STORE!!!!

co_addr <= co_addr_dummy;
co_addr_dummy(31 downto 13) <= tag_out(18 downto 0);
co_addr_dummy(12 downto 6) <= savedAddress(12 downto 6);
co_addr_dummy(5 downto 4) <= "00" when co1 else "01" when co2 else "10" when co3 else "11";

tag_address <= fullAddress(12 downto 6) when (rdy ='1' and req_vld ='1') else 
savedAddress(12 downto 6) when (rdy ='1' and req_vld ='0')else
curr_index;

new_tag (18 downto 0) <= savedAddress (31 downto 13);
new_tag(20) <= '0' when (NOT (rst) and NOT(rdy)) else '1';
new_tag(19) <= '1' when storing else '0'; --IS THIS RIGHT???

end basic;