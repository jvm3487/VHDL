
library IEEE, altera, work;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_1164.all;
USE altera.altera_primitives_components.all;
USE work.all;

ENTITY top_level is
port (
	SW			:	in		std_logic_vector(17 downto 0);
	HEX0		:	out	std_logic_vector( 6 downto 0);
	HEX1		:	out	std_logic_vector( 6 downto 0);
	HEX2		:	out	std_logic_vector( 6 downto 0);
	HEX3		:	out	std_logic_vector( 6 downto 0);
	HEX4		:	out	std_logic_vector( 6 downto 0);
	HEX5		:	out	std_logic_vector( 6 downto 0);
	HEX6		:	out	std_logic_vector( 6 downto 0);
	HEX7		:	out	std_logic_vector( 6 downto 0));   
END ENTITY;

ARCHITECTURE basic of top_level is

signal segments	:	std_logic_vector(55 downto 0);
signal hex_1	:	std_logic_vector(15 downto 0);
signal hex_2	:	std_logic_vector(15 downto 0);
signal hex_3	:	std_logic_vector(15 downto 0);
signal hex_4	:	std_logic_vector(15 downto 0);
signal hex_5	:	std_logic_vector(15 downto 0);
signal lastbinary: std_logic_vector(3 downto 0);


COMPONENT hexencoder IS
	PORT(
		binary	: in 	std_logic_vector (3 DOWNTO 0);
		hexonehot	: out std_logic_vector (15 DOWNTO 0)
		);
END COMPONENT;

COMPONENT hex_decoder IS
	PORT(
		hexonehot	: in 	std_logic_vector (15 DOWNTO 0);
		ledsegments	: out std_logic_vector (6 DOWNTO 0)
		);
END COMPONENT;

BEGIN
	
--	HEX7 <= segments(55 downto 49);
--	HEX6 <= segments(48 downto 42);
--	HEX5 <= segments(41 downto 35);
--	HEX4 <= segments(34 downto 28);
--	HEX3 <= segments(27 downto 21);
--	HEX2 <= segments(20 downto 14);
--	HEX1 <= segments(13 downto  7);
--	HEX0 <= segments( 6 downto  0);
	


lastbinary<="00" & SW(17 downto 16);
HEX5<="1111111";
HEX6<="1111111";
HEX7<="1111111";


firsthex : hexencoder PORT MAP(
	binary => SW(3 downto 0),
	hexonehot => hex_1(15 downto 0)	
	);

		
secondhex : hexencoder PORT MAP(
	binary => SW(7 downto 4),
	hexonehot => hex_2(15 downto 0)	
	);
	
	
thirdhex : hexencoder PORT MAP(
	binary => SW(11 downto 8),
	hexonehot => hex_3(15 downto 0)	
	);
	
	
fourthhex : hexencoder PORT MAP(
	binary => SW(15 downto 12),
	hexonehot => hex_4(15 downto 0)	
	);
	
	
fifthhex : hexencoder PORT MAP(
	binary => lastbinary,
	hexonehot => hex_5(15 downto 0)	
	);
	
firstLED : hex_decoder PORT MAP(
	hexonehot => hex_1,
	ledsegments => HEX0	
	);
	
secondLED : hex_decoder PORT MAP(
	hexonehot => hex_2,
	ledsegments => HEX1	
	);
	
thirdLED : hex_decoder PORT MAP(
	hexonehot => hex_3,
	ledsegments => HEX2	
	);
	
fourthLED : hex_decoder PORT MAP(
	hexonehot => hex_4,
	ledsegments => HEX3	
	);

fifthLED : hex_decoder PORT MAP(
	hexonehot => hex_5,
	ledsegments => HEX4	
	);
	
	

END basic;


