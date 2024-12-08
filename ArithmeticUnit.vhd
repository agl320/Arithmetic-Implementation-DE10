LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ArithmeticUnit IS
	PORT (
		-- INPUTS
		A_sign : IN STD_LOGIC;
		A_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		A_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		B_sign : IN STD_LOGIC;
		B_magnitude : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		B_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		operation : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- OUTPUTS
		result_magnitude : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		result_sign : OUT STD_LOGIC;
		result_fp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		-- Error signal
		error : OUT STD_LOGIC
	);
END ENTITY ArithmeticUnit;

ARCHITECTURE ArithmeticUnitLogic OF ArithmeticUnit IS

	-- ADD RESULTS
	SIGNAL result_magnitude_int : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL result_sign_int : STD_LOGIC;
	SIGNAL result_fp_int : STD_LOGIC_VECTOR(1 DOWNTO 0);
 
	SIGNAL error_int : STD_LOGIC;

	COMPONENT ArithmeticCore IS
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
	END COMPONENT;
BEGIN
	-- adder handler
	AH : ArithmeticCore
	PORT MAP(
		operation => operation, 
 
		-- INPUTS
		A_sign => A_sign, 
		A_magnitude => A_magnitude, 
		A_fp => A_fp, 

		B_sign => B_sign, 
		B_magnitude => B_magnitude, 
		B_fp => B_fp, 
		-- RESULTS
		result_magnitude => result_magnitude_int, 
		result_sign => result_sign_int, 
		result_fp => result_fp_int, 
		error => error_int
	);

	PROCESS (operation)

	BEGIN
		result_magnitude <= result_magnitude_int;
		result_sign <= result_sign_int;
		result_fp <= result_fp_int;
 
		--TODO : CHECK FOR DIVISION BY ZERO (or bounds)
		error <= error_int;

	END PROCESS;

END ARCHITECTURE ArithmeticUnitLogic;