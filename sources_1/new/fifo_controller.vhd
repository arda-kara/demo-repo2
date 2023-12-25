library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_buffer_controller is
    port(
        clk              : in std_logic;        -- Internal 200 MHz clock
        reset            : in std_logic;        -- Reset signal
        data_available   : in std_logic;        -- Data available in the receiver
        FIFO_full        : in std_logic;        -- FIFO full indicator from FIFO Buffer
        FIFO_empty       : in std_logic;        -- FIFO empty indicator from FIFO Buffer
        grayscale_ready  : in std_logic;        -- Input ready signal from Grayscale Module
        write_enable     : out std_logic;       -- Write enable signal to FIFO Buffer
        read_enable      : out std_logic        -- Read enable signal to FIFO Buffer
    );
end fifo_buffer_controller;

architecture Behavioral of fifo_buffer_controller is
begin
    -- Controller Process
    controller_process: process(clk, reset)
    begin
        if reset = '1' then
            -- Reset state
            write_enable <= '0';
            read_enable <= '0';
        elsif rising_edge(clk) then
            -- Write Enable Logic
            if data_available = '1' and FIFO_full = '0' then
                write_enable <= '1';
            else
                write_enable <= '0';
            end if;

            -- Read Enable Logic
            if FIFO_empty = '0' and grayscale_ready = '1' then
                read_enable <= '1';
            else
                read_enable <= '0';
            end if;
        end if;
    end process;
end Behavioral;
