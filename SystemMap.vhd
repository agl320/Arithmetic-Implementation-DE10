LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

ENTITY SystemMap IS
	PORT (
			CLOCK_50: IN STD_LOGIC;
			SW: IN STD_LOGIC_VECTOR(9 downto 0);
			KEY: IN STD_LOGIC_VECTOR(3 downto 0);
			LEDR : OUT STD_LOGIC_VECTOR(9 downto 0)
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
			
			-- debug output 
			d_1 : OUT STD_LOGIC;
			d_2 : OUT STD_LOGIC;
			d_3 : OUT STD_LOGIC
		-- 
		);
	END COMPONENT;
	
BEGIN
	PS : PreScale
		GENERIC MAP(
			N => 12
		)
		PORT MAP(
			clk => CLOCK_50,
			clk_out => clk_internal
		);

	SM : StateManager
		PORT MAP(
			clk => clk_internal,
			reset => KEY(2),
			next_trig => KEY(0),
			back_trig => KEY(1),
			d_1 => LEDR(0),
			d_2 => LEDR(1),
			d_3 => LEDR(2)
		);
		


END ARCHITECTURE SystemMapLogic;