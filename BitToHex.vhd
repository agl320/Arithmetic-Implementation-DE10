LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Turns 5 bit input into 2 hex segments
ENTITY BitToHex IS
	PORT (
		bit_sequence : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END ENTITY BitToHex;

ARCHITECTURE BitToHexLogic OF BitToHex IS
 
	COMPONENT SegDecoder IS
		PORT (
			D : IN std_logic_vector(3 DOWNTO 0);
			Y : OUT std_logic_vector(6 DOWNTO 0)
		);
	END COMPONENT;
BEGIN
	SD1 : SegDecoder 
	PORT MAP(
		D => bit_sequence (3 DOWNTO 0), 
		Y => seg0
	);
 
	SD2 : SegDecoder
	PORT MAP(
		D => "000" & bit_sequence(4), 
		Y => seg1
	);
 

END ARCHITECTURE BitToHexLogic;