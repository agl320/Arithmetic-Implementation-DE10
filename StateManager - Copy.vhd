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
	edit_trig : IN STD_LOGIC;
	
	-- debug output 
	d_1 : OUT STD_LOGIC;
	d_2 : OUT STD_LOGIC;
	d_3 : OUT STD_LOGIC;
	
	d_5 : out STD_LOGIC;
	
	-- input 
	input : IN STD_LOGIC_VECTOR(9 downto 0);
	
	-- output
	seg0 : OUT STD_LOGIC_VECTOR(6 downto 0);
	seg1 : OUT STD_LOGIC_VECTOR(6 downto 0);

	seg2 : OUT STD_LOGIC_VECTOR(6 downto 0);
	seg3 : OUT STD_LOGIC_VECTOR(6 downto 0);

	seg4 : OUT STD_LOGIC_VECTOR(6 downto 0);
	seg5 : OUT STD_LOGIC_VECTOR(6 downto 0)
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
	SIGNAL y_prev : state_type := sA;
	
	-- Toggle edit
	SIGNAL editEnabled : STD_LOGIC := '0';
	
	-- Cached values
	SIGNAL firstWhole : STD_LOGIC_VECTOR(4 downto 0) := "00000";
	SIGNAL firstFloating : STD_LOGIC_VECTOR(1 downto 0) := "00";
	SIGNAL firstSign : STD_LOGIC := '0';
	
	SIGNAL secondWhole : STD_LOGIC_VECTOR(4 downto 0) := "00000";
	SIGNAL secondFloating : STD_LOGIC_VECTOR(1 downto 0) := "00";
	SIGNAL secondSign : STD_LOGIC := '0';
	
	SIGNAL operation : STD_LOGIC_VECTOR(1 downto 0) := "00";
	
	-- 7-seg outputs
	CONSTANT CHAROFF : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";
	CONSTANT DECIMAL : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1110111";
	
	SIGNAL bh_seg0, bh_seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL fp_seg0, fp_seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL op_seg0, op_seg1, op_seg2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_seg0 : STD_LOGIC_VECTOR(6 downto 0);

	SIGNAL bitSequence : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL fpSequence : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL opSequence : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL signSequence : STD_LOGIC;
	
	COMPONENT BitToHex IS
		PORT(		
			bitSequence : IN STD_LOGIC_VECTOR(4 downto 0);
			seg0 : OUT STD_LOGIC_VECTOR(6 downto 0);
			seg1 : OUT STD_LOGIC_VECTOR(6 downto 0)
		);
	END COMPONENT;
	
	COMPONENT OpDecoder IS 
		PORT (
			D : IN STD_LOGIC_VECTOR(1 downto 0);
			X : OUT STD_LOGIC_VECTOR(6 downto 0);
			Y : OUT STD_LOGIC_VECTOR(6 downto 0);
			Z : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;
	
	-- Converts 2 bits to decimal representation in 2 seg
	COMPONENT FpDecoder IS 
		PORT (
			D : IN STD_LOGIC_VECTOR(1 downto 0);
			Y : OUT STD_LOGIC_VECTOR(6 downto 0);
			Z : OUT STD_LOGIC_VECTOR(6 downto 0)
		);
	END COMPONENT;

	COMPONENT SignDecoder IS
    PORT (
        D : IN STD_LOGIC; 
        Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
	END COMPONENT;


	BEGIN
	
	-- Converst 5 bits (whole number) into seg
	BH : BitToHex 
		PORT MAP(
			bitSequence => bitSequence,
			seg0 => bh_seg0,
			seg1 => bh_seg1
		);
		
	-- Convert 2 bit to operation symbol
	OP : OpDecoder 
		PORT MAP(
			D => opSequence,
			X => op_seg2,
			Y => op_seg1, 
			Z => op_seg0
		);
		
	FP : FpDecoder 
		PORT MAP(
			D => fpSequence,
			Y => fp_seg0,
			Z => fp_seg1
		);
	
	S: SignDecoder 
		PORT MAP(
			D => signSequence,
			Y => s_seg0
		);
	
	-- Handling state logic
	PROCESS(reset, clk, editEnabled, edit_trig)
		BEGIN
		-- reset to sA upon reset trigger
		IF reset = '1' THEN
			y <= sA;
		
		-- upon rising edge, go to next state
		ELSIF RISING_EDGE(clk) THEN
			
			IF y_next /= y THEN
				editEnabled <= '0';
			END IF;
			
			-- JK Flip flop" for enabling edits
			-- and y /= sA and y/= sD optional if we don't want edit light to show up
			IF edit_trig = '1' and editEnabled = '0'  THEN
				editEnabled <= '1';
			ELSIF edit_trig = '1' and editEnabled = '1' THEN
				editEnabled <= '0';
			END IF;
			
			IF y = sB THEN
				bitSequence <= firstWhole;
				fpSequence <= firstFloating;
				signSequence <= firstSign;
			ELSIF y = sC THEN 
				bitSequence <= secondWhole;
				fpSequence <= secondFloating;
				signSequence <= secondSign;
			ELSIF y = sD THEN
			-- bit and fp not needed technically
				bitSequence <= "00000";
				fpSequence <= "00";
				signSequence <= '0';
				opSequence <= operation;
			ELSE
				opSequence <= "00";
				bitSequence <= "00000";
				signSequence <= '0';
				fpSequence <= "00";
			END IF;
			
			-- Update previous state
			y <= y_next;
		END IF;
	END PROCESS;
	
	-- Input/Operation Process Logic
	PROCESS(input, edit_trig, editEnabled)
	BEGIN
		IF y = sA or reset = '1' THEN
				firstWhole <= "00000";
				firstFloating <= "00";
				firstSign <= '0';
				
				secondWhole <= "00000";
				secondFloating <= "00";
				secondSign <= '0';
				
				operation <= "00";
		END IF;

		-- if edit_trig triggered, allow edits
		IF editEnabled = '1' THEN
			IF y = sB THEN
				-- whole number
				firstWhole <= input(6 downto 2); 
				-- decimal/floating point
				firstFloating <= input(1 downto 0);
				firstSign <= input(7);
					
			ELSIF y = sC THEN
				-- whole number
				secondWhole <= input(6 downto 2); 
				-- decimal/floating point
				secondFloating <= input(1 downto 0);
				secondSign <= input(7);
				
			ELSIF y = sD THEN
				operation <= input(1 downto 0);
			END IF;
		END IF;
			  
	END PROCESS;
	
	-- FSM Process Logic
	PROCESS(y, next_trig, back_trig)
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
					y_next <= sA;
				
				-- if back triggered, nothing to clear from storage
				ELSIF back_trig = '1' THEN 
					y_next <= sD;
					
				-- nothing occurs
				ELSE
					y_next <= sE;  
					
				END IF;
	END CASE;

END PROCESS;
	PROCESS(y, bh_seg0, bh_seg1, op_seg0, op_seg1, op_seg2)
	BEGIN 
		IF y = sB or y = sC THEN
			seg5 <= s_seg0;
			seg4 <= bh_seg1;
			seg3 <= bh_seg0;
			seg2 <= DECIMAL;
			seg1 <= fp_seg0;	
			seg0 <= fp_seg1;
		ELSIF y = sD THEN
			seg5 <= CHAROFF;
			seg4 <= CHAROFF;
			seg3 <= op_seg0;
			seg2 <= op_seg1;
			seg1 <= op_seg2;
			seg0 <= CHAROFF;
		ELSE
			seg5 <= CHAROFF;
			seg4 <= CHAROFF;
			seg3 <= CHAROFF;
			seg2 <= CHAROFF;
			seg1 <= CHAROFF;
			seg0 <= CHAROFF;
		END IF;
			
	END PROCESS;
					 
	d_5 <= editEnabled;


END ARCHITECTURE StateManagerLogic;