LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shifter IS
	PORT (	data_A	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit input
			ctrl_rightshift	: IN STD_LOGIC;	-- shift direction (right / NOT left)
			ctrl_shamt	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- 5bit unsigned integer shift amount
			data_S	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );	-- 32bit output
END shifter;

ARCHITECTURE Structure OF shifter IS
	SIGNAL L0, L1, L2, L3, L4, R0, R1, R2, R3, R4	: STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit mux interconnects
	COMPONENT muxGeneric IS
		GENERIC (n: integer := 16);
		PORT (	A, B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);	-- 5bit inputs
				s	: IN STD_LOGIC;	-- select (NOT A / B)
				F	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );	-- 5bit output
	END COMPONENT;
BEGIN
	Dxxxxx:	muxGeneric GENERIC MAP (n => 32) PORT MAP (L4, R4, ctrl_rightshift, data_S);
	LxxxxN: muxGeneric GENERIC MAP (n => 32) PORT MAP (data_A(31 DOWNTO 0), data_A(30 DOWNTO 0)&"0", ctrl_shamt(0), L0);
	LxxxNx:	muxGeneric GENERIC MAP (n => 32) PORT MAP (L0(31 DOWNTO 0), L0(29 DOWNTO 0)&"00", ctrl_shamt(1), L1);
	LxxNxx:	muxGeneric GENERIC MAP (n => 32) PORT MAP (L1(31 DOWNTO 0), L1(27 DOWNTO 0)&"0000", ctrl_shamt(2), L2);
	LxNxxx: muxGeneric GENERIC MAP (n => 32) PORT MAP (L2(31 DOWNTO 0), L2(23 DOWNTO 0)&"00000000", ctrl_shamt(3), L3);
	LNxxxx: muxGeneric GENERIC MAP (n => 32) PORT MAP (L3(31 DOWNTO 0), L3(15 DOWNTO 0)&"0000000000000000", ctrl_shamt(4), L4);
	RxxxxN:	muxGeneric GENERIC MAP (n => 32) PORT MAP (data_A(31 DOWNTO 0), "0"&data_A(31 DOWNTO 1), ctrl_shamt(0), R0);
	RxxxNx: muxGeneric GENERIC MAP (n => 32) PORT MAP (R0(31 DOWNTO 0), "00"&R0(31 DOWNTO 2), ctrl_shamt(1), R1);
	RxxNxx: muxGeneric GENERIC MAP (n => 32) PORT MAP (R1(31 DOWNTO 0), "0000"&R1(31 DOWNTO 4), ctrl_shamt(2), R2);
	RxNxxx: muxGeneric GENERIC MAP (n => 32) PORT MAP (R2(31 DOWNTO 0), "00000000"&R2(31 DOWNTO 8), ctrl_shamt(3), R3);
	RNxxxx: muxGeneric GENERIC MAP (n => 32) PORT MAP (R3(31 DOWNTO 0), "0000000000000000"&R3(31 DOWNTO 16), ctrl_shamt(4), R4);
END Structure;