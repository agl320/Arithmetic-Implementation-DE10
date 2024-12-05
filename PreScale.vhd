LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

-- N Bit prescaler
ENTITY PreScale IS
-- generic definitions
	GENERIC (
		N : INTEGER := 24
	);
-- port definitions
	PORT (clk : IN STD_LOGIC;
			clk_out : OUT STD_LOGIC);

END ENTITY PreScale;

ARCHITECTURE PreScaleLogic OF PreScale IS
-- signal definitions
	SIGNAL acc : UNSIGNED(N downto 0) := (others => '0');
	
-- logic
	BEGIN
	
		PROCESS(clk)
		BEGIN
			
			IF rising_edge(clk) THEN
				-- Acc resets to 0 when acc reaches 2^24-1
				--   Cannot compare with (others => '1') as unconstrained
				--   thus we compare with max value
				-- TO_UNSIGNED technically not needed
				IF acc = (2**(N+1) - 1)
					THEN acc <= (others => '0');
			
				ELSE
					-- increment acc (clk_out) by 1
					acc <= acc + 1;
					
				END IF;
			END IF;
		END PROCESS;
		
		-- assign msb to clk_out
		clk_out <= acc(N);

END ARCHITECTURE PreScaleLogic;