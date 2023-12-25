library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_receiver is
    port(
        master_clk         : in  std_logic; -- Master Clock
        reset            : in  std_logic; -- Global Reset
        master_ready     : in  std_logic; -- Chip Select
        MOSI             : in  std_logic; -- MOSI line
        write_permission : in  std_logic; -- Signal indicating permission to write to FIFO Buffer
        receiver_out     : out std_logic_vector(23 downto 0); -- 24-bit pixel data output
        pixel_valid      : out std_logic; -- Indicates a valid pixel is ready
        can_receive      : out std_logic  -- Indicates if the receiver can accept more data
    );
end entity;

architecture spi_receiver_arch of spi_receiver is
    type state_type is (IDLE, RECEIVING, DATA_READY);
    signal state        : state_type := IDLE;
    signal pixel_buffer : std_logic_vector(23 downto 0) := (others => '0');
    signal ptr          : integer range 0 to 23 := 0;
begin
    Data_Input: process(master_clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            pixel_buffer <= (others => '0');
            ptr <= 0;
            pixel_valid <= '0';
            can_receive <= '1'; -- Indicating that receiver is ready after reset
        elsif rising_edge(master_clk) then
            case state is
                when IDLE =>
                    if master_ready = '1' and write_permission = '1' then
                        state <= RECEIVING;
                        pixel_valid <= '0';
                        can_receive <= '0'; -- Not ready to receive during data capturing
                    else
                        can_receive <= '1'; -- Ready to receive when IDLE
                    end if;

                when RECEIVING =>
                    pixel_buffer(23 - ptr) <= MOSI;
                    if ptr < 23 then
                        ptr <= ptr + 1;
                        can_receive <= '0'; -- Continue receiving, not ready for new data
                    else
                        state <= DATA_READY;
                        ptr <= 0;
                    end if;

                when DATA_READY =>
                    receiver_out <= pixel_buffer;
                    pixel_valid <= '1';
                    if write_permission = '0' then
                        state <= IDLE;
                        can_receive <= '1'; -- Ready to receive when IDLE
                    else
                        state <= RECEIVING;
                        can_receive <= '0'; -- Continue receiving, not ready for new data
                    end if;
            end case;
        end if;
    end process;
end spi_receiver_arch;
