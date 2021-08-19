LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_digital_clock IS
END tb_digital_clock;
ARCHITECTURE behavior OF tb_digital_clock IS 
  -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT digital_clock
    PORT(
         clk : IN  std_logic;
         RESET : IN  std_logic;
         SET_TIME : IN std_logic;
         SET_ALARM : IN std_logic;
         STOP_ALARM : IN std_logic;
         ALARM_ON : IN std_logic;
         CLOCK_ON : IN std_logic;
         H_in1 : IN  std_logic_vector(1 downto 0);
         H_in0 : IN  std_logic_vector(3 downto 0);
         M_in1 : IN  std_logic_vector(3 downto 0);
         M_in0 : IN  std_logic_vector(3 downto 0);
         
         H_out1 : OUT  std_logic_vector(6 downto 0);
         H_out0 : OUT  std_logic_vector(6 downto 0);
         M_out1 : OUT  std_logic_vector(6 downto 0);
         M_out0 : OUT  std_logic_vector(6 downto 0);
         S_out1 : OUT  std_logic_vector(6 downto 0);
         S_out0 : OUT  std_logic_vector(6 downto 0);
         Alarm : OUT std_logic
         
        );
    END COMPONENT;
   --INPUTS
   signal clk : std_logic := '0';
   signal RESET : std_logic := '0';
   signal SET_TIME : std_logic := '0';
   signal SET_ALARM : std_logic := '0';
   signal STOP_ALARM : std_logic := '1';
   signal ALARM_ON : std_logic := '0';
   signal CLOCK_ON : std_logic := '0';
   signal H_in1 : std_logic_vector(1 downto 0) := (others => '0');
   signal H_in0 : std_logic_vector(3 downto 0) := (others => '0');
   signal M_in1 : std_logic_vector(3 downto 0) := (others => '0');
   signal M_in0 : std_logic_vector(3 downto 0) := (others => '0');

  --OUTPUTS
   signal H_out1 : std_logic_vector(6 downto 0);
   signal H_out0 : std_logic_vector(6 downto 0);
   signal M_out1 : std_logic_vector(6 downto 0);
   signal M_out0 : std_logic_vector(6 downto 0);
   signal S_out1 : std_logic_vector(6 downto 0);
   signal S_out0 : std_logic_vector(6 downto 0);
   signal ALARM : std_logic;
   
   -- Clock period definitions
   constant clk_period : time := 20 ms;
   
BEGIN

 -- Instantiate the Unit Under Test (UUT)
   uut: digital_clock PORT MAP (
          clk => clk,
          RESET => RESET,
          H_in1 => H_in1,
          H_in0 => H_in0,
          M_in1 => M_in1,
          M_in0 => M_in0,
          SET_TIME => SET_TIME,
          SET_ALARM => SET_ALARM,
          STOP_ALARM => STOP_ALARM,
          ALARM_ON => ALARM_ON,
          CLOCK_ON => CLOCK_ON,
          
          H_out1 => H_out1,
          H_out0 => H_out0,
          M_out1 => M_out1,
          M_out0 => M_out0,
          S_out1 => S_out1,
          S_out0 => S_out0,
          ALARM => ALARM
        );
-- Clock process definitions
clk_process :process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin  
    
    -- Start the Clock normaly for 10 Seconds
    RESET <= '1';  
    wait for 10 ms;
    
    RESET <= '0';  
    wait for 10 ms;
    
    Clock_On <= '1';
    wait for 10 ms;
    
    wait for 10000 ms;
    
    -- Set Time and wait for 5 seconds
    Set_Time <= '1';
    wait for 50 ms;
    
    H_in1 <= "10";
    H_in0 <= x"1";
    M_in1 <= x"4";
    M_in0 <= x"5";  
    wait for 50 ms; 
    
    Set_Time <= '0';
    wait for 50 ms;
    
    wait for 5000 ms;
    
    -- set Alarm
    Set_Alarm <= '1';
    wait for 50 ms;
    
    H_in1 <= "10";
    H_in0 <= x"1";
    M_in1 <= x"4";
    M_in0 <= x"7";  
    wait for 50 ms; 
    
    Set_Alarm <= '0';
    wait for 50 ms;
    
    Alarm_on <= '1';
    wait for 50 ms;
    -- wait for 2 minutes to alarm be actived
    wait for 120000 ms;
    
    wait;

end process;

END;