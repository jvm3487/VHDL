LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity sext is
PORT (
	InSignal : IN STD_LOGIC_VECTOR (16 downto 0);
	OutSignal: OUT STD_LOGIC_VECTOR (31 downto 0)
	);
	
end sext;
architecture basic of sext is
signal signbit : STD_LOGIC;

begin

signbit <= Insignal(16); --  doubtful about this part a bit. need clarification
OutSignal <= "000000000000000" & InSignal when (signbit = '0') else "111111111111111" & Insignal;
end basic;
