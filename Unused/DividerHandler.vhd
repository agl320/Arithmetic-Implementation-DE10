LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY DividerHandler IS
    PORT (
	 -- Dividend, 7-bit signed
        A : IN STD_LOGIC_VECTOR(6 DOWNTO 0); 
		  -- Divisor (same format)
        B : IN STD_LOGIC_VECTOR(6 DOWNTO 0); 
		  -- result inluding fraction at end
        Result : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); 
		  -- err signal
        Error : OUT STD_LOGIC
    );
END ENTITY DividerHandler;

ARCHITECTURE DividerHandlerLogic OF DividerHandler IS
	-- signed vals
	SIGNAL signed_A, signed_B : SIGNED(6 DOWNTO 0);
	-- res
	SIGNAL signed_Result : SIGNED(8 DOWNTO 0);
	
	-- internal
	SIGNAL temp_Result : INTEGER;
	SIGNAL fractional_part : INTEGER;
	BEGIN
    -- Convert inputs to signed values
    signed_A <= SIGNED(A);
    signed_B <= SIGNED(B);

    PROCESS(signed_A, signed_B)
    BEGIN
        -- Check for division by zero
        IF signed_B = 0 THEN
            Result <= (OTHERS => '0'); -- Output zero
            Error <= '1'; -- Division by zero error
        ELSE
            Error <= '0'; -- No error

            -- Perform division with truncation
            temp_Result <= TO_INTEGER(signed_A) * 100 / TO_INTEGER(signed_B); -- Scale to 2 decimal places
            fractional_part <= temp_Result MOD 100; -- Get fractional part
            temp_Result <= temp_Result / 100; -- Integer part

            -- Truncate fractional part to 1 decimal
            fractional_part <= fractional_part / 10;

            -- Combine integer and fractional part into 9-bit result
            signed_Result <= TO_SIGNED(temp_Result * 10 + fractional_part, 9);
            Result <= STD_LOGIC_VECTOR(signed_Result); -- Assign to output
        END IF;
    END PROCESS;
END ARCHITECTURE DividerHandlerLogic;