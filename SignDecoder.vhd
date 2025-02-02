LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SignDecoder IS
	PORT (
		D : IN STD_LOGIC;
		Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END ENTITY SignDecoder;

ARCHITECTURE SignDecoderLogic OF SignDecoder IS
BEGIN
	PROCESS (D)
	BEGIN
		CASE D IS
			WHEN '0' => 
				Y <= "1111111";
			WHEN '1' => 
				Y <= "0111111";
		END CASE;
	END PROCESS;
END ARCHITECTURE SignDecoderLogic;