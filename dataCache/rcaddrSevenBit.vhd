library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity rcaddrSevenBit is
  generic (  
   hi: natural :=6);
  port (
     a   : in std_logic_vector (hi downto 0);  
     b   : in std_logic_vector (hi downto 0);   
     ci  : in std_logic;                               
     sum : out std_logic_vector (hi downto 0)
	  ); 
end rcaddrSevenBit;

architecture basic of rcaddrSevenBit is

signal carries : std_logic_vector (hi + 1 downto 0); 
signal half_sum : std_logic_vector (hi downto 0);     
signal half_co   : std_logic_vector (hi downto 0);    

begin
  carries(0) <= ci; 
  for_bits: for i in hi downto 0 generate
      half_sum(i) <= a(i) xor b(i);  
      half_co(i)  <= a(i) and b(i);
      sum(i) <= half_sum(i) xor carries(i);
      carries(i+1) <= half_co(i) or (carries(i) and half_sum(i));
  end generate for_bits;
 
end basic;