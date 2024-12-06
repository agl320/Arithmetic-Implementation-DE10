LIBRARY ieee; 
USE ieee.std_logic_1164.all; 

ENTITY OpDecoder IS PORT 
	(
	D : IN STD_LOGIC_VECTOR(1 downto 0);
	X : OUT STD_LOGIC_VECTOR(6 downto 0);
	Y : OUT STD_LOGIC_VECTOR(6 downto 0);
	Z : OUT std_logic_vector(6 downto 0)
	);
END ENTITY OpDecoder;

ARCHITECTURE OpDecoderLogic OF OpDecoder IS 

BEGIN
	PROCESS(D)
		BEGIN
			-- ADD
			IF D = "00" THEN
				X <= "0100001";
				Y <= "0100001";
				Z <= "0001000";
			-- SUB
			ELSIF D = "01" THEN
				X <= "0000011";
				Y <= "1100011";
				Z <= "0010010";
			-- MUL
			ELSIF D = "10" THEN
				X <= "1100111";
				Y <= "1100011";
				Z <= "0001001";
			-- DIV
			ELSIF D = "11" THEN
				X <= "1100011";
				Y <= "1111011";
				Z <= "1000000";
			ELSE
				X <= "1111111";
				Y <= "1111111";
				Z <= "1111111";
			END IF;
	END PROCESS;
	
END ARCHITECTURE OpDecoderLogic;