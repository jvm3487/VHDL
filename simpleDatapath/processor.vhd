-- Course: Duke University, ECE 590 (Fall 2012)
-- Description: unpipelined processor
-- Revised: October 6, 2012

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

ENTITY processor IS
    PORT (	clock, reset	: IN STD_LOGIC;
			keyboard_in	: IN STD_LOGIC_VECTOR(31 downto 0);
			keyboard_ack, lcd_write	: OUT STD_LOGIC;
			lcd_data	: OUT STD_LOGIC_VECTOR(31 downto 0) );
END processor;

ARCHITECTURE Structure OF processor IS
	COMPONENT imem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clken	: IN STD_LOGIC ;
				clock	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT dmem IS
		PORT (	address	: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
				clock	: IN STD_LOGIC ;
				data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				wren	: IN STD_LOGIC ;
				q	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT regfile IS
		PORT (	clock, ctrl_writeEnable, ctrl_reset	: IN STD_LOGIC;
				ctrl_writeReg, ctrl_readRegA, ctrl_readRegB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				data_writeReg	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
				data_readRegA, data_readRegB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
	END COMPONENT;
	COMPONENT alu IS
		PORT (	data_operandA, data_operandB	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit inputs
				ctrl_ALUopcode	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	-- 3bit ALU opcode
				data_result	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit output
				isEqual, isGreaterThan	: OUT STD_LOGIC);
	END COMPONENT;
	
	component adder32 is
PORT ( A, B : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32bit addends
carryIn : IN STD_LOGIC;
sum : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 32bit sum output
carryOut : OUT STD_LOGIC);
end component;

	
	COMPONENT control IS
		PORT ( op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
				ALU_select: OUT STD_LOGIC;
				ctrl_ALUopcode	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				Data_select	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				wren	: OUT STD_LOGIC;
				ctrl_writeEnable: OUT STD_LOGIC;
				Beq_C: OUT STD_LOGIC;
				Bgt_C: OUT STD_LOGIC;
				Jump_select: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				Destination_select: OUT STD_LOGIC;
				Source_select:  OUT STD_LOGIC;
				keyboard_ack: OUT STD_LOGIC;
				lcd_write: OUT STD_LOGIC);	
	END COMPONENT;
	
		COMPONENT ProcessorUpperHalf IS
		PORT (	
		ImmEx  : in std_logic_vector (31 downto 0); --Output of the sign extended element
		Beq_C : in std_logic;
		Bgt_C: in std_logic;
		Jump_select: in std_logic_vector(1 downto 0);
		Qb: in std_logic_vector (31 downto 0); --Lower output of the Register file
		clk: in std_logic;
		rst: in std_logic;
		isEqual: in std_logic;
		isGreaterThan: in std_logic;
		q_output  : out std_logic_vector (31 downto 0);
		next_counter_dummy : out std_logic_vector (31 downto 0); --dummy variable for simulation
		current_counter_dummy : out std_logic_vector (31 downto 0); --dummy variable for simulation
		counter_plus_one_out : out std_logic_vector (31 downto 0));
	END COMPONENT;
	
	component sext is
PORT (
	InSignal : IN STD_LOGIC_VECTOR (16 downto 0);
	OutSignal: OUT STD_LOGIC_VECTOR (31 downto 0)
	);
	end component;
	
	signal ALU_select: STD_LOGIC;
				signal ctrl_ALUopcode: STD_LOGIC_VECTOR(2 DOWNTO 0);
				signal Data_select	: STD_LOGIC_VECTOR(1 DOWNTO 0);
				signal wren	: STD_LOGIC;
				signal ctrl_writeEnable: STD_LOGIC;
				signal Beq_C: STD_LOGIC;
				signal Bgt_C: STD_LOGIC;
				signal Jump_select: STD_LOGIC_VECTOR(1 DOWNTO 0);
				signal Destination_select: STD_LOGIC;
				signal Source_select:   STD_LOGIC;
				signal keyboard_ack_dummy:  STD_LOGIC;
				signal lcd_write_dummy:  STD_LOGIC;	
				signal next_counter_dummy : std_logic_vector (31 downto 0);
				signal current_counter_dummy : std_logic_vector (31 downto 0);
				
				signal ImmEx  : std_logic_vector (31 downto 0); --Output of the sign extended element
		
		signal Qb:  std_logic_vector (31 downto 0); --Lower output of the Register file

		signal isEqual:  std_logic;
		signal isGreaterThan:  std_logic;
		signal CurrIns  :  std_logic_vector (31 downto 0);
		signal counter_plus_one_out : std_logic_vector (31 downto 0);
		
		signal thirtyone: STD_LOGIC_VECTOR(4 downto 0);

signal Rs: STD_LOGIC_VECTOR(4 downto 0);
signal Rd: STD_LOGIC_VECTOR(4 downto 0);
signal JalDataOut: STD_LOGIC_VECTOR(4 downto 0);
signal Rt: STD_LOGIC_VECTOR(4 downto 0);
signal s1: STD_LOGIC_VECTOR(31 downto 0);
signal s2: STD_LOGIC_VECTOR(31 downto 0);
signal SourceMuxOut: STD_LOGIC_VECTOR(4 downto 0);
signal AluMuxOut: STD_LOGIC_VECTOR(31 downto 0);
signal DatatoWrite: STD_LOGIC_VECTOR(31 downto 0);
signal DmemOut: STD_LOGIC_VECTOR(31 downto 0);
signal Keyin: STD_LOGIC_VECTOR(31 downto 0);
signal AluResult: STD_LOGIC_VECTOR(31 downto 0);
		
		
		
	
BEGIN
		--Taking apart current instruction
		Rd <= CurrIns(26 downto 22);
		Rs <= CurrIns(21 downto 17);
		Rt <= CurrIns(16 downto 12);
		
		
		upper_part: ProcessorUpperHalf port map (	
		ImmEx  => ImmEx, --Output of the sign extended element
		Beq_C => Beq_C,
		Bgt_C => Bgt_C,
		Jump_select => Jump_select,
		Qb => s2, --Lower output of the Register file
		clk => clock,
		rst => reset,
		isEqual => isEqual,
		isGreaterThan => isGreaterThan,
		q_output => CurrIns,
		next_counter_dummy =>next_counter_dummy,
		current_counter_dummy=>current_counter_dummy,
		counter_plus_one_out => counter_plus_one_out);

controller: control port map(
				op	=> CurrIns(31 downto 27),	-- instruction opcode
				ALU_select => ALU_select, 
				ctrl_ALUopcode	=> ctrl_ALUopcode,
				Data_select	=> Data_select,
				wren	=> wren,
				ctrl_writeEnable => ctrl_writeEnable,
				Beq_C => Beq_C,
				Bgt_C => Bgt_C,
				Jump_select => Jump_select,
				Destination_select => Destination_select,
				Source_select => Source_select,
				keyboard_ack => keyboard_ack_dummy,
				lcd_write => lcd_write_dummy);

lcd_write <= lcd_write_dummy;
keyboard_ack <= keyboard_ack_dummy;


registers: regFile PORT map (	
	clock => clock,
	ctrl_writeEnable =>  ctrl_writeEnable,
	ctrl_reset => reset, 
	ctrl_writeReg => JalDataOut,
	ctrl_readRegA => Rs,
	ctrl_readRegB =>  SourceMuxOut,
	data_writeReg => DatatoWrite,
	data_readRegA => s1,
	data_readRegB => s2);

--component ALU instantiated.
--ALU inputs: 
--S1 from regfile.
--ALu mux output.

--outputs: isEqual
--isgreaterthan
--result

MainAlu: Alu PORT MAP (	
		data_operandA => s1,
		data_operandB => AluMuxOut,
		ctrl_ALUopcode => ctrl_ALUopcode,
		data_result => AlUresult,
		isEqual => isEqual,
		isGreaterThan => isGreaterThan 
	);
	
	
--component data mem instantiated.
--Data memory inputs:
--Output from regfile s2
--result from ALU

--outputs: dataout

DataMem: Dmem PORT MAP (	
		address => ALUResult(11 downto 0),
		clock => not(clock),
		data => s2,
		wren => wren,
		q => DmemOut
	);
	
--Component Sign Extender:
--Inputs: the imem output.
--Outputs: signextended output.
sign_extend: sext PORT MAP (
		InSignal => CurrIns(16 downto 0),--output from the Imem component,
		OutSignal => ImmEx--Johns logic for branch address.
	);
	
--component 2:1 muxes instantiated
--Jal input selector:
JalDataOut <= "11111" when (Destination_select='1') else Rd;	

--Data input for one of the Reg file inputs:
SourceMuxOut <= Rd when (Source_select = '0') else Rt;

--Alu Input Selector mux:
 ALUMuxOut<= s2 when (AlU_select = '0') else ImmEx;

--component 4:1 mux with awesome when elses:
DatatoWrite <= keyboard_in when (Data_select = "11") else
	counter_plus_one_out when(Data_select = "10") else
	DmemOut when(Data_select = "01") else
	AluResult;
	

lcd_data <=  s2 ;

END Structure;