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
 
		d_5 : OUT STD_LOGIC;
 
		-- input
		input : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
 
		-- output
		seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		seg2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		seg3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		seg4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		seg5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
 
END ENTITY StateManager;

ARCHITECTURE StateManagerLogic OF StateManager IS

	-- FSM VARS
	-- sA: idle
	-- sB: input1
	-- sC: input2
	-- sD: operation
	-- sE: result/error

	TYPE state_type IS (sA, sB, sC, sD, sE);
 
	SIGNAL y : state_type;
	SIGNAL y_next : state_type; 
	SIGNAL y_prev : state_type := sA;
 
	-- TOGGLE EDIT
	SIGNAL editEnabled : STD_LOGIC := '0';
 
	-- CACHED/STORED VALUES
	SIGNAL first_magnitude : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
	SIGNAL first_fp : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL first_sign : STD_LOGIC := '0';
 
	SIGNAL second_magnitude : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
	SIGNAL second_fp : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	SIGNAL second_sign : STD_LOGIC := '0';
 
	SIGNAL operation : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
 
	-- INPUT INTO COMPONENTS
	SIGNAL bit_sequence : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL fp_sequence : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL op_sequence : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL sign_sequence : STD_LOGIC;
 
	-- OUTPUT VARS
	CONSTANT CHAR_OFF : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111";
	CONSTANT CHAR_DECIMAL : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1110111";
	CONSTANT CHAR_E : STD_LOGIC_VECTOR(6 downto 0) := "0000110";
	CONSTANT CHAR_R : STD_LOGIC_VECTOR(6 downto 0) := "0101111";
	CONSTANT CHAR_I : STD_LOGIC_VECTOR(6 downto 0) := "1111001";
	CONSTANT CHAR_D : STD_LOGIC_VECTOR(6 downto 0) := "1000000";
	CONSTANT CHAR_L : STD_LOGIC_VECTOR(6 downto 0) := "1000111";

	-- HEX SEGMENTS
	SIGNAL bh_seg0, bh_seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL fp_seg0, fp_seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL op_seg0, op_seg1, op_seg2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL s_seg0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
 
	-- RESULT
	-- note: change size later to account for multiplication
	SIGNAL result_magnitude : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
	SIGNAL result_sign : STD_LOGIC := '0';
	-- will truncate and only use one
	SIGNAL result_fp : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
 
	SIGNAL res_seg0 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	SIGNAL res_seg1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	SIGNAL res_seg2 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	SIGNAL res_seg3 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	SIGNAL res_seg4 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
	SIGNAL res_seg5 : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');

	-- ERROR SIGNAL
	SIGNAL error : STD_LOGIC := '0';
 
	COMPONENT BitToHex IS
		PORT (
			bit_sequence : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
 
	COMPONENT OpDecoder IS
		PORT (
			D : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			X : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			Z : OUT std_logic_vector(6 DOWNTO 0)
		);
	END COMPONENT;
 
	-- Converts 2 bits to decimal representation in 2 seg
	COMPONENT FpDecoder IS
		PORT (
			D : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			Z : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT SignDecoder IS
		PORT (
			D : IN STD_LOGIC;
			Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
 
	COMPONENT ArithmeticUnit IS
		PORT (
			A_sign : IN STD_LOGIC; -- Sign bit of input A
			A_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Whole part of input A
			A_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

			B_sign : IN STD_LOGIC; -- Sign bit of input B
			B_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Whole part of input B
			B_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

			operation : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

			-- OUTPUTS
			result_magnitude : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
			result_sign : OUT STD_LOGIC;
			result_fp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

			-- Error signal
			error : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT ResultToHex IS

		PORT (-- OUTPUT
			result_magnitude : IN STD_LOGIC_VECTOR(11 DOWNTO 0); 
			result_sign : IN STD_LOGIC;
			result_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
 
			-- Floating point
			seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			-- Whole
			seg2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			-- Sign
			seg5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

BEGIN
	-- Converst 5 bits (whole number) into seg
	BH : BitToHex
	PORT MAP(
		bit_sequence => bit_sequence, 
		seg0 => bh_seg0, 
		seg1 => bh_seg1
	);
 
	-- Convert 2 bit to operation symbol
	OP : OpDecoder
	PORT MAP(
		D => op_sequence, 
		X => op_seg2, 
		Y => op_seg1, 
		Z => op_seg0
	);
 
	FP : FpDecoder
	PORT MAP(
		D => fp_sequence, 
		Y => fp_seg0, 
		Z => fp_seg1
	);
 
	S : SignDecoder
	PORT MAP(
		D => sign_sequence, 
		Y => s_seg0
	);
 
	OPH : ArithmeticUnit
	PORT MAP(
		A_sign => first_sign, 
		A_magnitude => first_magnitude, 
		A_fp => first_fp, 

		B_sign => second_sign, 
		B_magnitude => second_magnitude, 
		B_fp => second_fp, 

		operation => operation, 

		-- OUTPUTS
		result_magnitude => result_magnitude, 
		result_sign => result_sign, 
		result_fp => result_fp, 

		-- Error signal
		error => error
	);
 
	RH : ResultToHex
	PORT MAP(
		result_magnitude => result_magnitude, 
		result_sign => result_sign, 
		result_fp => result_fp, 
		seg0 => res_seg0, 
		seg1 => res_seg1, 
		seg2 => res_seg2, 
		seg3 => res_seg3, 
		seg4 => res_seg4, 
		seg5 => res_seg5
	);

 
	-- Handling state logic
	PROCESS (reset, clk)
	BEGIN
		-- reset to sA upon reset trigger
		IF reset = '1' THEN
			editEnabled <= '0';
			y <= sA;
 
			-- upon rising edge, go to next state
		ELSIF RISING_EDGE(clk) THEN
 
		--	IF y_next /= y THEN
		--		editEnabled <= '0';
		--	END IF;
 
			-- JK Flip flop" for enabling edits
			-- and y /= sA and y/= sD optional if we don't want edit light to show up
			IF edit_trig = '1' AND editEnabled = '0' THEN
				editEnabled <= '1';
			ELSIF edit_trig = '1' AND editEnabled = '1' THEN
				editEnabled <= '0';
			END IF;
 
			IF y = sB THEN
				bit_sequence <= first_magnitude;
				fp_sequence <= first_fp;
				sign_sequence <= first_sign;
			ELSIF y = sC THEN
				bit_sequence <= second_magnitude;
				fp_sequence <= second_fp;
				sign_sequence <= second_sign;
			ELSIF y = sD THEN
				-- bit and fp not needed technically
				bit_sequence <= "00000";
				fp_sequence <= "00";
				sign_sequence <= '0';
				op_sequence <= operation;
			ELSE
				op_sequence <= "00";
				bit_sequence <= "00000";
				sign_sequence <= '0';
				fp_sequence <= "00";
			END IF;
 
			-- Update previous state
			y <= y_next;
		END IF;
	END PROCESS;
 
	-- Input/Operation Process Logic
	PROCESS (clk, reset, y, editEnabled)
		BEGIN
			IF y = sA OR reset = '1' THEN
				first_magnitude <= "00000";
				first_fp <= "00";
				first_sign <= '0';
 
				second_magnitude <= "00000";
				second_fp <= "00";
				second_sign <= '0';
 
				operation <= "00";
			END IF;

			-- if edit_trig triggered, allow edits
			-- must check for state switch, otherwise will reset upon back
			IF editEnabled = '1' AND y = y_next THEN
				IF y = sB THEN
					-- whole number
					first_magnitude <= input(6 DOWNTO 2);
					-- decimal/floating point
					first_fp <= input(1 DOWNTO 0);
					first_sign <= input(7);
 
				ELSIF y = sC THEN
					-- whole number
					second_magnitude <= input(6 DOWNTO 2);
					-- decimal/floating point
					second_fp <= input(1 DOWNTO 0);
					second_sign <= input(7);
 
				ELSIF y = sD THEN
					operation <= input(1 DOWNTO 0);
				END IF;
			END IF;
 
		END PROCESS;
 
		-- FSM Process Logic
		PROCESS (y, next_trig, back_trig)
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
						-- store input in DataManager
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
						-- store input in DataManager
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
						-- store operation in DataManager
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
						-- store input in DataManager
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
			PROCESS (y, bh_seg0, bh_seg1, op_seg0, op_seg1, op_seg2)
				BEGIN
						IF y = sA THEN
							seg5 <= CHAR_OFF;
							seg4 <= CHAR_I;
							seg3 <= CHAR_D;
							seg2 <= CHAR_L;
							seg1 <= CHAR_E; 
							seg0 <= CHAR_OFF;
						ELSIF y = sB OR y = sC THEN
							seg5 <= s_seg0;
							seg4 <= bh_seg1;
							seg3 <= bh_seg0;
							seg2 <= CHAR_DECIMAL;
							seg1 <= fp_seg0; 
							seg0 <= fp_seg1;
						ELSIF y = sD THEN
							seg5 <= CHAR_OFF;
							seg4 <= CHAR_OFF;
							seg3 <= op_seg0;
							seg2 <= op_seg1;
							seg1 <= op_seg2;
							seg0 <= CHAR_OFF;
						ELSIF y = sE THEN
							IF error /= '1' THEN
								seg5 <= res_seg5;
								seg4 <= res_seg4;
								seg3 <= res_seg3;
								seg2 <= res_seg2;
								seg1 <= res_seg1;
								seg0 <= res_seg0;
							ELSE
								seg5 <= CHAR_OFF;
								seg4 <= CHAR_OFF;
								seg3 <= CHAR_E;
								seg2 <= CHAR_R;
								seg1 <= CHAR_R;
								seg0 <= CHAR_OFF;
							END IF;
						ELSE
							seg5 <= CHAR_OFF;
							seg4 <= CHAR_OFF;
							seg3 <= CHAR_OFF;
							seg2 <= CHAR_OFF;
							seg1 <= CHAR_OFF;
							seg0 <= CHAR_OFF;
						END IF;
					
				END PROCESS;
 
				d_5 <= editEnabled;
END ARCHITECTURE StateManagerLogic;