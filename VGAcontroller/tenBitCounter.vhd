library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity tenBitCounter is
generic(
	nBit : natural := 9);
port (
    -- Takes one (nBit+1) bit vector and adds one -> can add from 0 to (2^(nBit+1))-1 (ignores overflow -> 0 with no carry out)
	 add_N  : in std_logic_vector(nBit downto 0);
    sum_N : out std_logic_vector(nBit downto 0));
end tenBitCounter;
	
architecture basic of tenBitCounter is

signal carryIn_N : std_logic_vector ((nBit+1) downto 0);

begin

carryIn_N(0) <= '1';

-- XOR with current bit and a potential carryIn from previous bit in a ripple carry manner
rippleCarryCounter: for i in 0 to nBit generate
	sum_N(i) <= add_N(i) XOR carryIn_N(i);
	carryIn_N(i+1) <= add_N(i) AND carryIn_N(i);
end generate rippleCarryCounter;	
	
end basic;