library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_transmitter is
    port(
        master_clk              : in  std_logic;
        reset                   : in  std_logic;
        cdc_fifo_empty          : in  std_logic;
        cdc_out                 : in  std_logic_vector(7 downto 0);
        master_ready            : in  std_logic;
        transmitter_empty       : out std_logic;
        MISO                    : out std_logic;
        transmitter_ready       : out std_logic
    );
end entity spi_transmitter;

architecture Behavioral of spi_transmitter is
    type state_type is (IDLE, LOAD, TRANSMIT, WAIT_MASTER, RESET_BUFFER);
    signal current_state, next_state : state_type := IDLE;
    signal transmit_buffer : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_counter : integer range 0 to 7 := 0;

begin

    -- Combined State Update and Next State Logic Process
    process(master_clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            next_state <= IDLE;
            bit_counter <= 0;
            transmit_buffer <= (others => '0');
            MISO <= '0';
            transmitter_empty <= '1'; -- Buffer is empty after reset
        elsif rising_edge(master_clk) then
            -- Update current state
            current_state <= next_state;
            -- FSM Output Management and Next State Logic
            case current_state is
                when IDLE =>
                    transmitter_empty <= '1'; -- Buffer is empty in IDLE state
                    MISO <= '0';
                    if cdc_fifo_empty = '0' and master_ready = '1' then
                        next_state <= LOAD;
                    else
                        next_state <= IDLE;
                    end if;

                when LOAD =>
                    transmit_buffer <= cdc_out;
                    transmitter_empty <= '0';
                    bit_counter <= 0;
                    next_state <= TRANSMIT;

                when TRANSMIT =>
                    transmitter_ready <= '1';
                    MISO <= transmit_buffer(bit_counter);
                    if bit_counter < 7 then
                        bit_counter <= bit_counter + 1;
                        next_state <= TRANSMIT;
                    else
                        next_state <= RESET_BUFFER;
                    end if;

                when WAIT_MASTER =>
                    if master_ready = '1' then
                        next_state <= IDLE;
                    else
                        next_state <= WAIT_MASTER;
                    end if;

                when RESET_BUFFER =>
                    transmit_buffer <= (others => '0'); -- Reset buffer
                    transmitter_empty <= '1'; -- Signal that buffer is empty
                    next_state <= IDLE; -- Return to IDLE state

                when others =>
                    next_state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;
