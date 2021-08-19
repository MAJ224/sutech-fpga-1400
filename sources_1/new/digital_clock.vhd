library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity digital_clock is
port ( 

-- INPUTS

clk: in std_logic; 
RESET: in std_logic; 

H_in1: in std_logic_vector(1 downto 0);
-- 2-bit input used to set the most significant hour digit of the clock. Valid values are 0 to 2. 
H_in0: in std_logic_vector(3 downto 0);
-- 4-bit input used to set the least significant hour digit of the clock. Valid values are 0 to 9. 
M_in1: in std_logic_vector(3 downto 0);
-- 4-bit input used to set the most significant minute digit of the clock. Valid values are 0 to 9. 
M_in0: in std_logic_vector(3 downto 0);
-- 4-bit input used to set the least significant minute digit of the clock. Valid values are 0 to 9.
SET_TIME: in std_logic;
-- 2-bit input used to active set time state.Valid values are 0 and 1.
SET_ALARM: in std_logic;
-- 2-bit input used to active set alarm state.Valid values are 0 and 1.
STOP_ALARM: in std_logic;
-- 2-bit input used to deactive buzzer state.Valid values are 0 and 1.
ALARM_ON: in std_logic;
-- 2-bit input used to active alarm.Valid values are 0 and 1.
CLOCK_ON: in std_logic;
-- 2-bit input used to active work normal state.Valid values are 0 and 1.
  
-- OUTPUTS

ALARM: out std_logic;
-- The flag of Alarm of the clock. Valid values are 0 and 1
H_out1: out std_logic_vector(6 downto 0);
-- The most significant digit of the hour. Valid values are 0 to 2 (Hexadecimal value on 7-segment LED)
H_out0: out std_logic_vector(6 downto 0);
-- The most significant digit of the hour. Valid values are 0 to 9 (Hexadecimal value on 7-segment LED)
M_out1: out std_logic_vector(6 downto 0);
-- The most significant digit of the minute. Valid values are 0 to 9 (Hexadecimal value on 7-segment LED)
M_out0: out std_logic_vector(6 downto 0);
-- The most significant digit of the minute. Valid values are 0 to 9 (Hexadecimal value on 7-segment LED)
S_out1: out std_logic_vector(6 downto 0);
-- The most significant digit of the second. Valid values are 0 to 9 (Hexadecimal value on 7-segment LED)
S_out0: out std_logic_vector(6 downto 0)
-- The most significant digit of the second. Valid values are 0 to 9 (Hexadecimal value on 7-segment LED)
);
end digital_clock;

architecture Behavioral of digital_clock is

component bin2hex
port (
    Bin: in std_logic_vector(3 downto 0);
    Hout: out std_logic_vector(6 downto 0)
);
end component;

component clk_div
port (
    clk: in std_logic;
    clk_1s: out std_logic
);
end component;

signal clk_1s: std_logic; -- 1-s clock
signal Cur_Time, Alarm_Time: integer; -- store times
signal counter_hour, counter_minute, counter_second: integer; -- counter using for create time
signal H_out1_bin: std_logic_vector(3 downto 0);--The most significant digit of the hour
signal H_out0_bin: std_logic_vector(3 downto 0);--The least significant digit of the hour
signal M_out1_bin: std_logic_vector(3 downto 0);--The most significant digit of the minute
signal M_out0_bin: std_logic_vector(3 downto 0);--The least significant digit of the minute
signal S_out1_bin: std_logic_vector(3 downto 0);--The most significant digit of the second
signal S_out0_bin: std_logic_vector(3 downto 0);--The least significant digit of the second

type State_Type is (Start, Work_Normal, Setup_Alarm, Setup_Time, Buzzer_on);
signal State, State_Next : State_Type;

begin

    -- create 1 second clock
    create_1s_clock: clk_div port map (clk => clk, clk_1s => clk_1s); 
    
    -- standard working
    process(clk, RESET)
    begin
        if (RESET = '1') then -- go to state START if reset
            State <= Start;
        elsif (clk'event and clk = '1') then -- otherwise update the states
            State <= State_Next;
        else
            null;
        end if; 
    end process;

    -- state machine operation
    process(clk_1s, H_in1, H_in0, M_in1, M_in0, State, clock_on, alarm_on, set_time, STOP_ALARM) begin 
   
    State_Next <= State; -- store current state as next
    case State is 
        when Start => 
            if Clock_On = '1' then
                State_Next <= Work_Normal;
            end if; 
        when Work_Normal => 
            ALARM <= '0'; 
            if Set_Time = '1' then
                State_Next <= Setup_Time;
            end if;
            if Set_Alarm = '1' then
                State_Next <= Setup_Alarm;
            end if;
            if Alarm_On = '1' and Cur_Time = Alarm_Time then
                State_Next <= Buzzer_On;
            end if;
            if Clock_On = '0' then
                State_Next <= Start;
            end if;
        when Setup_Alarm =>
            Alarm_Time <= (to_integer(unsigned(H_in1))*10 + to_integer(unsigned(H_in0))) * 3600;
            Alarm_Time <= Alarm_Time + (to_integer(unsigned(M_in1))*10 + to_integer(unsigned(M_in0))) * 60;            
            if Set_Alarm = '0' then
                State_Next <= Work_Normal;
            end if;
        when Setup_Time =>
            counter_hour <= to_integer(unsigned(H_in1))*10 + to_integer(unsigned(H_in0));
            counter_minute <= to_integer(unsigned(M_in1))*10 + to_integer(unsigned(M_in0));
            counter_second <= 0;  
            if Set_Time = '0' then
                State_Next <= Work_Normal;
            end if;
        when Buzzer_On =>
            ALARM <= '1';
            if cur_time <= alarm_time + 10 then
                State_Next <= Buzzer_On;
            end if;
            if STOP_ALARM = '1' or cur_time > alarm_time + 10 or ALARM_ON = '0' then
                State_Next <= Work_Normal;
            end if;
    end case; 
        
    if (clk_1s'event and clk_1s = '1') then
        counter_second <= counter_second + 1;
        cur_time <= counter_second + (counter_minute * 60) + (counter_hour * 3600);
        if (counter_second >=59) then -- second > 59 then minute increases
            counter_minute <= counter_minute + 1;
            counter_second <= 0;
            if (counter_minute >=59) then -- minute > 59 then hour increases
                counter_minute <= 0;
                counter_hour <= counter_hour + 1;
                if (counter_hour >= 24) then -- hour > 24 then set hour to 0
                    counter_hour <= 0;
                end if;
            end if;
        end if;
    end if;
        
end process;

-- Conversion time

-- H_out1 binary value
H_out1_bin <= x"2" when counter_hour >= 20 else
x"1" when counter_hour >= 10 else
x"0";
-- 7-Segment LED display of H_out1
convert_hex_H_out1: bin2hex port map (Bin => H_out1_bin, Hout => H_out1); 
-- H_out0 binary value
 H_out0_bin <= std_logic_vector(to_unsigned((counter_hour - to_integer(unsigned(H_out1_bin))*10),4));
-- 7-Segment LED display of H_out0
convert_hex_H_out0: bin2hex port map (Bin => H_out0_bin, Hout => H_out0);

-- M_out1 binary value
 M_out1_bin <= x"5" when counter_minute >= 50 else
 x"4" when counter_minute >= 40 else
 x"3" when counter_minute >= 30 else
 x"2" when counter_minute >= 20 else
 x"1" when counter_minute >= 10 else
 x"0";
-- 7-Segment LED display of M_out1
convert_hex_M_out1: bin2hex port map (Bin => M_out1_bin, Hout => M_out1); 
-- M_out0 binary value
 M_out0_bin <= std_logic_vector(to_unsigned((counter_minute - to_integer(unsigned(M_out1_bin))*10),4));
-- 7-Segment LED display of M_out0
convert_hex_M_out0: bin2hex port map (Bin => M_out0_bin, Hout => M_out0);

-- S_out1 binary value
 S_out1_bin <= x"5" when counter_second >= 50 else
 x"4" when counter_second >= 40 else
 x"3" when counter_second >= 30 else
 x"2" when counter_second >= 20 else
 x"1" when counter_second >= 10 else
 x"0";
-- 7-Segment LED display of S_out1
convert_hex_S_out1: bin2hex port map (Bin => S_out1_bin, Hout => S_out1); 
-- S_out0 binary value
 S_out0_bin <= std_logic_vector(to_unsigned((counter_second - to_integer(unsigned(S_out1_bin))*10),4));
-- 7-Segment LED display of S_out0
convert_hex_S_out0: bin2hex port map (Bin => S_out0_bin, Hout => S_out0); 

end Behavioral;