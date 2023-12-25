library IEEE;
use IEEE.std_logic_1164.all;

entity cdc_single_bit is
    port(
        clk_a      : in  std_logic; -- Source clock domain
        clk_b      : in  std_logic; -- Destination clock domain
        signal_in  : in  std_logic; -- Input signal from source clock domain
        signal_out : out std_logic  -- Output signal in destination clock domain
    );
end entity;

architecture Behavioral of cdc_single_bit is
    signal sync_reg : std_logic_vector(1 downto 0) := (others => '0');
begin
    -- Synchronizer chain in destination clock domain
    sync_process: process(clk_b)
    begin
        if rising_edge(clk_b) then
            sync_reg(0) <= signal_in;             -- First flip-flop
            sync_reg(1) <= sync_reg(0);           -- Second flip-flop
        end if;
    end process;

    signal_out <= sync_reg(1); -- Output from the last flip-flop
end Behavioral;
