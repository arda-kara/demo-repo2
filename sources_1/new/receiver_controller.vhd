library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_receiver_controller is
    port(
        clk              : in  std_logic;        -- 50 MHz clock
        reset            : in  std_logic;        -- Reset signal
        master_ready     : in  std_logic;        -- Readiness signal from SPI Master
        FIFO_full    : in  std_logic;        -- Indicator that FIFO in 200 MHz domain is not full
        write_permission : out std_logic         -- Write permission signal for SPI Slave Receiver
    );
end spi_receiver_controller;

architecture Behavioral of spi_receiver_controller is
begin
    -- Controller Process
    controller_process: process(clk, reset)
    begin
        if reset = '1' then
            -- Reset state
            write_permission <= '0';
        elsif rising_edge(clk) then
            -- Write Permission Logic
            if master_ready = '1' and FIFO_full = '0' then
                write_permission <= '1'; -- Permit writing when Master is ready and FIFO is not full
            else
                write_permission <= '0';
            end if;
        end if;
    end process;
end Behavioral;
