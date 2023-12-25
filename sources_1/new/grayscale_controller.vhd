library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity grayscale_module_controller is
    port(
        clk                   : in  std_logic;           -- Internal 200 MHz clock
        reset                 : in  std_logic;           -- Reset signal
        FIFO_empty            : in  std_logic;           -- Signal indicating SPI Transmitter buffer is empty
        grayscale_data_valid  : in  std_logic;           -- Data valid signal from Grayscale Module
        module_input_ready    : in  std_logic;           -- Input ready signal from Grayscale Module
        next_stage_ready      : in  std_logic;           -- Readiness signal from the next stage (e.g., CDC Unit-2)
        process_next_pixel    : out std_logic            -- Signal to Grayscale Module to process next pixel
    );
end grayscale_module_controller;

architecture Behavioral of grayscale_module_controller is
begin
    -- Controller Process
    controller_process: process(clk, reset)
    begin
        if reset = '1' then
            -- Reset state
            process_next_pixel <= '0';
        elsif rising_edge(clk) then
            -- Control Logic for processing next pixel
            if FIFO_empty = '0' and module_input_ready = '1' and grayscale_data_valid = '0' and next_stage_ready = '1' then
                process_next_pixel <= '1'; -- Signal to Grayscale Module to read next pixel
            else
                process_next_pixel <= '0'; -- Wait until FIFO has data, Grayscale Module is ready for new input, and the current pixel is processed or the next stage is ready
            end if;
        end if;
    end process;
end Behavioral;
