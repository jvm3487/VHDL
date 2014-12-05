
LIBRARY ieee, work;
USE ieee.std_logic_1164.all;
USE work.all;

entity hex_decoder is
port (
   hexonehot	: in 	std_logic_vector (15 downto 0);  	--input1 set of onehot signals representing hex value
   ledsegments 	: out	std_logic_vector (6 downto 0) 	--output 7 bit vector controlling LED segments
   );
end entity;


ARCHITECTURE DATAFLOW OF hex_decoder IS
-- Local signals to be used in this architecture

BEGIN

--initialize

ledsegments(0)<=hexonehot(1)OR hexonehot(4) OR hexonehot(11) OR hexonehot(13);
ledsegments(1)<=hexonehot(5)OR hexonehot(6) OR hexonehot(11) OR hexonehot(12)OR hexonehot(14)OR hexonehot(15);
ledsegments(2)<=hexonehot(2)OR hexonehot(12) OR hexonehot(14) OR hexonehot(15);
ledsegments(3)<=hexonehot(1)OR hexonehot(4) OR hexonehot(7) OR hexonehot(9)OR hexonehot(10)OR hexonehot(15);
ledsegments(4)<=hexonehot(1)OR hexonehot(3) OR hexonehot(4) OR hexonehot(5)OR hexonehot(7)OR hexonehot(9);
ledsegments(5)<=hexonehot(2)OR hexonehot(3) OR hexonehot(13) OR hexonehot(1);
ledsegments(6)<=hexonehot(0)OR hexonehot(1) OR hexonehot(7) OR hexonehot(12);


END DATAFLOW;