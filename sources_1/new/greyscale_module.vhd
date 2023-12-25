library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity grayscale_circuit is
    port(
        sync_clk           : in  std_logic;
        reset                  : in  std_logic;
        gray_in                : in  std_logic_vector(23 downto 0);
        process_next_pixel     : in  std_logic;           -- External control signal for read enable
        cdc_fifo_full          : in  std_logic;
        input_ready            : out std_logic;           -- Signal indicating readiness for new input
        gray_pixel             : out std_logic_vector(7 downto 0);
        grayscale_data_valid   : out std_logic;           -- Modified to account for FIFO full status
        write_to_fifo          : out std_logic            -- New output signal to control FIFO write
    );
end entity;

architecture Behavioral of grayscale_circuit is
    signal R, G, B             : unsigned(7 downto 0) := (others => '0');
    signal internal_gray       : unsigned(7 downto 0);
    signal pixel_valid         : std_logic := '0';
    constant coeff_R           : unsigned(7 downto 0) := to_unsigned(77, 8);
    constant coeff_G           : unsigned(7 downto 0) := to_unsigned(150, 8);
    constant coeff_B           : unsigned(7 downto 0) := to_unsigned(29, 8);
    signal sum                 : unsigned(15 downto 0);
begin
    Grayscale_Process: process(sync_clk, reset)
    begin
        if reset = '1' then
            pixel_valid <= '0';
            gray_pixel <= (others => '0');
            input_ready <= '1'; -- Ready for input after reset
            grayscale_data_valid <= '0';
            write_to_fifo <= '0';
        elsif rising_edge(sync_clk) then
            if process_next_pixel = '1' and pixel_valid = '0' then
                -- Read and process a pixel from FIFO
                R <= unsigned(gray_in(23 downto 16));
                G <= unsigned(gray_in(15 downto 8));
                B <= unsigned(gray_in(7 downto 0));
                sum <= resize(R * coeff_R, sum'length) + resize(G * coeff_G, sum'length) + resize(B * coeff_B, sum'length);
                internal_gray <= sum(15 downto 8);
                gray_pixel <= std_logic_vector(internal_gray);
                pixel_valid <= '1';
                input_ready <= '0'; -- Indicate that the circuit is busy processing a pixel
                -- Check if FIFO is full before marking data as valid
                if cdc_fifo_full <= '0' then
                    grayscale_data_valid <= '1';
                    write_to_fifo <= '1'; -- Signal to write data to FIFO
                else
                    grayscale_data_valid <= '0';
                    write_to_fifo <= '0';
                end if;
            else
                if pixel_valid = '1' then
                    pixel_valid <= '0'; -- Reset pixel_valid for next pixel
                    input_ready <= '1'; -- Ready for the next input
                end if;
                grayscale_data_valid <= '0';
                write_to_fifo <= '0';
            end if;
        end if;
    end process;
end Behavioral;
