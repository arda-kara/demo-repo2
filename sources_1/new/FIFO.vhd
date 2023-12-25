library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIFO is
    generic(
        pixel_width : natural := 24;       -- Width of each pixel data
        FIFO_depth  : natural := 36000    -- Depth of FIFO buffer (bit (1/16 of an image))
    );
    port(
        sync_clk    : in  std_logic;                           -- Clock signal
        reset       : in  std_logic;                           -- Reset signal
        write_enable       : in  std_logic;                           -- Write enable signal
        read_enable       : in  std_logic;                           -- Read enable signal
        FIFO_in     : in  std_logic_vector(pixel_width - 1 downto 0); -- Data input
        FIFO_out    : out std_logic_vector(pixel_width - 1 downto 0); -- Data output
        FIFO_full   : out std_logic;                           -- FIFO full indicator
        FIFO_empty  : out std_logic                            -- FIFO empty indicator
    );
end FIFO;

architecture Behavioral of FIFO is
    type buffer_type is array (0 to FIFO_depth - 1) of std_logic_vector(pixel_width - 1 downto 0);
    signal FIFO_buffer : buffer_type;
    signal write_pointer : integer range 0 to FIFO_depth - 1 := 0;
    signal read_pointer : integer range 0 to FIFO_depth - 1 := 0;
    signal num_elements : integer range 0 to FIFO_depth := 0; -- Number of elements in FIFO
    signal internal_full: std_logic := '0';
    signal internal_empty: std_logic := '1';
begin
    process(sync_clk, reset, internal_full, internal_empty)
    begin
        if reset = '1' then
            write_pointer <= 0;
            read_pointer <= 0;
            num_elements <= 0;
            internal_full <= '0';
            internal_empty <= '1';
        elsif rising_edge(sync_clk) then
            -- Write operation
            if write_enable = '1' and internal_full = '0' then
                FIFO_buffer(write_pointer) <= FIFO_in;
                write_pointer <= (write_pointer + 1) mod FIFO_depth;
                num_elements <= num_elements + 1;
            end if;

            -- Read operation
            if read_enable = '1' and internal_empty = '0' then
                FIFO_out <= FIFO_buffer(read_pointer);
                read_pointer <= (read_pointer + 1) mod FIFO_depth;
                num_elements <= num_elements - 1;
            end if;

            -- Update FIFO status
            if num_elements = FIFO_depth-50 then
            internal_full <= '1';
            end if;
            if num_elements = 50 then
            internal_empty <= '0';
            end if;
           
        end if;
        FIFO_full <= internal_full;   -- Update output port
        FIFO_empty <= internal_empty; -- Update output port
    end process;

end Behavioral;
