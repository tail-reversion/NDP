library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity passthrough_clock is

  port (
    raw_clk_in : in  std_logic;         -- raw input clock
    reset_in   : in  std_logic;         -- global reset signal
    clk_out    : out std_logic;         -- properly buffered output clock
    valid_out  : out std_logic);        -- clock is locked and signal is valid

end entity passthrough_clock;

architecture rtl of passthrough_clock is

  signal clk_en : std_logic;

begin

  clk_en <= not reset_in;

  valid_out <= clk_en;

  bufgce_inst : BUFGCE
    port map ( I => raw_clk_in,
               O => clk_out,
               CE => clk_en );

end architecture rtl;
