LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Turns 5 bit input into 2 hex segments
ENTITY ResultToHex IS
	PORT (
		-- OUTPUT
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
END ENTITY ResultToHex;

ARCHITECTURE ResultToHexLogic OF ResultToHex IS

	COMPONENT SegDecoder IS
		PORT (
			D : IN std_logic_vector(3 DOWNTO 0);
			Y : OUT std_logic_vector(6 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT FpDecoder IS
		PORT (
			D : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			Z : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;
BEGIN
	FPD : FpDecoder
	PORT MAP(
		D => result_fp, 
		Y => seg0, 
		Z => OPEN
	);

	seg1 <= "1110111";

	SD2 : SegDecoder
	PORT MAP(
		D => result_magnitude(3 DOWNTO 0), 
		Y => seg2
	);

	SD3 : SegDecoder
	PORT MAP(
		D => result_magnitude(7 DOWNTO 4), 
		Y => seg3
	);

	SD4 : SegDecoder
	PORT MAP(
		D => result_magnitude(11 DOWNTO 8), 
		Y => seg4
	);
	-- sign decoder 1bit
	seg5 <= "1111111" WHEN result_sign = '0' ELSE "0111111";

END ARCHITECTURE ResultToHexLogic;