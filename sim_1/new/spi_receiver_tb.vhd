library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity spi_receiver_tb is
end entity spi_receiver_tb;

architecture Behavioral of spi_receiver_tb is
    -- Component Declaration for spi_receiver
    component spi_receiver is
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

    -- Clock period definitions
    constant clk_period : time := 20 ns;

    -- Signal Declarations
    signal master_clk         : std_logic := '0';
    signal reset              : std_logic := '1';
    signal master_ready       : std_logic := '0';
    signal MOSI               : std_logic := '0';
    signal write_permission   : std_logic := '0';
    signal receiver_out       : std_logic_vector(23 downto 0);
    signal pixel_valid        : std_logic;
    signal can_receive        : std_logic;

    -- Test pixel data to send
    signal test_pixel_data    : std_logic_vector(23 downto 0) := x"FFCCEE"; -- Example Pixel Data
    signal pixel_data_counter : integer range 0 to 23 := 0;
    signal test_pixel_data1    : std_logic_vector(23 downto 0) := x"ABCDEF"; -- Example Pixel Data

begin
    -- UUT
    uut: spi_receiver
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

    -- Clock process definitions
    clk_process: process
    begin
        master_clk <= '0';
        wait for clk_period/2;
        master_clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
stim_proc: process
begin
    -- Reset
    wait for 50 ns;
    reset <= '0';
    wait for 50 ns;

    -- Initialize the SPI Transfer
    master_ready <= '1';
    write_permission <= '1';
    wait for clk_period; -- Wait for one clock cycle to ensure stability

    -- Send pixel data bit by bit
    for i in 23 downto 0 loop
        MOSI <= test_pixel_data(i);
        wait for clk_period; -- Wait for one clock cycle
    end loop;

    -- Finish the SPI Transfer
    master_ready <= '0';
    write_permission <= '0';
    wait for clk_period;
    -- Add additional testing scenarios here
    -- Initialize the SPI Transfer
    master_ready <= '1';
    write_permission <= '1';
    wait for clk_period; -- Wait for one clock cycle to ensure stability

    -- Send pixel data bit by bit
    for i in 23 downto 0 loop
        MOSI <= test_pixel_data1(i);
        wait for clk_period; -- Wait for one clock cycle
    end loop;

    -- Finish the SPI Transfer
    master_ready <= '0';
    write_permission <= '0';
    -- Finish the simulation
    wait;
end process;

end Behavioral;
