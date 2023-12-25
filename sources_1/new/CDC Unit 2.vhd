library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.func_pkg.all;  -- Ensure this package includes necessary functions like log2ceil

entity CDC_Unit_2 is
    port(
        -- Clocks
        internal_clk    : in std_logic;  -- 200 MHz internal clock
        master_clk      : in std_logic;  -- 50 MHz master clock

        -- Reset
        reset           : in std_logic;

        -- Signals from Grayscale Module (200 MHz domain)
        gray_pixel   : in std_logic_vector(7 downto 0);
        data_valid   : in std_logic;  -- Grayscale data valid
        cdc_write    : in std_logic;
        
        -- Signals to SPI Transmitter (50 MHz domain)
        gray_pixel_cdc  : out std_logic_vector(7 downto 0);
        data_valid_cdc  : out std_logic;  -- Synchronized data valid signal

        -- Signal from SPI Transmitter (50 MHz domain)
        buffer_empty : in std_logic;  -- Transmitter buffer empty
        cdc_read     : in std_logic;

        -- Signal to Grayscale Module (200 MHz domain)
        buffer_empty_cdc : out std_logic; -- Synchronized buffer empty signal

        -- Buffer state signals
        fifo_full       : out std_logic;  -- Indicates if the internal FIFO is full
        fifo_empty      : out std_logic   -- Indicates if the internal FIFO is empty
    );
end entity;

architecture Behavioral of CDC_Unit_2 is

    -- Instantiate Dual Clock FIFO for gray_pixel
    component async_fifo is
        generic(
            DATA_WIDTH : natural := 8;
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
            fifo_empty  : out std_logic;
            fifo_full : out std_logic
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

    -- Dual Clock FIFO for gray_pixel data
    gray_pixel_fifo: async_fifo
        generic map (
            DATA_WIDTH => 8,
            FIFO_DEPTH => 160
        )
        port map (
            wr_clk     => internal_clk,
            rd_clk     => master_clk,
            reset      => reset,
            data_in    => gray_pixel,
            data_out   => gray_pixel_cdc,
            wr_en      => data_valid,
            rd_en      => '1', -- Always ready to read in SPI Transmitter clock domain
            fifo_full  => fifo_empty,
            fifo_empty => fifo_full
        );

    -- Synchronize data_valid signal from Grayscale Module to SPI Transmitter
    sync_data_valid: cdc_single_bit
        port map (
            clk_a      => internal_clk,
            clk_b      => master_clk,
            signal_in  => data_valid,
            signal_out => data_valid_cdc
        );

    -- Synchronize buffer_empty signal from SPI Transmitter to Grayscale Module
    sync_buffer_empty: cdc_single_bit
        port map (
            clk_a      => master_clk,
            clk_b      => internal_clk,
            signal_in  => buffer_empty,
            signal_out => buffer_empty_cdc
        );

end Behavioral;
