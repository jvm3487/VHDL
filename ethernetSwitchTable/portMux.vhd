library ieee;
use ieee.std_logic_1164.all;

entity portMux is
	port(
		a	:	in	std_logic_vector(1 downto 0);
		b	:	in std_logic_vector(1 downto 0);
		s	:	in	std_logic;
		o	:	out std_logic_vector(1 downto 0));
end portMux;


architecture mx	of portMux is


begin

	o <= a when s = '1' else b;

end architecture;