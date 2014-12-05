LIBRARY ieee;
USE ieee.std_logic_1164.all;
library altera;
use altera.altera_primitives_components.all;

ENTITY register1bit IS
	PORT
	(
		D		:	 IN STD_LOGIC;
		clear		:	 IN STD_LOGIC;
		inEnable		:	 IN STD_LOGIC;
		clock		:	 IN STD_LOGIC;
		outEnableB		:	 IN STD_LOGIC;
		outEnableA		:	 IN STD_LOGIC;
		Qa		:	 OUT STD_LOGIC;
		Qb		:	 OUT STD_LOGIC
	);
END register1bit;

ARCHITECTURE STRUCTURE OF register1bit IS

SIGNAL dffe_out : STD_LOGIC;

BEGIN

myTRI_A : TRI PORT MAP( a_in => dffe_out, 
							   oe   => outEnableA,
							   a_out=> Qa);
								
myTRI_B : TRI PORT MAP( a_in => dffe_out, 
							   oe   => outEnableB,
							   a_out=> Qb);
							 
my_DFFE : DFFE PORT MAP(
                            d=> D, 
                            clk=> clock, 
                            clrn=> not clear,
                            prn=>'1',
                            ena=>inEnable, 
                            q=> dffe_out);

END STRUCTURE;

