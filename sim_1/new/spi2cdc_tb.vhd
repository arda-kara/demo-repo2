library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_spi_cdc is
end entity tb_spi_cdc;

architecture sim of tb_spi_cdc is
    -- Component Declarations
    component spi_receiver
        port(
            master_clk         : in  std_logic;
            reset              : in  std_logic;
            master_ready       : in  std_logic;
            MOSI               : in  std_logic;
            write_permission   : in  std_logic;
            receiver_out       : out std_logic_vector(23 downto 0);
            pixel_valid        : out std_logic;
            can_receive        : out std_logic
        );
    end component;

    component CDC_Unit_1
        port(
            master_clk         : in std_logic;
            internal_clk       : in std_logic;
            reset              : in std_logic;
            receiver_out       : in std_logic_vector(23 downto 0);
            pixel_valid        : in std_logic;
            receiver_out_cdc   : out std_logic_vector(23 downto 0);
            pixel_valid_cdc    : out std_logic;
            cdc_read           : in  std_logic;
            cdc_write          : in std_logic;
            write_permission   : in std_logic;
            write_permission_cdc : out std_logic;
            fifo_empty         : out std_logic;
            fifo_full          : out std_logic
        );
    end component;

--    component clk_wiz_0
--        port(
--            reset    : in  std_logic;
--            clk_in1  : in  std_logic;
--            clk_out1 : out std_logic
--        );
--    end component;

    -- Signals for interconnecting components and testbench
    signal master_clk         : std_logic := '0';
    signal internal_clk       : std_logic := '0'; 
    signal clk_wiz_reset      : std_logic := '0';
    signal reset              : std_logic := '1';
    signal master_ready       : std_logic := '0';
    signal MOSI               : std_logic := '0';
    signal write_permission   : std_logic := '1';
    signal receiver_out       : std_logic_vector(23 downto 0);
    signal pixel_valid        : std_logic;
    signal can_receive        : std_logic;
    signal receiver_out_cdc   : std_logic_vector(23 downto 0);
    signal pixel_valid_cdc    : std_logic;
    signal cdc_read_ctrl      : std_logic := '1';
    signal cdc_write_ctrl     : std_logic := '1';
    signal write_permission_cdc : std_logic;
    signal fifo_empty         : std_logic;
    signal fifo_full          : std_logic;
    signal test_pixel_data    : std_logic_vector(23 downto 0) := x"FFCCEE";
    signal test_pixel_data1    : std_logic_vector(23 downto 0) := x"ABCDEF"; -- Example Pixel Data

begin
    -- SPI Receiver Instance
    uut_spi_receiver: spi_receiver
        port map (
            master_clk => master_clk,
            reset => reset,
            master_ready => master_ready,
            MOSI => MOSI,
            write_permission => write_permission,
            receiver_out => receiver_out,
            pixel_valid => pixel_valid,
            can_receive => can_receive
        );

    -- CDC Unit-1 Instance
    uut_cdc_unit_1: CDC_Unit_1
        port map (
            master_clk => master_clk,
            internal_clk => internal_clk,
            reset => reset,
            receiver_out => receiver_out,
            pixel_valid => pixel_valid,
            receiver_out_cdc => receiver_out_cdc,
            pixel_valid_cdc => pixel_valid_cdc,
            write_permission => write_permission,
            write_permission_cdc => write_permission_cdc,
            fifo_empty => fifo_empty,
            fifo_full => fifo_full,
            cdc_read => cdc_read_ctrl,
            cdc_write => cdc_write_ctrl
        );

--    -- Clock Wizard Instance
--    clk_wizard: clk_wiz_0
--        port map (
--            reset => clk_wiz_reset,
--            clk_in1 => master_clk,
--            clk_out1 => internal_clk
--        );

    -- Master Clock Process (50 MHz)
    master_clk_process: process
    begin
        while true loop
            master_clk <= not master_clk; 
            wait for 20 ns;  -- 50 MHz clock
        end loop;
    end process;

    internal_clk_process: process
    begin
    while true loop
            internal_clk <= not internal_clk; 
            wait for 5 ns;  -- 200 MHz clock
        end loop;
    end process;
    
    
    -- Test Stimulus Process
    stimulus: process
        variable pixel_data : std_logic_vector(23 downto 0) := x"CCBBAA"; -- Test RGB pixel
    begin
        
        -- Reset
        wait for 50 ns;
        reset <= '1';
        wait for 50 ns;
        
        
        -- Initialize SPI
        master_ready <= '1';
        write_permission <= '1';
        wait for 20 ns;
        
        
        -- Send pixel data bit by bit
        for i in 23 downto 0 loop
            MOSI <= test_pixel_data(i);
            wait for 20 ns; -- Wait for one clock cycle
        end loop;        
        
        -- Finish SPI Transfer
        master_ready <= '0';
        write_permission <= '0';
        wait for 20 ns;
        -- End of simulation
        wait; 
    end process;

end sim;
