LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- Bank of 32 32-bit registers
ENTITY regfile IS
	PORT (	clock, ctrl_writeEnable, ctrl_reset	: IN STD_LOGIC;
			ctrl_writeReg, -- Register to write to
			ctrl_readRegA, -- Register 1 to read from
			ctrl_readRegB	: IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Register 2 to read from
			data_writeReg	: IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- data that you want to write to reg
			data_readRegA, data_readRegB	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) ); -- output of regs
END regfile;

ARCHITECTURE Structure OF regfile IS
	COMPONENT decoder5to32
		PORT (	s	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);	-- 5bit select vector
				w	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );	-- selected output bit becomes high
	END COMPONENT;
	COMPONENT register32bit
		PORT (	D	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bits data input
				clock, clear, inEnable, outEnableA, outEnableB	: IN STD_LOGIC;
				Qa, Qb	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );	-- 32bits data output
	END COMPONENT;
	COMPONENT triStateBuffer
		PORT (	input	: IN STD_LOGIC;
				enable	: IN STD_LOGIC;
				output	: OUT STD_LOGIC );
	END COMPONENT;
	
	SIGNAL writeEnable, outEnableA, outEnableB	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inEnable	: STD_LOGIC_VECTOR(31 DOWNTO 1);
BEGIN
	writeDecode: decoder5to32 PORT MAP (ctrl_writeReg, writeEnable);
	readDecodeA: decoder5to32 PORT MAP (ctrl_readRegA, outEnableA);
	readDecodeB: decoder5to32 PORT MAP (ctrl_readRegB, outEnableB);
	reg0 : FOR i IN 0 TO 31 GENERATE
		outA: triStateBuffer PORT MAP ('0', outEnableA(0), data_readRegA(i));
		outB: triStateBuffer PORT MAP ('0', outEnableB(0), data_readRegB(i));
	END GENERATE reg0;
	regs : FOR i IN 1 TO 31 GENERATE
		inEnable(i) <= ctrl_writeEnable AND writeEnable(i);
		reg_array: register32bit PORT MAP (data_writeReg, clock, ctrl_reset, inEnable(i), outEnableA(i), outEnableB(i), data_readRegA, data_readRegB);
	END GENERATE regs;
END;