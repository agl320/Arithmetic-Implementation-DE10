LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

ENTITY SystemMap IS
	PORT (
		CLOCK_50: IN STD_LOGIC;
		SW: IN STD_LOGIC_VECTOR(9 downto 0);
		KEY: IN STD_LOGIC_VECTOR(3 downto 0);
		LEDR : OUT STD_LOGIC_VECTOR(9 downto 0);
		HEX0 : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX1 : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX2 : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX3 : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX4 : OUT STD_LOGIC_VECTOR(6 downto 0);
		HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0)
	);

END ENTITY SystemMap;


ARCHITECTURE SystemMapLogic OF SystemMap IS 
	
	-- Slowed clock signal
	SIGNAL clk_internal : STD_LOGIC;
	
	COMPONENT PreScale IS 
		-- generic definitions
		GENERIC (
			N : INTEGER := 24
		);
		-- port definitions
		PORT (clk : IN STD_LOGIC;
				clk_out : OUT STD_LOGIC);
	END COMPONENT;
		
	COMPONENT StateManager IS
		PORT (
			
			-- general ports
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			
			-- state management
			next_trig : IN STD_LOGIC;
			back_trig : IN STD_LOGIC;
			edit_trig : IN STD_LOGIC;
			
			-- debug output 
			d_1 : OUT STD_LOGIC;
			d_2 : OUT STD_LOGIC;
			d_3 : OUT STD_LOGIC;
			
			d_5 : OUT STD_LOGIC;
			
			-- input 
			input : IN STD_LOGIC_VECTOR(9 downto 0);
			
			seg0 : OUT STD_LOGIC_VECTOR(6 downto 0);
			seg1 : OUT STD_LOGIC_VECTOR(6 downto 0);

			seg2 : OUT STD_LOGIC_VECTOR(6 downto 0);
			seg3 : OUT STD_LOGIC_VECTOR(6 downto 0);

			seg4 : OUT STD_LOGIC_VECTOR(6 downto 0);
			seg5 : OUT STD_LOGIC_VECTOR(6 downto 0)
		);
	END COMPONENT;
	
BEGIN
	PS : PreScale
		GENERIC MAP(
			N => 23
		)
		PORT MAP(
			clk => CLOCK_50,
			clk_out => clk_internal
		);

	SM : StateManager
		PORT MAP(
			clk => clk_internal,
			reset => NOT KEY(3),
			next_trig => NOT KEY(0),
			back_trig => NOT KEY(1),
			edit_trig => NOT KEY(2),
			d_1 => LEDR(0),
			d_2 => LEDR(1),
			d_3 => LEDR(2),
			input => SW(9 downto 0),
			seg0 => HEX0,
			seg1 => HEX1,
			seg2 => HEX2,
			seg3 => HEX3,
			seg4 => HEX4,
			seg5 => HEX5,
			d_5 => LEDR(9)
		);
		


END ARCHITECTURE SystemMapLogic;