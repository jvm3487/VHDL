LIBRARY ieee;
USE ieee.std_logic_1164.all;
library altera;
use altera.altera_primitives_components.all;

ENTITY triStateBuffer IS
	PORT
	(
		input		:	 IN STD_LOGIC;
		enable		:	 IN STD_LOGIC;
		output		:	 OUT STD_LOGIC
	);
END triStateBuffer;

ARCHITECTURE STRUCTURE OF triStateBuffer IS

BEGIN

myTRI : TRI PORT MAP( a_in => input, 
							 oe   => enable,
							 a_out=> output);
							 

END STRUCTURE;