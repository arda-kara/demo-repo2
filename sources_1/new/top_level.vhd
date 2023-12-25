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
    transmitter_ready               : out std_logic
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

end Behavioral;