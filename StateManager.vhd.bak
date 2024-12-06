LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

ENTITY StateManager IS 
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
	);

END ENTITY StateManager;

ARCHITECTURE StateManagerLogic OF StateManager IS

	-- FSM variables
	-- 	sA: idle
	-- 	sB: input1
	-- 	sC: input2
	-- 	sD: operation
	-- 	sE: result/error

	TYPE state_type IS (sA, sB, sC, sD, sE);
	
	SIGNAL y : state_type; 
	SIGNAL y_next : state_type;  
	
	-- 7-seg outputs
	CONSTANT CHAROFF : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111"; 

	-- Clock and initial properties
	BEGIN
	PROCESS(reset, clk)
		BEGIN
		-- reset to sA upon reset trigger
		IF reset = '1' THEN
			y <= sA;
		
		-- upon rising edge, go to next state
		ELSIF RISING_EDGE(clk) THEN
			y <= y_next;
		END IF;
	END PROCESS;
	
	-- FSM Process Logiic
	PROCESS(y)
	BEGIN
		CASE y IS
		
			-- sA : idle state
			WHEN sA =>  
			   
				-- display idle on SEG
				d_1 <= '0';
				d_2 <= '0';
				d_3 <= '0';
			
				-- if next triggered
				IF next_trig = '1' THEN  
				  y_next <= sB;
				
				-- nothing occurs; stay same state
				ELSE
				  y_next <= sA;
				END IF;

			-- sB : input 1 
			WHEN sB =>  
			
				-- display idle on SEG
				d_1 <= '1';
				d_2 <= '0';
				d_3 <= '0';
				
				-- if next triggered and input valid
				-- 	store input in DataManager
				IF next_trig = '1' THEN 
					y_next <= sC;
				
				-- if back triggered, nothing to clear from storage
				ELSIF back_trig = '1' THEN 
					y_next <= sA;
					
				-- nothing occurs
				ELSE
					y_next <= sB;  
					
				END IF;

			-- sC: input 2		
			WHEN sC =>  
			
				-- display idle on SEG
				d_1 <= '0';
				d_2 <= '1';
				d_3 <= '0';
		
				-- if next triggered and input valid
				--	store input in DataManager
				IF next_trig = '1' THEN 
					y_next <= sD;
				
				-- if back triggered, nothing to clear from storage
				ELSIF back_trig = '1' THEN 
					y_next <= sB;
					
				-- nothing occurs
				ELSE
					y_next <= sC;  
					
				END IF;
				
			-- sD : choose operation	
			WHEN sD =>  
			
				-- display idle on SEG
				d_1 <= '1';
				d_2 <= '1';
				d_3 <= '0';
		
				-- if next triggered and input valid
				--	store operation in DataManager
				IF next_trig = '1' THEN 
					y_next <= sE;
				
				-- if back triggered, nothing to clear from storage
				ELSIF back_trig = '1' THEN 
					y_next <= sC;
					
				-- nothing occurs
				ELSE
					y_next <= sD;  
					
				END IF;
				
			-- sE : result/error	
			WHEN sE =>  
			
				-- display idle on SEG
				d_1 <= '0';
				d_2 <= '0';
				d_3 <= '1';
				
				-- if next triggered and input valid
				--	store input in DataManager
				IF next_trig = '1' THEN 
					y_next <= sE;
				
				-- if back triggered, nothing to clear from storage
				ELSIF back_trig = '1' THEN 
					y_next <= sC;
					
				-- nothing occurs
				ELSE
					y_next <= sD;  
					
				END IF;
	END CASE;

END PROCESS;
	


END ARCHITECTURE StateManagerLogic;