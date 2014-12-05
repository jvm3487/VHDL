LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder32 IS
	PORT (	A, B	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit addends
			carryIn	: IN STD_LOGIC;
			sum	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);	-- 32bit sum output
			carryOut	: OUT STD_LOGIC);
END adder32;

ARCHITECTURE structure OF adder32 IS
	SIGNAL carry15, carryH0, carryH1	: STD_LOGIC;	-- internal carry / multiplexer select
	SIGNAL sumH0, sumH1	: STD_LOGIC_VECTOR(15 DOWNTO 0);	-- temporary High vectors for port mapping
	COMPONENT adder16
		PORT (	A, B	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);	-- 16bit addends
				carryIn	: IN STD_LOGIC;
				sum	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	-- 16bit sum output
				carryOut	: OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT muxGeneric
		GENERIC (n: integer:=16);
		PORT (	A, B	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);	-- 16bit inputs
				s	: IN STD_LOGIC;	-- select (NOT A / B)
				F	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );	-- 16bit output
	END COMPONENT;
BEGIN
	lower:	adder16 PORT MAP (A(15 DOWNTO 0), B(15 DOWNTO 0), carryIn, sum(15 DOWNTO 0), carry15);
	upper0:	adder16 PORT MAP (A(31 DOWNTO 16), B(31 DOWNTO 16), '0', sumH0, carryH0);
	upper1:	adder16 PORT MAP (A(31 DOWNTO 16), B(31 DOWNTO 16), '1', sumH1, carryH1);
	upper:	muxGeneric GENERIC MAP (n => 16) PORT MAP (sumH0, sumH1, carry15, sum(31 DOWNTO 16));
	carry:	carryOut <= (carryH0 AND NOT carry15) OR (carryH1 AND carry15);
END structure;