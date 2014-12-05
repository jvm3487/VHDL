
LIBRARY ieee, work;
USE ieee.std_logic_1164.all;
USE work.all;

entity hexencoder is
port (
   binary	: in 	std_logic_vector (3 downto 0);  	--input1 (4 bits from binaryitches)
   hexonehot 	: out	std_logic_vector (15 downto 0) 	--output 16 signals, 1 hot
   );
end entity;


ARCHITECTURE DATAFLOW OF hexencoder IS
-- Local signals to be used in this architecture


BEGIN

--initialize

	hexonehot(0) <= (NOT binary(3)) AND (NOT binary(2)) AND (NOT binary(1)) AND (NOT binary(0));
	hexonehot(1) <= (NOT binary(3)) AND (NOT binary(2)) AND (NOT binary(1)) AND (binary(0));
	hexonehot(2) <= (NOT binary(3)) AND (NOT binary(2)) AND (binary(1)) AND (NOT binary(0));
	hexonehot(3) <= (NOT binary(3)) AND (NOT binary(2)) AND (binary(1)) AND (binary(0));
	hexonehot(4) <= (NOT binary(3)) AND (binary(2)) AND (NOT binary(1)) AND (NOT binary(0));
	hexonehot(5) <= (NOT binary(3)) AND (binary(2)) AND (NOT binary(1)) AND (binary(0));
	hexonehot(6) <= (NOT binary(3)) AND (binary(2)) AND (binary(1)) AND (NOT binary(0));
	hexonehot(7) <= (NOT binary(3)) AND (binary(2)) AND (binary(1)) AND (binary(0));
	hexonehot(8) <= (binary(3)) AND (NOT binary(2)) AND (NOT binary(1)) AND (NOT binary(0));
	hexonehot(9) <= (binary(3)) AND (NOT binary(2)) AND (NOT binary(1)) AND (binary(0));
	hexonehot(10) <= (binary(3)) AND (NOT binary(2)) AND (binary(1)) AND (NOT binary(0));
	hexonehot(11) <= (binary(3)) AND (NOT binary(2)) AND (binary(1)) AND (binary(0));
	hexonehot(12) <= (binary(3)) AND (binary(2)) AND (NOT binary(1)) AND (NOT binary(0));
	hexonehot(13) <= (binary(3)) AND (binary(2)) AND (NOT binary(1)) AND (binary(0));
	hexonehot(14) <= (binary(3)) AND (binary(2)) AND (binary(1)) AND (NOT binary(0));
	hexonehot(15) <= (binary(3)) AND (binary(2)) AND (binary(1)) AND (binary(0));



END DATAFLOW;