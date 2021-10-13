--HCSR-04 App

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
--defining i/o's in entity
entity hcsr04 is
port
(
clk : in std_logic; --clock signal
echo_pin : in std_logic; --echo pin of hcsr04
trig_pin : in std_logic; --trigger pin of hcsr04
cathode : inout std_logic_vector (7 downto 0); --7seg's cathode
anode : inout std_logic_vector(3 downto 0); --7seg's anode
LED : out std_logic_vector(11 downto 0) --statement leds
);
end hcsr04;

architecture bhv of hcsr04 is
signal trigger: std_logic; --declaring wires(before begin) to connect components inside of chip, which means signals.
signal echo: std_logic;

begin
process(clk,trigger,echo,echo_pin) --means we'll process whichs are in parantheses
--defining variables
variable counter_trig: integer range 0 to 100000000:=0; -- creating 10µs trigger signal
variable counter_timer: integer range 0 to 100000000:=0; -- to measure 1 cm distance
variable anode_counter:unsigned(16 downto 0):=(others=>'0');
variable i: unsigned(11 downto 0):=(others=>'0'); --cm
variable i_temp: unsigned(11 downto 0):=(others=>'0'); --to keep cm
variable i_bcd:unsigned(11 downto 0) := (others=>'0'); --bcd conversions

begin
if rising_edge(clk) then
echo<=echo_pin;
end if;

if rising_edge(clk) then
anode_counter:=anode_counter+1;
end if;

--7seg anode scan with case statement
case(std_logic_vector'(anode_counter(16), anode_counter(15))) is
	when"00"=>anode<="1110";
	when"01"=>anode<="1101";
	when"10"=>anode<="1011";
	when others=>anode<="0111";
	end case;


--creating 1 period of trigger signal
if rising_edge(clk) then
	if(counter_trig=600000) then
		counter_trig:=0;
	else
		counter_trig:=counter_trig+1;
			end if;
		end if;


--creating 10 µs high trigger signal
if rising_edge(clk) then
	if (counter_trig<1000) then
		trig_pin<='1';
			else
				trig_pin<='0';
	end if;
end if;



--to measure just 1 cm distance, distance=(time*velocity of sound m/s)/2
-- when we calculate time for 1 cm, the result is 5882 and odds, so counter_timer must be 5882.
if rising_edge (clk) then
	if(echo='1') then
		if (counter_timer=5882) then 
		counter_timer :=0;
		i:=i+1; --holds distance in cm
		i_temp:=i; --i_temp keeps cm info for not lose it.
		else
			counter_timer:=counter_timer+1; --it counts pulse during high of echo signal
		end if;
	end if;
	if(echo='0') then
	i:="000000000000"; --makes it zero when process is done
	end if;
end if;

--adjusting the flashing leds according to the distance
		if rising_edge (clk) then
					
				if i_temp<"000000000101" then     --5
					led<="000000000001";
				elsif i_temp<"000000001010" then --10
					led<="000000000011";
				elsif i_temp<"000000001111" then --15
					led<="000000000111";
				elsif i_temp<"000000010100" then --20
					led<="000000001111";
				elsif i_temp<"000000011001" then --25
					led<="000000011111";
				elsif i_temp<"000000011110" then --30
					led<="000000111111";
				elsif i_temp<"000000100011" then --35
					led<="000001111111";
				elsif i_temp<"000000101000" then --40
					led<="000011111111";
				elsif i_temp<"000000101101" then --45
                    led<="000111111111";
                elsif i_temp<"000000110010" then --50
                    led<="001111111111";
                elsif i_temp<"000000110111" then --55
                    led<="011111111111";
                elsif i_temp<"000000111100" then --60
                    led<="111111111111";
				else 
					led<="111111111111";
				end if;
			
		end if;
		
		
-- bcd conversion starts		
--bcd which means binary coded decimal
--using the bcd algorithm, we found the digits of distance, for examle for i_temp=13, => "1" "3"
if i_temp<"000000001010" then ---- <10
i_bcd:=i_temp;
elsif i_temp<"000000010100" then ---<20
i_bcd:=i_temp+6;
elsif i_temp<"000000011110" then ----30
i_bcd:=i_temp+12;
elsif i_temp<"000000101000"then 
i_bcd:=i_temp+18;
elsif i_temp<"000000110010"then  ----50
i_bcd:=i_temp+24;
elsif i_temp<"000000111100" then
i_bcd:=i_temp+30;
elsif i_temp<"000001000110" then
i_bcd:=i_temp+36;
elsif i_temp<"000001010000" then
i_bcd:=i_temp+42;
elsif i_temp<"000001011010"then
i_bcd:=i_temp+48;
elsif i_temp<"000001100100"then--100 
i_bcd:=i_temp+54;

else
i_bcd:="100010001000";
end if;
-- bcd conversion finished



-- seven segment display
		
			if anot="1110" then--anode0
				case (i_bcd(3 downto 0)) is
		  			when"0000"=> cathode<="11000000";
		  			when"0001"=> cathode<="11111001";
					when"0010"=> cathode<="10100100";
					when"0011"=> cathode<="10110000";
					when"0100"=> cathode<="10011001";
					when"0101"=> cathode<="10010010";
					when"0110"=> cathode<="10000010";
					when"0111"=> cathode<="11111000";
					when"1000"=> cathode<="10000000";
					when others=>cathode<="10010000";
				end case;
			end if;

			if anode="1101" then--anode1 
				case (i_bcd(7 downto 4)) is
					when"0000"=> cathode<="11000000";
					when"0001"=> cathode<="11111001";
					when"0010"=> cathode<="10100100";
					when"0011"=> cathode<="10110000";
					when"0100"=> cathode<="10011001";
					when"0101"=> cathode<="10010010";
					when"0110"=> cathode<="10000010";
					when"0111"=> cathode<="11111000";
					when"1000"=> cathode<="10000000";
					when others=>cathode<="10010000";
				end case;
			end if;

			if anode="1011" then--anode2 
				case (i_bcd(11 downto 8)) is
					when"0000"=> cathode<="11000000";
					when"0001"=> cathode<="11111001";
					when"0010"=> cathode<="10100100";
					when"0011"=> cathode<="10110000";
					when"0100"=> cathode<="10011001";
					when"0101"=> cathode<="10010010";
					when"0110"=> cathode<="10000010";
					when"0111"=> cathode<="11111000";
					when"1000"=> cathode<="10000000";
					when others=>cathode<="10010000";
				end case;
			end if;

			if anode="0111" then--anode3 
			  cathode<="11111111";
			end if;
			
			
			
			
			
	--	end if;


		-- seven segment display
	
		
		
	end process;



	end bhv;
