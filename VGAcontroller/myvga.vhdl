library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
library altera;
use altera.altera_primitives_components.all;

entity myvga is
port (
    clk     : in std_logic;
    rst     : in std_logic;
    red     : out std_logic_vector (9 downto 0);
    green   : out std_logic_vector (9 downto 0);
    blue    : out std_logic_vector (9 downto 0);
    blank   : out std_logic;
    hsync   : out std_logic;
    vsync   : out std_logic);
	end myvga;

architecture basic of myvga is

component vmem is
port (
address : in std_logic_vector  (15 downto 0);
clock : in std_logic;
q    : out std_logic_vector (8 downto 0));
end component;

component Address_Increment is
port (
add_N : in std_logic_vector (15 downto 0);    
sum_N : out std_logic_vector (15 downto 0)
   );
end component;

component incrementXYandReset is
port(
current_x  : in std_logic_vector (9 downto 0);
current_y : in std_logic_vector (9 downto 0);
active_x: in std_logic;
toggle_active_x: in std_logic;
active_y: in std_logic;
toggle_active_y: in std_logic;
next_x  : out std_logic_vector (9 downto 0);
next_y : out std_logic_vector (9 downto 0)
	);
end component;

signal current_x: std_logic_vector(9 downto 0) := "0000000000";
signal next_x : std_logic_vector(9 downto 0);

signal current_y: std_logic_vector(9 downto 0) := "0000000000";
signal next_y : std_logic_vector(9 downto 0);

signal current_hsync: std_logic := '1';
signal current_vsync: std_logic := '1';
signal next_hsync: std_logic;
signal next_vsync: std_logic;

signal toggle_hsync: std_logic;
signal toggle_vsync: std_logic;

signal active_x: std_logic := '1';
signal toggle_active_x: std_logic;
signal next_active_x: std_logic;

signal toggle_active_y: std_logic;
signal active_y: std_logic := '1';
signal next_active_y: std_logic;

signal next_address: std_logic_vector(15 downto 0);
signal address_intermediate: std_logic_vector(15 downto 0); 
signal added_address: std_logic_vector(15 downto 0);
signal current_address: std_logic_vector(15 downto 0) := "0000000000000000";

signal pixel_data: std_logic_vector(8 downto 0);


begin

toggle_hsync <= '1' when (current_x = "1010001111" or current_x = "1011101111") else '0';
toggle_vsync <= '1' when ((current_y = "0111101010" and current_x = "1100011111") or (current_x = "1100011111" and current_y = "0111101100")) else '0';
toggle_active_x <= '1' when (current_x = "1001111111" or current_x = "1100011111") else '0';
toggle_active_y <= '1' when ((current_y = "0111011111" and current_x = "1100011111") or (current_x = "1100011111" and current_y = "1000001011")) else '0';

hsync <= '1' when (current_x = "0000000000") else current_hsync;
vsync <= '1' when (current_y = "0000000000") else current_vsync;
next_hsync <= '1' when (current_x = "0000000000") else (current_hsync XOR toggle_hsync);
next_vsync <= '1' when (current_y = "0000000000") else (current_vsync XOR toggle_vsync);

next_active_x <= '1' when (current_x = "0000000000") else active_x XOR toggle_active_x;
next_active_y <= '1' when (current_y = "0000000000") else active_y XOR toggle_active_y; 

blank <= '1' when (current_x = "0000000000" and current_y = "0000000000") else active_x AND active_y;

address_intermediate <= added_address when (((current_x(3) XOR next_x(3)) AND (active_x AND active_y)) = '1') else current_address;
next_address <= "0000000000000000" when (current_y = "1000001011" and current_x = "1100011111") else address_intermediate;

-- Gives the pixel data to the VGA controller.

red <= pixel_data(8 downto 6) & "0000000" when ((active_x AND active_y) = '1') else "0000000000";
green <= pixel_data(5 downto 3) & "0000000" when ((active_x AND active_y) = '1') else "0000000000";
blue <= pixel_data(2 downto 0) & "0000000" when ((active_x AND active_y) = '1') else "0000000000";

address_adder: Address_Increment PORT MAP(
add_N => current_address(15 downto 0),
sum_N => added_address(15 downto 0)
);

assignVmem: vmem PORT MAP(
address => current_address,
clock => clk,
q    => pixel_data(8 downto 0)
);

incrementXY: incrementXYandReset PORT MAP(
current_x => current_x,
current_y => current_y,
active_x => active_x,
toggle_active_x => toggle_active_x,
active_y => active_y,
toggle_active_y => toggle_active_y,
next_x => next_x,
next_y => next_y
);

address_dff: for i in 15 downto 0 generate
address_state : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_address(i),
q   => current_address(i));
end generate address_dff;

x_loc_dff: for i in 9 downto 0 generate
x_state : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_x(i),
q   => current_x(i));
end generate x_loc_dff;

y_loc_dff: for i in 9 downto 0 generate
y_state : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_y(i),
q   => current_y(i));
end generate y_loc_dff;

hsync_state : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_hsync,
q   => current_hsync);

vsync_state : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_vsync,
q   => current_vsync);

active_x_label : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_active_x,
q   => active_x);

active_y_label : dff port map (
clk => clk,
clrn => not(rst),
prn => '1',
d   => next_active_y,
q   => active_y
); 

end basic;