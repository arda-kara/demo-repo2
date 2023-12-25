library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CDC_Unit_2_tb is
    -- Testbench has no ports
end entity CDC_Unit_2_tb;

architecture tb of CDC_Unit_2_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component CDC_Unit_2
        port(
            internal_clk       : in std_logic;
            master_clk         : in std_logic;
            reset              : in std_logic;
            gray_pixel         : in std_logic_vector(7 downto 0);
            data_valid         : in std_logic;
            cdc_write          : in std_logic;
            gray_pixel_cdc     : out std_logic_vector(7 downto 0);
            data_valid_cdc     : out std_logic;
            buffer_empty       : in std_logic;
            cdc_read           : in std_logic;
            buffer_empty_cdc   : out std_logic;
            fifo_full          : out std_logic;
            fifo_empty         : out std_logic
        );
    end component;

    -- Signal declarations
    signal internal_clk   : std_logic := '0';
    signal master_clk     : std_logic := '0';
    signal reset          : std_logic := '1';
    signal gray_pixel     : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid     : std_logic := '0';
    signal cdc_write      : std_logic := '0';
    signal gray_pixel_cdc : std_logic_vector(7 downto 0);
    signal data_valid_cdc : std_logic;
    signal buffer_empty   : std_logic := '0';
    signal cdc_read       : std_logic := '0';
    signal buffer_empty_cdc : std_logic;
    signal fifo_full      : std_logic;
    signal fifo_empty     : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: CDC_Unit_2
        port map (
            internal_clk       => internal_clk,
            master_clk         => master_clk,
            reset              => reset,
            gray_pixel         => gray_pixel,
            data_valid         => data_valid,
            cdc_write          => cdc_write,
            gray_pixel_cdc     => gray_pixel_cdc,
            data_valid_cdc     => data_valid_cdc,
            buffer_empty       => buffer_empty,
            cdc_read           => cdc_read,
            buffer_empty_cdc   => buffer_empty_cdc,
            fifo_full          => fifo_full,
            fifo_empty         => fifo_empty
        );

    -- Clock process for internal_clk (200 MHz)
    internal_clk_process: process
    begin
        internal_clk <= '0';
        wait for 2.5 ns; -- 200 MHz clock
        internal_clk <= '1';
        wait for 2.5 ns;
    end process;

    -- Clock process for master_clk (50 MHz)
    master_clk_process: process
    begin
        master_clk <= '0';
        wait for 10 ns; -- 50 MHz clock
        master_clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;

        -- Stimulate inputs
        gray_pixel <= x"AA";
        data_valid <= '1';
        buffer_empty <= '0';
        wait for 20 ns; -- Simulate one cycle of data
        data_valid <= '0';
        
        data_valid <= '1';
        buffer_empty <= '1';
        -- Observe outputs and FIFO status
        wait for 100 ns;

        -- End of test
        wait;
    end process;

end tb;
