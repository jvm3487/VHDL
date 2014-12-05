library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity incrementXYandReset is
port (
	 current_x  : in std_logic_vector (9 downto 0);
    current_y : in std_logic_vector (9 downto 0);
	 active_x: in std_logic;
	 toggle_active_x: in std_logic;
	 active_y: in std_logic;
	 toggle_active_y: in std_logic;
	 next_x  : out std_logic_vector (9 downto 0);
	 next_y : out std_logic_vector (9 downto 0));
end incrementXYandReset;


architecture basic of incrementXYandReset is

component tenBitCounter is
	port (
	 add_N: in std_logic_vector(9 downto 0);
    sum_N: out std_logic_vector (9 downto 0));
end component;

signal intermediate_x: std_logic_vector(9 downto 0);
signal intermediate_y: std_logic_vector(9 downto 0);
signal y_Plus_One: std_logic_vector(9 downto 0);

begin

increment_x: tenBitCounter PORT MAP(
	add_N => current_x(9 downto 0),
	sum_N => intermediate_x(9 downto 0)
	);
	
increment_y: tenBitCounter PORT MAP(
	add_N => current_y(9 downto 0),
	sum_N => y_Plus_One(9 downto 0)
	);
		
next_x <= "0000000000" when (current_x = "1100011111") else intermediate_x;
intermediate_y <= y_Plus_One when (current_x = "1100011111") else current_y; 
next_y <= "0000000000" when (current_y = "1000001011" and current_x = "1100011111") else intermediate_y;
	
end basic;