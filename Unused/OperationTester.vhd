LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY OperationTester IS
	PORT(LEDR : OUT STD_LOGIC_VECTOR(9 downto 0);
		SW : IN STD_LOGIC_VECTOR(9 downto 0));
END ENTITY OperationTester;

ARCHITECTURE Behavior OF OperationTester IS
    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT AdditionHandler IS
        PORT (
             -- INPUTS
        A_sign : IN STD_LOGIC;                          -- Sign bit of input A
        A_whole : IN STD_LOGIC_VECTOR(4 DOWNTO 0);      -- Whole part of input A
        A_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);         -- Fractional part of input A
        
        B_sign : IN STD_LOGIC;                          -- Sign bit of input B
        B_whole : IN STD_LOGIC_VECTOR(4 DOWNTO 0);      -- Whole part of input B
        B_fp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);         -- Fractional part of input B
        
        -- OUTPUT
        result_magnitude : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) ;
			result_sign : OUT STD_LOGIC;
				result_fp : OUT STD_LOGIC_VECTOR(1 downto 0)
        );
    END COMPONENT;

    -- Testbench signals
    SIGNAL A : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Dividend
    SIGNAL B : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Divisor
    SIGNAL result : STD_LOGIC_VECTOR(6 DOWNTO 0);              -- Result
	 SIGNAL result_sign: STD_LOGIC;

	 SIGNAL result_fp : STD_LOGIC_VECTOR( 1 downto 0);
		BEGIN
    -- Instantiate the Unit Under Test (UUT)
    UUT: AdditionHandler
        PORT MAP (
              -- INPUTS
				  A_sign => '0',
				  A_whole => "11111", --1F
					A_fp => "00",
				  
				  B_sign => '0',
				  B_whole => "11111",--1F
					B_fp => "00",
					
            result_magnitude => result,
				result_sign => result_sign,
				result_fp => result_fp
        );

	 LEDR(5 downto 0) <= result(5 downto 0);
END ARCHITECTURE Behavior;
