library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.func_pkg.all;

entity CDC_Unit_1 is
    port(
        -- Clocks
        master_clk         : in std_logic;
        internal_clk       : in std_logic;

        -- Reset
        reset              : in std_logic;

        -- Signals from SPI Receiver (50 MHz domain)
        receiver_out       : in std_logic_vector(23 downto 0);
        pixel_valid        : in std_logic;  -- Retained
        

        -- Signals to FIFO Buffer and Controller (200 MHz domain)
        receiver_out_cdc   : out std_logic_vector(23 downto 0);
        pixel_valid_cdc    : out std_logic;  -- Retained
        cdc_write          : in std_logic;  -- New signal
        
        -- Signal from FIFO Buffer Controller (200 MHz domain)
        write_permission       : in std_logic;
        cdc_read               : in std_logic;  -- New signal for read enable 

        -- Signal to SPI Receiver and FIFO Buffer (50 MHz domain)
        write_permission_cdc   : out std_logic;
        
        -- CDC FIFO signals
        fifo_empty         : out std_logic;
        fifo_full          : out std_logic       
    );
end entity;

architecture Behavioral of CDC_Unit_1 is
    -- Instantiate Dual Clock FIFO for receiver_out
    component async_fifo is
        generic(
            DATA_WIDTH : natural := 24;
            FIFO_DEPTH : natural := 160
        );
        port(
            wr_clk     : in  std_logic;
            rd_clk     : in  std_logic;
            reset      : in  std_logic;
            data_in    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            wr_en      : in  std_logic;
            rd_en      : in  std_logic;
            fifo_full  : out std_logic;
            fifo_empty : out std_logic
        );
    end component;

    -- Instantiate Dual Flip Flop Synchronizers
    component cdc_single_bit is
        port(
            clk_a      : in  std_logic;
            clk_b      : in  std_logic;
            signal_in  : in  std_logic;
            signal_out : out std_logic
        );
    end component;

begin
    -- Dual Clock FIFO for receiver_out data
    receiver_out_fifo: async_fifo
        generic map (
            DATA_WIDTH => 24,
            FIFO_DEPTH => 160
        )
        port map (
            wr_clk     => master_clk,
            rd_clk     => internal_clk,
            reset      => reset,
            data_in    => receiver_out,
            data_out   => receiver_out_cdc,
            wr_en      => cdc_write,      -- Changed to cdc_write
            rd_en      => cdc_read,        -- New signal for read enable
            fifo_empty  => fifo_empty,
            fifo_full => fifo_full
        );

    -- Synchronize pixel_valid signal from SPI Receiver to FIFO Buffer Controller
    sync_pixel_valid: cdc_single_bit
        port map (
            clk_a      => master_clk,
            clk_b      => internal_clk,
            signal_in  => pixel_valid,
            signal_out => pixel_valid_cdc
        );

    -- Synchronize write_permission signal from FIFO Buffer Controller to SPI Receiver and FIFO Buffer
    sync_write_permission: cdc_single_bit
        port map (
            clk_a      => internal_clk,
            clk_b      => master_clk,
            signal_in  => write_permission,
            signal_out => write_permission_cdc
        );

end Behavioral;
