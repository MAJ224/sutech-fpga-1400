-- Clock divider module to get 1 second clock 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk_div is

port (
   clk: in std_logic;
   clk_1s: out std_logic
);

end clk_div;

architecture Behavioral of clk_div is

signal count: integer := 1;
signal tmp : std_logic := '0';
  
begin
  
    process(clk, tmp)
    begin
        if (clk'event and clk = '1') then
            count <= count + 1;
            if (count = 25) then
                tmp <= NOT tmp;
                count <= 1;
            end if;
        end if;
    clk_1s <= tmp;

end process;

end Behavioral;