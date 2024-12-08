LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FpDecoder IS
    PORT (
        D : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
        Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
        Z : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) 
    );
END ENTITY FpDecoder;

ARCHITECTURE FpDecoderLogic OF FpDecoder IS
BEGIN
    
    PROCESS(D)
    BEGIN
        CASE D IS
            WHEN "00" =>  -- 0.00
                Y <= "1000000"; -- '0'
                Z <= "1000000"; -- '0'
            WHEN "01" =>  -- 0.25
                Y <= "0100100"; -- '2'
                Z <= "0010010"; -- '5'
            WHEN "10" =>  -- 0.50
                Y <= "0010010"; -- '5'
                Z <= "1000000"; -- '0'
            WHEN "11" =>  -- 0.75
                Y <= "1111000"; -- '7'
                Z <= "0010010"; -- '5'
            WHEN OTHERS => 
                Y <= "1111111"; 
                Z <= "1111111"; 
        END CASE;
    END PROCESS;
END ARCHITECTURE FpDecoderLogic;