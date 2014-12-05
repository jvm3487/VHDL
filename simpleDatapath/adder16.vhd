LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder16 IS
	PORT (	A, B	: IN STD_LOGIC_VECTOR(15 DOWNTO 0);	-- 8bit addends
			carryIn	: IN STD_LOGIC;
			sum	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	-- 8bit sum output
			carryOut	: OUT STD_LOGIC);
END adder16;

ARCHITECTURE Structure OF adder16 IS
	SIGNAL carry8	: STD_LOGIC;	-- internal carries
	COMPONENT adder8 IS
		PORT (	A, B	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);	-- 8bit addends
				carryIn	: IN STD_LOGIC;
				sum	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);	-- 8bit sum output
				carryOut	: OUT STD_LOGIC);
	END COMPONENT;
BEGIN
	lower: adder8 PORT MAP (A(7 DOWNTO 0), B(7 DOWNTO 0), carryIn, sum(7 DOWNTO 0), carry8);
	upper: adder8 PORT MAP (A(15 DOWNTO 8), B(15 DOWNTO 8), carry8, sum(15 DOWNTO 8), carryOut);
END Structure;