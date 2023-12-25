library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CDC_Unit_1_tb is
    -- Empty entity for the testbench
end entity CDC_Unit_1_tb;

architecture tb of CDC_Unit_1_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component CDC_Unit_1
        port(
            master_clk        : in std_logic;
            internal_clk      : in std_logic;
            reset             : in std_logic;
            receiver_out      : in std_logic_vector(23 downto 0);
            pixel_valid       : in std_logic;
            cdc_write         : in std_logic;
            receiver_out_cdc  : out std_logic_vector(23 downto 0);
            pixel_valid_cdc   : out std_logic;
            write_enable      : in std_logic;
            write_enable_cdc  : out std_logic;
            cdc_read          : in std_logic;
            fifo_empty        : out std_logic;
            fifo_full         : out std_logic
        );
    end component;

    -- Signal declarations
    signal master_clk        : std_logic := '0';
    signal internal_clk      : std_logic := '0';
    signal reset             : std_logic := '1';
    signal receiver_out      : std_logic_vector(23 downto 0) := (others => '0');
    signal pixel_valid       : std_logic := '0';
    signal cdc_write         : std_logic := '0';
    signal receiver_out_cdc  : std_logic_vector(23 downto 0);
    signal pixel_valid_cdc   : std_logic;
    signal write_enable      : std_logic := '0';
    signal write_enable_cdc  : std_logic;
    signal cdc_read          : std_logic := '0';
    signal fifo_empty        : std_logic;
    signal fifo_full         : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: CDC_Unit_1
        port map (
            master_clk        => master_clk,
            internal_clk      => internal_clk,
            reset             => reset,
            receiver_out      => receiver_out,
            pixel_valid       => pixel_valid,
            cdc_write         => cdc_write,
            receiver_out_cdc  => receiver_out_cdc,
            pixel_valid_cdc   => pixel_valid_cdc,
            write_enable      => write_enable,
            write_enable_cdc  => write_enable_cdc,
            cdc_read          => cdc_read,
            fifo_empty        => fifo_empty,
            fifo_full         => fifo_full
        );

    -- Clock process for master_clk (50 MHz)
    master_clk_process: process
    begin
        master_clk <= '0';
        wait for 10 ns; -- 50 MHz clock
        master_clk <= '1';
        wait for 10 ns;
    end process;

    -- Clock process for internal_clk (200 MHz)
    internal_clk_process: process
    begin
        internal_clk <= '0';
        wait for 2.5 ns; -- 200 MHz clock
        internal_clk <= '1';
        wait for 2.5 ns;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;

        -- Write single 24-bit vector
        receiver_out <= x"ABCDEF"; -- Example data
        cdc_write <= '1';
        wait for 20 ns; -- Wait for data to be written
        cdc_write <= '0';

        -- Wait for FIFO to handle data
        wait for 100 ns;

        -- Read from FIFO
        cdc_read <= '1';
        wait for 20 ns; -- Wait for data to be read
        cdc_read <= '0';
        
        
        write_enable <= '1';
        pixel_valid <= '1';
        -- Observe that receiver_out_cdc holds its value
        wait for 100 ns;

        -- End of test
        wait;
    end process;

end tb;
