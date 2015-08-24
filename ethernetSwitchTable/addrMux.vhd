library ieee;
use ieee.std_logic_1164.all;

entity addrMux is
	port(
		a	:	in	std_logic_vector(47 downto 0);
		b	:	in std_logic_vector(47 downto 0);
		s	:	in	std_logic;
		o	:	out std_logic_vector(47 downto 0));
end addrMux;


architecture mx	of addrMux is


begin

	o <= a when s = '1' else b;

end architecture;