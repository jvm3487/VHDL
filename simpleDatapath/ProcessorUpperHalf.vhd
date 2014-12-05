
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity ProcessorUpperHalf is
port (
ImmEx  : in std_logic_vector (31 downto 0); --Output of the sign extended element
    Beq_C : in std_logic;
Bgt_C: in std_logic;
Jump_select: in std_logic_vector(1 downto 0);
Qb: in std_logic_vector (31 downto 0); --Lower output of the Register file
clk: in std_logic;
rst: in std_logic;
isEqual: in std_logic;
isGreaterThan: in std_logic;
q_output  : out std_logic_vector (31 downto 0); --instruction 
next_counter_dummy : out std_logic_vector (31 downto 0);
current_counter_dummy : out std_logic_vector (31 downto 0);
counter_plus_one_out : out std_logic_vector (31 downto 0));
end ProcessorUpperHalf;


architecture basic of ProcessorUpperHalf is

component adder32 is
PORT ( A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32bit addends
carryIn : IN STD_LOGIC;
sum : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32bit sum output
carryOut : OUT STD_LOGIC);
end component;

component imem is
PORT( address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
clken : IN STD_LOGIC  := '1';
clock : IN STD_LOGIC  := '1';
q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
end component;

signal q: std_logic_vector(31 downto 0); --default name for the ins memory output
signal dont_care: std_logic; --the carry out of the +1 MUX next to the PC
signal dont_care_2: std_logic; --the carry out of the sign extend mux and PC+1
signal current_counter: std_logic_vector(31 downto 0);
signal next_counter: std_logic_vector(31 downto 0);
signal counter_plus_one: std_logic_vector(31 downto 0);
signal j_type_next_program: std_logic_vector(31 downto 0);
signal branch_next_program: std_logic_vector(31 downto 0);
signal branch_or_pc_plus_one: std_logic_vector(31 downto 0);
signal branch_equal: std_logic;
signal branch_greater: std_logic;
signal branch_true: std_logic;
signal next_counter_not_reset: std_logic_vector(31 downto 0);

begin

--the following pieces of logic implement the Program Counter Element
program_counter_dff: for i in 31 downto 0 generate
counter_state : dff port map (
clk => clk,
clrn => NOT(rst),
prn => '1',
d   => next_counter(i), --this will be output of the jump control MUX
q   => current_counter(i));
end generate program_counter_dff;

--the following pieces of logic implement the +1 ALU using the provided adder32 file
--it produces a signal that is one more than the current program counter
counter_add_one: adder32 port map(
A => current_counter,
B => "00000000000000000000000000000001",
carryIn => '0',
sum => counter_plus_one,
carryOut => dont_care);

--the following pieces of logic implement the inst memory
instruction_memory: imem port map(
address => next_counter(11 downto 0),
clken => '1',
clock => clk,
q => q
);
next_counter_dummy<=next_counter;
current_counter_dummy<=current_counter;
--since q will be outputted but also used in the logic another signal is needed; same thing for current_plus_one
q_output <= q;
counter_plus_one_out <= counter_plus_one;

--the following pieces of logic extend the 27 bits of the J-type instruction to full 32 bits
j_type_next_program <= counter_plus_one(31 downto 27) & q(26 downto 0);

--this adds the sign extended value to the PC+1 to get the value to branch on a branch
counter_add_one_adder: adder32 port map(
A => counter_plus_one,
B => ImmEx,
carryIn => '0',
sum => branch_next_program,
carryOut => dont_care_2);
 
--this creates the two AND gates and one OR gate as well as a branch_true intermediate control
branch_equal <= isEqual AND Beq_C;
branch_greater <= isGreaterThan AND Bgt_C;
branch_true <= branch_equal OR branch_greater;

--this implements a MUX to select between PC+1 and branch_next_program
branch_or_pc_plus_one <= branch_next_program when (branch_true = '1') else counter_plus_one;

--this implements a 4-way MUX to select between jumps and the result of the branc or plus one MUX
next_counter_not_reset <= branch_or_pc_plus_one when (Jump_select = "00") else -- selects output of branch or pc_plus_one MUX
j_type_next_program when (Jump_select = "01") else -- selects J or JAL
Qb when (Jump_select = "10") else -- selects JR -- Rd
"00000000000000000000000000000000";

next_counter <= next_counter_not_reset when (rst = '0') else "00000000000000000000000000000000";


END basic;