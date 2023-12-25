library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_transmitter_controller is
    port(
        clk                : in  std_logic;        -- 50 MHz clock
        reset              : in  std_logic;        -- Reset signal
        data_ready         : in  std_logic;        -- Signal indicating data is ready to be transmitted
        master_ready       : in  std_logic;        -- Readiness signal from SPI Master
        transmitter_ready  : out std_logic        -- Signal indicating Transmitter's readiness to send data
    );
end spi_transmitter_controller;

architecture Behavioral of spi_transmitter_controller is
begin
    -- Controller Process
    controller_process: process(clk, reset)
    begin
        if reset = '1' then
            -- Reset state
            transmitter_ready <= '0';
        elsif rising_edge(clk) then
            -- Transmitter Ready Logic
            if data_ready = '1' and master_ready = '1' then
                transmitter_ready <= '1'; -- Ready to transmit when data is ready and Master is ready
            else
                transmitter_ready <= '0';
            end if;
        end if;
    end process;
end Behavioral;