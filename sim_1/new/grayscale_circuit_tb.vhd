library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_grayscale_circuit is
end entity;

architecture Behavioral of tb_grayscale_circuit is
    component grayscale_circuit
        port(
            sync_clk           : in  std_logic;
            reset              : in  std_logic;
            gray_in            : in  std_logic_vector(23 downto 0);
            process_next_pixel : in  std_logic;
            cdc_fifo_full      : in  std_logic;
            input_ready        : out std_logic;
            gray_pixel         : out std_logic_vector(7 downto 0);
            grayscale_data_valid : out std_logic;
            write_to_fifo      : out std_logic
        );
    end component;

    -- Test Signals
    signal sync_clk           : std_logic := '0';
    signal reset              : std_logic := '1';
    signal gray_in            : std_logic_vector(23 downto 0);
    signal process_next_pixel : std_logic := '0';
    signal cdc_fifo_full      : std_logic := '0';
    signal input_ready        : std_logic;
    signal gray_pixel         : std_logic_vector(7 downto 0);
    signal grayscale_data_valid : std_logic;
    signal write_to_fifo      : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin
    uut: grayscale_circuit
        port map (
            sync_clk => sync_clk,
            reset => reset,
            gray_in => gray_in,
            process_next_pixel => process_next_pixel,
            cdc_fifo_full => cdc_fifo_full,
            input_ready => input_ready,
            gray_pixel => gray_pixel,
            grayscale_data_valid => grayscale_data_valid,
            write_to_fifo => write_to_fifo
        );

    -- Clock Process
    clk_process : process
    begin
        while true loop
            sync_clk <= '0';
            wait for clk_period/2;
            sync_clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Test Stimulus Process
    stimulus_process: process
    begin
        -- Initial Reset
        reset <= '1';
        wait for 40 ns;
        reset <= '0';
        wait for clk_period*2;

        -- Test Case 1: Simple RGB to Grayscale conversion
        gray_in <= x"ff0000"; -- Red
        process_next_pixel <= '1';
        wait for clk_period*8;
        process_next_pixel <= '0';
        wait for clk_period*8; -- Ensure enough time for processing
        
        -- Test Case 1: Simple RGB to Grayscale conversion
        gray_in <= x"00ff00"; -- Red
        process_next_pixel <= '1';
        wait for clk_period*8;
        process_next_pixel <= '0';
        wait for clk_period*8; -- Ensure enough time for processing
        
        -- Test Case 1: Simple RGB to Grayscale conversion
        gray_in <= x"40ff00"; -- Red
        process_next_pixel <= '1';
        wait for clk_period*8;
        process_next_pixel <= '0';
        wait for clk_period*8; -- Ensure enough time for processing
        
        -- Test Case 1: Simple RGB to Grayscale conversion
        gray_in <= x"00ff0a"; -- Red
        process_next_pixel <= '1';
        wait for clk_period*8;
        process_next_pixel <= '0';
        wait for clk_period*8; -- Ensure enough time for processing
        
        -- Test Case 1: Simple RGB to Grayscale conversion
        gray_in <= x"70ff08"; -- Red
        process_next_pixel <= '1';
        wait for clk_period*8;
        process_next_pixel <= '0';
        wait for clk_period*8; -- Ensure enough time for processing


      

        wait;
    end process;

end Behavioral;
