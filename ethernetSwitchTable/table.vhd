library ieee;
use ieee.std_logic_1164.all;

entity table is
	port(
		clk			:	in	std_logic;
		rst			:	in	std_logic;
		vld_in		:	in std_logic;
		dest_add		:	in	std_logic_vector(47 downto 0);
		src_add		:	in	std_logic_vector(47 downto 0);
		src_port 	:	in std_logic_vector(1 downto 0);
		vld_out		:	out	std_logic;
		ready 		:	out	std_logic;
		dest_port 	:	out	std_logic_vector(2 downto 0)
		);
end table;

architecture tb	of	table is
component interface is
	port(
		clock				:	in	std_logic;
		reset				:	in std_logic;
		ready_in			:	in	std_logic;
		ready_out		:	out	std_logic;
		valid_in			:	in std_logic;
		fsm_valid		:	in	std_logic;
		dest_write_en 	: in std_logic;
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
end component;

component FSM_table is
	port(
		clock				:	in	 std_logic;
		reset				:	in	 std_logic;
		ready				:  out std_logic;
		valid_in			:  in  std_logic;
		valid_out		:	out std_logic;
		write_enable   :  out std_lOGIC;
		read_mux			:  out std_lOGIC;
		enable_src		: 	out std_logic;
		enable_dest		:  out	std_logic;
		dest_found		:	in  std_logic_vector(1 downto 0);
		source_found	:	in  std_logic_vector(2 downto 0);
		LRU_delete_vld	: 	in  std_lOGIC;
		LRU_vldbit		:	out std_logic;
		reset_dest		:	out std_logic;
		reset_src		: 	out std_logic;
		destregwriten	:  out std_logic);
end component;

component compare_source is
	port(
		clock					:	in	 std_logic;
		reset					:	in	 std_logic;
		cs_enable			:	in	std_logic;
		MAC_source			:	in  std_logic_vector(47 downto 0);
		Source_port			: 	in  std_logic_vector(1 downto 0);
		fromTable1			:	in	 std_logic_vector(50 downto 0);
		fromTable2			:	in	 std_logic_vector(50 downto 0);
		index1				:	out std_logic_vector(4 downto 0);
		index2				:	out std_logic_vector(4 downto 0);
		src_working_valid : out std_logic; 
		results				:	out std_logic_vector(2 downto 0);
		outIndex				:	out std_logic_vector(4 downto 0);
		outData				:	out std_logic_vector(47 downto 0);
		outPort				:	out std_logic_vector(1 downto 0);
		wr_en					:	out std_logic);
end component;

component compare_dest is
	port(
		clock				:	in	 std_logic;
		reset				:	in	 std_logic;
		natural_reset  :  in  std_logic;
		cd_enanble		:	in	 std_logic;
		MAC_dest			:	in  std_logic_vector(47 downto 0);
		fromTable1		:	in	 std_logic_vector(50 downto 0);
		fromTable2		:	in	 std_logic_vector(50 downto 0);
		index1			:	out std_logic_vector(4 downto 0);
		index2			:	out std_logic_vector(4 downto 0);
		results			:	out std_logic_vector(1 downto 0);
		outPort			:	out std_logic_vector(1 downto 0);
		outAdd			:	out std_logic_vector(47 downto 0);
		outIndex 		:  out std_logic_vector(4 downto 0);
		outValid			:	out std_logic;
		outPort_saved 	: 	out std_logic_vector(1 downto 0);
		results_saved	:	out std_logic_vector(1 downto 0);
		wr_en				:	out std_logic);
end component;

component table_cleaner is
	port(
		clock, reset					: in std_logic;
		vld_in							: in std_logic; -- this signal and the next one signal the frame is over
		table_subsystem_rdy			: in std_logic; 
		write_en							: in std_lOGIC;
		write_vld_bit					: in std_lOGIC; -- this signal determines if the FSM is writing a new value to the table or deleting a value from the table
		write_index						: in std_logic_vector(4 downto 0);
		cmpr_destination_done		: in std_LOGIC;
		cmpr_destination_found		: in std_logic;
		read_dest_index				: in std_lOGIC_vector(4 downto 0);
		cmpr_source_done				: in std_lOGIC;
		cmpr_source_found				: in std_logic;
		read_source_index				: in std_lOGIC_vector(4 downto 0);
		LRU_delete_vld					: out std_lOGIC;
		LRU_index						: out std_lOGIC_vector(4 downto 0);
		Second_LRU_index				: out std_lOGIC_vector(4 downto 0));
end component;

component reg_file is
	port(
		clk		:	in	std_logic;
		reset		:	in	std_logic;
		wr_en		:	in	std_logic;
		r_add_1	:	in std_logic_vector(4 downto 0);
		r_add_2	:	in	std_logic_vector(4 downto 0);
		w_add		:	in	std_logic_vector(4 downto 0);
		w_valid	:	in std_logic;
		w_port	:	in std_logic_vector(1 downto 0);
		w_info	:	in	std_logic_vector(47 downto 0);
		r_data_1	:	out	std_logic_vector(50 downto 0);
		r_data_2	:	out	std_logic_vector(50 downto 0));
end component;

		signal	D_IN							:	std_logic_vector(47 downto 0);
		signal 	S_IN							:  std_logic_vector(47 downto 0);
		signal 	SP								:	std_logic_vector(1 downto 0);
		signal 	DP								:	std_logic_vector(2 downto 0);
		signal 	f_r_out						:	std_lOGIC;
		signal 	we1							:	std_logic;
		signal 	we2 							:  std_logic; 
		signal 	mux 							:	std_logic;
		signal 	s_idx							:	std_logic_vector(4 downto 0);
		signal	d_idx							:	std_logic_vector(4 downto 0);
		signal	s_fnd							:	std_logic_vector(2 downto 0);
		signal	d_fnd 						:	std_logic_vector(1 downto 0);
		signal	lru_d							:	std_logic;
		signal	lru_idx_1					:	std_logic_vector(4 downto 0);
		signal	lru_idx_2					:	std_logic_vector(4 downto 0);
		signal	reg_we						:	std_logic;
		signal	v_out							:	std_logic;
		signal 	s_idx_1						:	std_logic_vector(4 downto 0);
		signal 	s_idx_2						:	std_logic_vector(4 downto 0);
		signal 	d_idx_1						:	std_logic_vector(4 downto 0);
		signal 	d_idx_2						:	std_logic_vector(4 downto 0);
		signal   w_Source_Add 				:	std_logic_vector(47 downto 0); 
		signal   w_Dest_Add 					:	std_logic_vector(47 downto 0);
		signal	r_add_1						:	std_logic_vector(4 downto 0);
		signal	r_add_2						:	std_logic_vector(4 downto 0);		
		signal 	src_working_valid 		:  std_logic; 
		signal 	enable_source				:	std_logic;
		signal 	enable_dest 				: std_logic;
		signal 	LRU_valid 					:  std_logic;
		signal 	r_data_1 					: std_logic_vector(50 downto 0);
		signal 	r_data_2 					: std_logic_vector (50 downto 0);
		signal 	w_info 						: std_logic_vector (47 downto 0);
		signal 	w_add 						: std_logic_vector (4 downto 0);
		signal 	w_valid 						: std_logic;
		signal 	w_port 						: std_logic_vector (1 downto 0);
		signal 	cmpr_source_done 			: std_logic;
		signal 	cmpr_destination_done 	: std_logic;
		signal 	cmpr_source_found 		: std_logic;
		signal 	cmpr_destination_found 	: std_logic;
		signal 	dest_write_en 				: std_logic;
		signal 	reset_dest 					: std_logic;
		signal 	reset_src 					: std_logic;
		signal 	w_port_src 					: std_logic_vector (1 downto 0);
		signal 	w_port_dest 				: std_logic_vector (1 downto 0);
		signal 	outPort_saved 				: std_logic_vector (1 downto 0);
		signal 	results_saved 				: std_logic_vector (1 downto 0);

begin
	interface_inst : interface port map(
		clock 			=> clk,
		reset 			=> rst,
		ready_in		 	=> f_r_out,
		ready_out		 => ready,
		valid_in	 		=> vld_in,
		FSM_valid 		=> v_out, 
		valid_out 		=> vld_out,
		dest_write_en	=> dest_write_en, 
		MAC_DEST_EX 	=> dest_add,
		MAC_SRC_EX 		=> src_add,
		SRC_PORT_EX 	=> src_port,
		DEST_PORT_EX 	=> dest_port,
		MAC_DEST_IN 	=> D_IN,
		MAC_SRC_IN 		=> S_IN,
		SRC_PORT_IN 	=> SP,
		DEST_PORT_IN 	=> results_saved(0) & outPort_saved);
		
		
	
	FSM_table_inst : FSM_table port map (
		clock 				=> clk,
		reset 				=> rst,
		ready					=> f_r_out,
		valid_in 			=> vld_in,
		valid_out 			=> v_out,
		write_enable 		=> reg_we,
		enable_src 			=> enable_source,
		enable_dest 		=> enable_dest,
		read_mux 			=> mux,
		dest_found 			=> d_fnd,
		source_found 		=> s_fnd,
		LRU_delete_vld 	=> lru_d,
		LRU_vldbit 			=> LRU_valid,
		reset_dest			=> reset_dest,
		reset_src 			=> reset_src,
		destregwriten 		=> dest_write_en);
		
		
		r_add_1 <= s_idx_1 when (mux = '0' and src_working_valid ='1') else d_idx_1;
		r_add_2 <= s_idx_2 when (src_working_valid = '1') else d_idx_2;
		
		compare_source_inst : compare_source port map (
		clock						=> clk,
		reset						=> rst or reset_src,
		cs_enable 				=> enable_source,
		MAC_source 				=> S_IN,
		Source_port				=> SP,
		fromTable1				=> r_data_1,
		fromTable2				=> r_data_2,
		index1 					=> s_idx_1,
		index2 					=> s_idx_2,
		results 					=> s_fnd,
		src_working_valid 	=> src_working_valid,
		outIndex					=> s_idx,
		outData					=> w_source_Add,
		outPort 					=> w_port_Src,
		wr_en						=> we1);
		
		compare_dest_inst : compare_dest port map (
		clock 			=> clk,
		reset				=> rst or reset_dest,
		natural_reset 	=> rst,
		cd_enanble		=> enable_dest,
		MAC_dest			=> D_IN,
		fromTable1		=> r_data_1,
		fromTable2		=> r_data_2,
		index1			=> d_idx_1,
		index2			=> d_idx_2 ,
		results			=> d_fnd,
		outPort			=> w_port_dest,
		outAdd			=>	w_dest_Add,
		outIndex 		=> d_idx,
		outPort_saved 	=> outPort_saved,
		results_saved 	=> results_saved,
		wr_en				=> we2);
		
		cmpr_destination_done <= d_fnd(1);
		cmpr_destination_found <= d_fnd(0);
		cmpr_source_done <= s_fnd(2);
		cmpr_source_found <= s_fnd(1);
		
		table_cleaner_inst : table_cleaner port map(
		clock 							=> clk,
		reset 							=> rst,
		vld_in 							=> vld_in, -- this signal and the next one signal the frame is over
		table_subsystem_rdy 			=> f_r_out ,
		write_en 						=> reg_we OR we1 OR we2,
		write_vld_bit 					=> w_valid,  -- w_data[50], -- this signal determines if the FSM is writing a new value to the table or deleting a value from the table
		write_index						=> w_add,
		cmpr_destination_done 		=> cmpr_destination_done,
		cmpr_destination_found 		=> cmpr_destination_found,
		read_dest_index 				=> d_idx,
		cmpr_source_done 				=> cmpr_source_done,
		cmpr_source_found 			=> cmpr_source_found,
		read_source_index 			=> s_idx,
		LRU_delete_vld 				=> lru_d,
		LRU_index 						=> lru_idx_1
);


w_info <= w_Source_Add when (we1 = '1') else w_Dest_Add when (we2 ='1') else S_IN when (reg_we = '1' and LRU_valid = '1') else ("000000000000000001011110000000000000000000000000") ;
w_port <= w_port_src when (we1 = '1') else w_port_dest when (we2 ='1') else SP when (reg_we = '1' and LRU_valid = '1') else ("00");
w_valid <= '0' when (LRU_valid = '0' AND reg_we ='1') else '1';
w_add <= s_idx when (we1 ='1') else d_idx when (we2 ='1') else lru_idx_1;


reg_file_inst : reg_file port map(
		clk 			=> clk	,
		reset			=> rst,
		wr_en			=> reg_we OR we1 OR we2,
		r_add_1		=> r_add_1,
		r_add_2		=> r_add_2,
		w_add			=> w_add,
		w_valid		=> w_valid,
		w_port		=> w_port,
		w_info		=> w_info , 
		r_data_1 	=> r_data_1	,
		r_data_2		=> r_data_2);





end architecture;