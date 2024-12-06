LIBRARY ieee; 
USE ieee.std_logic_1164.all; 

-- Turns 5 bit input into 2 hex segments
ENTITY BitToHex IS 
	PoRT (
		bitSequence : IN STD_LOGIC_VECTOR(4 downto 0);
		seg0 : OUT STD_LOGIC_VECTOR(6 downto 0);
		seg1 : OUT STD_LOGIC_VECTOR(6 downto 0)
	);
END ENTITY BitToHex;

ARCHITECTURE BitToHexLogic OF BitToHex IS
	
	COMPONENT SegDecoder IS 
		PORT
		(D : in std_logic_vector(3 downto 0);
		Y : out std_logic_vector(6 downto 0));
	END COMPONENT;


BEGIN

	SD1 : SegDecoder	
		PORT MAP(
			D => bitSequence (3 downto 0),
			Y => seg0 
		);
		
	SD2 : SegDecoder
		PORT MAP(
			D => "000" & bitSequence(4),
			Y => seg1
		);
		

END ARCHITECTURE BitToHexLogic;