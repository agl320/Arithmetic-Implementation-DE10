LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ArithmeticCore IS
	PORT (
		operation : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- INPUTS
		A_sign : IN STD_LOGIC;
		A_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		A_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		B_sign : IN STD_LOGIC;
		B_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		B_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- OUTPUT
		result_magnitude : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		result_sign : OUT STD_LOGIC;
		result_fp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		error : OUT STD_LOGIC
	);
END ENTITY ArithmeticCore;

ARCHITECTURE ArithmeticCoreLogic OF ArithmeticCore IS
	SIGNAL signed_A, signed_B : SIGNED(7 DOWNTO 0);
	SIGNAL result : SIGNED(15 DOWNTO 0);
BEGIN
	PROCESS (A_sign, A_magnitude, B_sign, B_magnitude, A_fp, B_fp)
	BEGIN
		-- 2s compl if needed
		-- mag separate
		IF A_sign = '1' THEN
			signed_A <= - SIGNED('0' & A_magnitude & A_fp);
		ELSE
			signed_A <= SIGNED('0' & A_magnitude & A_fp);
		END IF;
		IF B_sign = '1' THEN
			signed_B <= - SIGNED('0' & B_magnitude & B_fp);
		ELSE
			signed_B <= SIGNED('0' & B_magnitude & B_fp);
		END IF;

		-- CHOOSE OPERATION
		CASE operation IS
			WHEN "00" => 
				-- Addition
				result <= RESIZE(signed_A, 16) + RESIZE(signed_B, 16);
				error <= '0';
			WHEN "01" => 
				-- Subtraction
				result <= RESIZE(signed_A, 16) - RESIZE(signed_B, 16);
				error <= '0';
			WHEN "10" => 
				-- Multiplication
				-- cannot be outside these bounds
				IF (A_magnitude = "11111" AND A_fp /= "00") AND (B_magnitude = "11111" AND B_fp /= "00") THEN
					result <= (OTHERS => '0');
					error <= '1';
				ELSE
					-- scaling factor to account for 2 bit fp * 2 bit fp -> truncate by 2
					result <= RESIZE((RESIZE(signed_A, 16) * RESIZE(signed_B, 16)) / 4, 16);
					error <= '0';
				END IF;
			WHEN "11" => 
				-- Division
				-- Check div by zero -> err
				IF B_magnitude = "00000" AND B_fp = "00" THEN
					result <= (OTHERS => '0');
					error <= '1';
				ELSE
					--result <= RESIZE((RESIZE(signed_A, 16) * RESIZE(signed_B, 16)) / 4, 16);
					result <= RESIZE((RESIZE(signed_A, 16) * 4) / RESIZE(signed_B, 16), 16);
					error <= '0';
				END IF;
			WHEN OTHERS => 
				result <= (OTHERS => '0');
				error <= '1';
		END CASE;
		IF result < 0 THEN
			result_sign <= '1';

			result_magnitude <= STD_LOGIC_VECTOR( - result(13 DOWNTO 2));
			result_fp <= STD_LOGIC_VECTOR( - result(1 DOWNTO 0));
		ELSE
			result_sign <= '0';

			result_magnitude <= STD_LOGIC_VECTOR(result(13 DOWNTO 2));

			result_fp <= STD_LOGIC_VECTOR(result(1 DOWNTO 0));
		END IF;
	END PROCESS;
END ARCHITECTURE ArithmeticCoreLogic;