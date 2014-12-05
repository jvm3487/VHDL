LIBRARY ieee;
USE ieee.std_logic_1164.all;
library altera;
use altera.altera_primitives_components.all;

ENTITY DflipflopE IS

PORT
	(
		D		:	 IN STD_LOGIC;
		clock		:	 IN STD_LOGIC;
		inEnable		:	 IN STD_LOGIC;
		clear		:	 IN STD_LOGIC;
		Q		:	 OUT STD_LOGIC
	);
	
END DflipflopE;

ARCHITECTURE STRUCTURE OF DflipflopE IS

BEGIN

my_DFFE : DFFE PORT MAP(
                            d=> D, 
                            clk=> clock, 
                            clrn=> not clear,
                            prn=>'1',
                            ena=>inEnable, 
                            q=> Q);
END STRUCTURE;
									 