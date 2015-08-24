library ieee;
use ieee.std_logic_1164.all;

entity interface is
	port(
		clock				:	in	std_logic;
		reset				:	in std_logic;
		ready_in			:	in	std_logic;
		ready_out		:	out	std_logic;
		valid_in			:	in std_logic;
		dest_write_en 	: in std_logic;
		fsm_valid		:	in	std_logic;
		valid_out		:	out	std_logic;
		MAC_DEST_EX		:	in std_logic_vector(47 downto 0);
		MAC_SRC_EX		:	in std_logic_vector(47 downto 0);
		SRC_PORT_EX		:	in	std_logic_vector(1 downto 0);
		DEST_PORT_EX	:	out	std_logic_vector(2 downto 0);
		MAC_DEST_IN		:	out std_logic_vector(47 downto 0);
		MAC_SRC_IN		:	out std_logic_vector(47 downto 0);
		SRC_PORT_IN		:	out	std_logic_vector(1 downto 0);
		DEST_PORT_IN	:	in	std_logic_vector(2 downto 0)
		);
		
end interface;


architecture int_arch	of interface is
COMPONENT DFFE
   PORT (d   : IN STD_LOGIC;
        clk  : IN STD_LOGIC;
        clrn : IN STD_LOGIC;
        prn  : IN STD_LOGIC;
        ena  : IN STD_LOGIC;
        q    : OUT STD_LOGIC );
END COMPONENT;


begin
	-- Throughput from FSM
	ready_out <= ready_in;
	valid_out <= fsm_valid;
	
	-- DFFE for Dest. MAC
	dst_dff : for i in 0 to 47 generate
		dsti : dffe port map(MAC_DEST_EX(i),clock, not reset,'1',ready_in AND valid_in,MAC_DEST_IN(i));
	end generate;
	
	-- DFFE for Src. MAC
	src_dff : for i in 0 to 47 generate
		srci : dffe port map(MAC_SRC_EX(i),clock, not reset,'1',ready_in AND valid_in,MAC_SRC_IN(i));
	end generate;
	
	-- DFFE for Src. Port
	sprt_dff : for i in 0 to 1 generate
		spi : dffe port map(SRC_PORT_EX(i),clock, not reset,'1',ready_in AND valid_in,SRC_PORT_IN(i));
	end generate;
	
	-- DFFE for Dest. Port
	dprt_dff : for i in 0 to 2 generate
		dpi : dffe port map(DEST_PORT_IN(i),clock, not reset,'1',dest_write_en,DEST_PORT_EX(i));
	end generate;
	

end architecture;