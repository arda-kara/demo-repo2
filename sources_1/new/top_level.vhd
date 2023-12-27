library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.func_pkg.all;  -- Ensure this package includes necessary functions like log2ceil

entity top_level_system is
Port (
    master_clk                      : in  std_logic;
    reset                           : in  std_logic;
    master_ready                    : in  std_logic;
    MOSI                            : in  std_logic;
    MISO                            : out std_logic;
    receiver_ready                  : out std_logic;
    transmitter_ready               : out std_logic;
    can_receive                     : out std_logic
);
end top_level_system;

architecture Behavioral of top_level_system is

------------------------------------------------------------
---------------- Component Declarations --------------------
------------------------------------------------------------

    component clk_wiz_0 is
    port(
        reset   : in  std_logic;
        clk_in1 : in  std_logic;
        clk_out1: out std_logic
    );
    end component;
    
    component spi_receiver is
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
    end component;
    
    component spi_transmitter is
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
    end component;
        
    component CDC_Unit_1 is
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
    end component;
    
    component CDC_Unit_2 is
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
    end component;
        
    component grayscale_circuit is
    port(
        sync_clk             : in std_logic;
        reset                : in std_logic;
        gray_in              : in std_logic_vector(23 downto 0);
        process_next_pixel   : in std_logic;
        cdc_fifo_full       : in std_logic;
        input_ready          : out std_logic;
        gray_pixel           : out std_logic_vector(7 downto 0);
        grayscale_data_valid : out std_logic;
        write_to_fifo        : out std_logic
    );
    end component;
    
    component grayscale_module_controller is
    port(
        clk                  : in std_logic;
        reset                : in std_logic;
        fifo_empty           : in std_logic;
        grayscale_data_valid : in std_logic;
        module_input_ready          : in std_logic;
        next_stage_ready     : in std_logic;
        process_next_pixel   : out std_logic
    );
    end component;
    
    component FIFO is
    generic(
        pixel_width : natural;
        FIFO_depth  : natural
    );
    port(
        sync_clk    : in std_logic;
        reset       : in std_logic;
        write_enable: in std_logic;
        read_enable : in std_logic;
        FIFO_in     : in std_logic_vector(23 downto 0);
        FIFO_out    : out std_logic_vector(23 downto 0);
        FIFO_full   : out std_logic;
        FIFO_empty  : out std_logic
    );
    end component;

    component fifo_buffer_controller is
    port(
        clk            : in std_logic;
        reset          : in std_logic;
        data_available : in std_logic;
        FIFO_full      : in std_logic;
        FIFO_empty     : in std_logic;
        grayscale_ready: in std_logic;
        write_enable   : out std_logic;
        read_enable    : out std_logic
    );
    end component;

-- Signal declarations for internal connections
   signal internal_clk : std_logic;
   signal write_permission : std_logic;
   signal write_permission_cdc : std_logic;
   signal receiver_out : std_logic_vector(23 downto 0);
   signal receiver_out_cdc : std_logic_vector(23 downto 0);
   signal pixel_valid : std_logic;
   signal pixel_valid_cdc : std_logic;
   signal cdc_buffer_empty : std_logic;
   signal gray_pixel : std_logic_vector(7 downto 0);
   signal gray_pixel_cdc : std_logic_vector(7 downto 0);
   signal fifo_read_enable : std_logic;
   signal fifo_write_enable : std_logic;
   signal transmitter_empty : std_logic;
   signal transmitter_empty_cdc : std_logic;
   signal fifo_out : std_logic_vector(23 downto 0);
   signal fifo_memory_full : std_logic;
   signal fifo_memory_empty : std_logic;
   signal gray_ready_for_input : std_logic;
   signal process_next_pixel :std_logic; 
   signal cdc1_fifo_full : std_logic;
   signal cdc1_fifo_empty : std_logic;
   signal cdc2_fifo_full : std_logic;
   signal cdc2_fifo_empty : std_logic;
   signal write_to_cdc2 : std_logic;
   signal grayscale_data_valid : std_logic;
   signal grayscale_data_valid_cdc : std_logic;
   
begin


------------------------------------------------------------
---------------- Component Instantiation -------------------
------------------------------------------------------------

    clock_wizard_inst: clk_wiz_0
    port map(
        reset   => reset,        -- Connected to the global reset signal
        clk_in1 => master_clk,   -- Connected to the master clock (50 MHz)
        clk_out1=> internal_clk  -- Output connected to the internal clock signal
    );
    
    spi_receiver_inst: spi_receiver
    port map(
        master_clk => master_clk,
        reset      => reset,
        master_ready => master_ready,
        MOSI=> MOSI,
        write_permission => write_permission,
        receiver_out => receiver_out,
        pixel_valid => pixel_valid,
        can_receive => can_receive
    );
    
    cdc_unit_1_inst: CDC_Unit_1 
    port map(
        master_clk => master_clk,
        internal_clk => internal_clk,
        reset => reset,
        receiver_out => receiver_out,
        pixel_valid => pixel_valid,
        receiver_out_cdc => receiver_out_cdc,
        pixel_valid_cdc => pixel_valid_cdc,
        cdc_write => pixel_valid,
        write_permission => write_permission,
        cdc_read => fifo_write_enable,
        write_permission_cdc => write_permission_cdc,
        fifo_empty => cdc1_fifo_empty,
        fifo_full => cdc1_fifo_full
    );
    
    fifo_module_inst: FIFO
    generic map(
        pixel_width => 24,   -- RGB = 3 Bytes = 24 bits
        FIFO_depth  => 36000 -- Approx. 12% of a 640x480 image
    )
    port map(
        sync_clk    => internal_clk,   -- From top-level (200 MHz)
        reset       => reset,          -- From top-level
        write_enable=> fifo_write_enable,   -- From FIFO Controller
        read_enable => fifo_read_enable,    -- From FIFO Controller
        FIFO_in     => receiver_out_cdc, -- From CDC Unit-1
        FIFO_out    => fifo_out,       -- To Grayscale Module
        FIFO_full   => fifo_memory_full,      -- To FIFO Controller
        FIFO_empty  => fifo_memory_empty      -- To FIFO Controller and Grayscale Module Controller
    );
    
    fifo_controller_inst: fifo_buffer_controller
    port map(
        clk            => internal_clk,    -- From top-level (200 MHz)
        reset          => reset,           -- From top-level
        data_available => pixel_valid_cdc, -- From CDC Unit-1
        FIFO_full      => fifo_memory_full,       -- From FIFO Module
        FIFO_empty     => fifo_memory_empty,      -- From FIFO Module
        grayscale_ready=> gray_ready_for_input,     -- From Grayscale Module
        write_enable   => fifo_write_enable,    -- To FIFO Module
        read_enable    => fifo_read_enable      -- To FIFO Module
    );
    
    grayscale_module_inst: grayscale_circuit
    port map(
        sync_clk             => internal_clk,    -- From top-level (200 MHz)
        reset                => reset,           -- From top-level
        gray_in              => fifo_out,        -- From FIFO Module
        process_next_pixel   => process_next_pixel, -- From Grayscale Controller
        cdc_fifo_full        => cdc2_fifo_full,      -- From CDC Unit-2
        input_ready          => gray_ready_for_input,     -- To Grayscale Controller
        gray_pixel           => gray_pixel,      -- To CDC Unit-2
        grayscale_data_valid => grayscale_data_valid, -- To CDC Unit-2 & Grayscale Controller
        write_to_fifo        => write_to_cdc2    -- To CDC Unit-2
    );
    
    grayscale_controller_inst: grayscale_module_controller
    port map(
        clk                  => internal_clk,    -- From top-level (200 MHz)
        reset                => reset,           -- From top-level
        fifo_empty           => transmitter_empty_cdc,      -- From SPI Transmitter (via CDC Unit-2)
        grayscale_data_valid => grayscale_data_valid, -- From Grayscale Module
        module_input_ready   => gray_ready_for_input,     -- From Grayscale Module
        next_stage_ready     => transmitter_empty_cdc,-- From CDC Unit-2
        process_next_pixel   => process_next_pixel -- To Grayscale Module
    );

    cdc_unit_2_inst: CDC_Unit_2
    port map(
        internal_clk => internal_clk,
        master_clk => master_clk,
        reset => reset,
        gray_pixel => gray_pixel,
        data_valid => grayscale_data_valid,
        cdc_write => write_to_cdc2,
        gray_pixel_cdc => gray_pixel_cdc,
        data_valid_cdc => grayscale_data_valid_cdc,
        buffer_empty => transmitter_empty,
        cdc_read => transmitter_empty,
        buffer_empty_cdc => transmitter_empty_cdc,
        fifo_full => cdc2_fifo_full,
        fifo_empty => cdc2_fifo_empty
            
    );
    
    spi_transmitter_inst: spi_transmitter
    port map(
        master_clk => master_clk,
        reset => reset,
        cdc_fifo_empty => cdc2_fifo_empty,
        cdc_out => gray_pixel_cdc,
        master_ready => master_ready,
        transmitter_empty => transmitter_empty,
        MISO => MISO,
        transmitter_ready => transmitter_ready
    );
end Behavioral;
