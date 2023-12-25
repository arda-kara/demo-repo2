library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.func_pkg.all;


entity async_fifo is
    generic(
        DATA_WIDTH : natural := 24;   -- Width of the data bus
        FIFO_DEPTH : natural := 256   -- Depth of the FIFO, should be a power of 2
    );
    port(
        wr_clk     : in std_logic;    -- Write clock (source domain)
        rd_clk     : in std_logic;    -- Read clock (destination domain)
        reset      : in std_logic;    -- Reset signal
        data_in    : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Input data
        data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0); -- Output data
        wr_en      : in std_logic;    -- Write enable
        rd_en      : in std_logic;    -- Read enable
        fifo_full  : out std_logic;   -- FIFO full flag
        fifo_empty : out std_logic    -- FIFO empty flag
    );
end entity async_fifo;

architecture Behavioral of async_fifo is
    -- FIFO memory array
    type fifo_array is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal fifo_mem : fifo_array;

    -- Read and write pointers
    signal wr_ptr : unsigned(log2ceil(FIFO_DEPTH)-1 downto 0) := (others => '0');
    signal rd_ptr : unsigned(log2ceil(FIFO_DEPTH)-1 downto 0) := (others => '0');

    -- Gray code pointers for synchronization
    signal wr_ptr_gray : unsigned(log2ceil(FIFO_DEPTH)-1 downto 0) := (others => '0');
    signal rd_ptr_gray : unsigned(log2ceil(FIFO_DEPTH)-1 downto 0) := (others => '0');
    
    signal fifo_full_internal : std_logic;
    signal fifo_empty_internal : std_logic;
    
    -- Function to convert binary to Gray code
    function to_gray(bin : unsigned) return unsigned is
        variable gray : unsigned(bin'length-1 downto 0);
    begin
        gray := bin xor bin srl 1;
        return gray;
    end function;

    -- Function to convert Gray code to binary
    function to_binary(gray : unsigned) return unsigned is
        variable bin : unsigned(gray'length-1 downto 0);
        variable temp_gray : unsigned := gray;
    begin
        for i in 0 to gray'length-1 loop
            bin(i) := temp_gray(i);
            if i > 0 then
                temp_gray(i-1) := temp_gray(i) xor temp_gray(i-1);
            end if;
        end loop;
        return bin;
    end function;

begin
    -- Write process
    write_process : process(wr_clk, reset)
    begin
        if reset = '1' then
            wr_ptr <= (others => '0');
            wr_ptr_gray <= (others => '0');
        elsif rising_edge(wr_clk) then
            if wr_en = '1' and fifo_full_internal = '0' then
                fifo_mem(to_integer(wr_ptr)) <= data_in;
                wr_ptr <= wr_ptr + 1;
                wr_ptr_gray <= to_gray(wr_ptr + 1);
            end if;
        end if;
    end process write_process;

    -- Read process
    read_process : process(rd_clk, reset)
    begin
        if reset = '1' then
            rd_ptr <= (others => '0');
            rd_ptr_gray <= (others => '0');
            data_out <= (others => '0'); -- Reset data_out to zero on reset
        elsif rising_edge(rd_clk) then
            if rd_en = '1' and fifo_empty_internal = '0' then
                data_out <= fifo_mem(to_integer(rd_ptr));
                rd_ptr <= rd_ptr + 1;
                rd_ptr_gray <= to_gray(rd_ptr + 1);
            end if;
            -- Note: The line that resets data_out to zero outside this condition is removed
        end if;
    end process read_process;

    -- Full and empty flag logic
    fifo_full_internal <= '1' when wr_ptr_gray = to_gray(rd_ptr + FIFO_DEPTH - 1) else '0';
    fifo_empty_internal <= '1' when wr_ptr_gray = rd_ptr_gray else '0';

    fifo_full <= fifo_full_internal;
    fifo_empty <= fifo_empty_internal;
end Behavioral;
