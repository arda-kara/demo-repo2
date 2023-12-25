LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level_system_tb IS
END top_level_system_tb;

ARCHITECTURE behavior OF top_level_system_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT top_level_system
    PORT(
        master_clk : IN  std_logic;
        reset : IN  std_logic;
        master_ready : IN  std_logic;
        MOSI : IN  std_logic;
        MISO : OUT std_logic;
        receiver_ready : OUT std_logic
    );
    END COMPONENT;

   --Inputs
   signal master_clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal master_ready : std_logic := '0';
   signal MOSI : std_logic := '0';

   --Outputs
   signal MISO : std_logic;
   signal receiver_ready : std_logic;

   -- Clock period definitions
   constant master_clk_period : time := 20 ns; -- Adjust as needed

BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: top_level_system PORT MAP (
          master_clk => master_clk,
          reset => reset,
          master_ready => master_ready,
          MOSI => MOSI,
          MISO => MISO,
          receiver_ready => receiver_ready
        );

   -- Clock process definitions
   master_clk_process :process
   begin
		master_clk <= '0';
		wait for master_clk_period/2;
		master_clk <= '1';
		wait for master_clk_period/2;
   end process;
   
   -- Stimulus process
   stim_proc: process
   -- Helper function to convert a hex string to std_logic_vector
   function To_StdLogicVector(hex : in string) return std_logic_vector is
      variable result : std_logic_vector(hex'length*4-1 downto 0);
   begin
      for i in 1 to hex'length-1 loop
         case hex(i) is
            when '0'      => result(i*4+3 downto i*4) := "0000";
            when '1'      => result(i*4+3 downto i*4) := "0001";
            when '2'      => result(i*4+3 downto i*4) := "0010";
            when '3'      => result(i*4+3 downto i*4) := "0011";
            when '4'      => result(i*4+3 downto i*4) := "0100";
            when '5'      => result(i*4+3 downto i*4) := "0101";
            when '6'      => result(i*4+3 downto i*4) := "0110";
            when '7'      => result(i*4+3 downto i*4) := "0111";
            when '8'      => result(i*4+3 downto i*4) := "1000";
            when '9'      => result(i*4+3 downto i*4) := "1001";
            when 'A'|'a'  => result(i*4+3 downto i*4) := "1010";
            when 'B'|'b'  => result(i*4+3 downto i*4) := "1011";
            when 'C'|'c'  => result(i*4+3 downto i*4) := "1100";
            when 'D'|'d'  => result(i*4+3 downto i*4) := "1101";
            when 'E'|'e'  => result(i*4+3 downto i*4) := "1110";
            when others   => result(i*4+3 downto i*4) := "1111"; -- 'F' or 'f'
         end case;
      end loop;
      return result;
   end To_StdLogicVector;

   -- 24-bit pixel data in hex format
   constant pixel_data_hex : string := "00AA00";
   variable pixel_data : std_logic_vector(23 downto 0);
begin
   pixel_data := To_StdLogicVector(pixel_data_hex);

   -- Initialize the system
   wait for 100 ns;  
   reset <= '0';  
   wait for 20 ns;
   master_ready <= '1'; -- Indicating master is ready

   -- Simulate sending the pixel data bit-by-bit over MOSI
   for i in pixel_data'high downto 0 loop
      MOSI <= pixel_data(i);
      wait for master_clk_period;
   end loop;

   -- Optionally, add delay and check for response on MISO, if applicable

   wait; -- will wait forever
end process;

END;
