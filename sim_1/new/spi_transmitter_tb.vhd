LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spi_transmitter_tb IS
END spi_transmitter_tb;

ARCHITECTURE behavior OF spi_transmitter_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT spi_transmitter
    PORT(
        master_clk : IN  std_logic;
        reset : IN  std_logic;
        cdc_fifo_empty : IN  std_logic;
        cdc_out : IN  std_logic_vector(7 downto 0);
        master_ready : IN  std_logic;
        buffer_empty : OUT std_logic;
        MISO : OUT std_logic
    );
    END COMPONENT;
    
    --Inputs
    signal master_clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal cdc_fifo_empty : std_logic := '1';
    signal cdc_out : std_logic_vector(7 downto 0) := (others => '0');
    signal master_ready : std_logic := '0';

    --Outputs
    signal buffer_empty : std_logic;
    signal MISO : std_logic;

    -- Clock period definitions
    constant master_clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: spi_transmitter PORT MAP (
        master_clk => master_clk,
        reset => reset,
        cdc_fifo_empty => cdc_fifo_empty,
        cdc_out => cdc_out,
        master_ready => master_ready,
        buffer_empty => buffer_empty,
        MISO => MISO
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
begin       
    -- Initialize Inputs
    reset <= '1';
    cdc_fifo_empty <= '1';
    cdc_out <= (others => '0');
    master_ready <= '0';

    -- Wait for global reset
    wait for 100 ns;
    reset <= '0';  

    -- Test Case 1: Transmit data when FIFO is not empty and master is ready
    cdc_fifo_empty <= '0';  -- FIFO is not empty
    master_ready <= '1';    -- Master is ready
    cdc_out <= "10101010";  -- Data to be transmitted
    wait for 160 ns;
    
    -- Test Case 1: Transmit data when FIFO is not empty and master is ready
    cdc_fifo_empty <= '0';  -- FIFO is not empty
    master_ready <= '1';    -- Master is ready
    cdc_out <= "11110000";  -- Data to be transmitted
    wait for 160 ns;
    
    -- Test Case 1: Transmit data when FIFO is not empty and master is ready
    cdc_fifo_empty <= '0';  -- FIFO is not empty
    master_ready <= '1';    -- Master is ready
    cdc_out <= "11001100";  -- Data to be transmitted
    wait for 160 ns;

    wait;
end process;


END;
