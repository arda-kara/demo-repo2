library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity async_fifo_tb is
    -- Testbench has no ports
end entity async_fifo_tb;

architecture behavior_tb of async_fifo_tb is 
    -- Component Declaration for the Unit Under Test (UUT)
    component async_fifo
        generic(
            DATA_WIDTH : natural := 24;
            FIFO_DEPTH : natural := 256
        );
        port(
            wr_clk     : in std_logic;
            rd_clk     : in std_logic;
            reset      : in std_logic;
            data_in    : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            wr_en      : in std_logic;
            rd_en      : in std_logic;
            fifo_full  : out std_logic;
            fifo_empty : out std_logic
        );
    end component;

    -- Inputs
    signal wr_clk : std_logic := '0';
    signal rd_clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal data_in : std_logic_vector(23 downto 0) := (others => '0');
    signal wr_en : std_logic := '0';
    signal rd_en : std_logic := '0';

    -- Outputs
    signal data_out : std_logic_vector(23 downto 0);
    signal fifo_full : std_logic;
    signal fifo_empty : std_logic;

    -- Clock period definitions
    constant wr_clk_period : time := 20 ns; -- 50 MHz
    constant rd_clk_period : time := 5 ns;  -- 200 MHz

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: async_fifo
        port map (
            wr_clk => wr_clk,
            rd_clk => rd_clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out,
            wr_en => wr_en,
            rd_en => rd_en,
            fifo_full => fifo_full,
            fifo_empty => fifo_empty
        );

    -- Clock process definitions
    wr_clk_process : process
    begin
        wr_clk <= '0';
        wait for wr_clk_period/2;
        wr_clk <= '1';
        wait for wr_clk_period/2;
    end process;

    rd_clk_process : process
    begin
        rd_clk <= '0';
        wait for rd_clk_period/2;
        rd_clk <= '1';
        wait for rd_clk_period/2;
    end process;

    -- Test process
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for 40 ns;
        reset <= '0';

        -- Write data
        for i in 0 to 10 loop
            wait until rising_edge(wr_clk);
            if fifo_full = '0' then
                data_in <= std_logic_vector(to_unsigned(i, 24));
                wr_en <= '1';
            else
                wr_en <= '0';
            end if;
        end loop;
        wr_en <= '0';
        
        -- Read data
        for i in 0 to 10 loop
            wait until rising_edge(rd_clk);
            rd_en <= '1';
        end loop;
        rd_en <= '0';

        -- Complete the simulation
        wait for 100 ns;
        report "End of simulation";
        wait;
    end process;

end behavior_tb;
