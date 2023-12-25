LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;


ENTITY fifo_tb IS
END fifo_tb;

ARCHITECTURE behavior OF fifo_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT FIFO
    GENERIC(
        pixel_width : natural := 24;
        FIFO_depth  : natural := 36000
    );
    PORT(
        sync_clk    : IN  std_logic;
        reset       : IN  std_logic;
        write_enable       : IN  std_logic;
        read_enable       : IN  std_logic;
        FIFO_in     : IN  std_logic_vector(pixel_width - 1 downto 0);
        FIFO_out    : OUT std_logic_vector(pixel_width - 1 downto 0);
        FIFO_full   : OUT std_logic;
        FIFO_empty  : OUT std_logic
    );
    END COMPONENT;

    --Inputs
    signal sync_clk    : std_logic := '0';
    signal reset       : std_logic := '1';
    signal write_enable       : std_logic := '0';
    signal read_enable       : std_logic := '0';
    signal FIFO_in     : std_logic_vector(23 downto 0);

    --Outputs
    signal FIFO_out    : std_logic_vector(23 downto 0);
    signal FIFO_full   : std_logic;
    signal FIFO_empty  : std_logic;

    -- Clock period definitions
    constant sync_clk_period : time := 10 ns; -- Adjust as needed

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: FIFO GENERIC MAP (
          pixel_width => 24,
          FIFO_depth  => 36000
          )
          PORT MAP (
          sync_clk => sync_clk,
          reset => reset,
          write_enable => write_enable,
          read_enable => read_enable,
          FIFO_in => FIFO_in,
          FIFO_out => FIFO_out,
          FIFO_full => FIFO_full,
          FIFO_empty => FIFO_empty
          );

    -- Clock process definitions
    sync_clk_process :process
    begin
        sync_clk <= '0';
        wait for sync_clk_period/2;
        sync_clk <= '1';
        wait for sync_clk_period/2;
    end process;

    -- Stimulus process
stim_proc: process
begin       
    -- hold reset state for 100 ns.
    wait for 100 ns;  
    reset <= '0';  

    -- Test Case 1: Write to FIFO
    write_enable <= '1';
    for i in 0 to 10 loop
        FIFO_in <= std_logic_vector(to_unsigned(i, 24)); -- Change data each time
        wait for sync_clk_period*10; -- Wait for ten clock cycle
    end loop;
    write_enable <= '0';

    -- Test Case 2: Read from FIFO
    wait for sync_clk_period * 10; -- Wait some time before reading
    read_enable <= '1';
    for i in 0 to 10 loop
        wait for sync_clk_period*10; -- Wait for ten clock cycle
    end loop;
    read_enable <= '0';

    -- End simulation
    wait;
end process;

END;
