LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY control IS
	PORT (	op	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- instruction opcode
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
END control;

ARCHITECTURE Behavior OF control IS

signal Source_select_dummy: std_logic;

BEGIN
	
	

	
	ALU_select <= (op(3) AND ((NOT op(1)) AND (NOT op(0)))) OR (op(1) AND op(2));
	ctrl_writeEnable <= ( (NOT op(3)) OR ( op (2) AND (op (1) XOR op(0))));
	ctrl_ALUopcode <= op(2 DOWNTO 0) when (Source_select_dummy = '1') else "00" & (op(3) AND (op(1) OR op (0)));
	Data_select <= op(3) & (  (op(3) AND op(1)) OR ( (NOT op(3)) AND op(2) AND op(1) AND op(0) ) );
	wren <= op(3) AND (NOT op(2)) AND (NOT op(1)) AND (NOT op(0));
	Beq_C <= op(3) AND op(0) AND (NOT op(1)) AND (NOT op(2));
	Bgt_C <= op(3) AND op(1) AND (NOT op(2)) AND (NOT op(0));
	Jump_select <= (op(3) AND op(1) AND op(0) AND (NOT op(2))) & (op(3) AND op(2) AND (NOT op(1)));
	Destination_select <= op(3) AND op(2) AND (NOT op(1)) AND op(0);
	Source_select_dummy <= (NOT op(3)) AND ( (NOT op(2)) OR (NOT op(1)) );
	keyboard_ack <= op(3) AND op(2) AND op(1) AND (NOT op(0));
	lcd_write <= op(3) AND op(2) AND op(1) AND op(0);
	
	Source_select <= Source_select_dummy;

END Behavior;



