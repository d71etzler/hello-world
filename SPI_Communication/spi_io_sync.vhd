--------------------------------------------------------------------------------
-- File: spi_io_sync.vhd
--
-- !THIS FILE IS UNDER REVISION CONTROL!
--
-- $Author:: uid03580  $: Author of last commit
-- $Date:: 2016-08-25 #$: Date of last commit
-- $Rev:: 20           $: Revision of last commit
--
-- Open Points/Remarks:
--  + (none)
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Used library definitions
--------------------------------------------------------------------------------
library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;
library sync;
  use sync.sync_elements.all;

--------------------------------------------------------------------------------
-- ENTITY definition
--------------------------------------------------------------------------------
entity spi_io_sync is
  generic (
    SPI_GUARD_LEN   : natural   := 1;     -- SPI guard length flip-flop shift register length
    SPI_CSEL_N_INIT : std_logic := '1';   -- SPI chip select initial synchronization value
    SPI_SCLK_INIT   : std_logic := '0';   -- SPI clock initial synchronization value
    SPI_SDI_INIT    : std_logic := '0'    -- Serial input data initial synchronization value
  );
  port (
    -- Input ports -------------------------------------------------------------
    i_rst           : in  std_logic;      -- Reset
    i_clk           : in  std_logic;      -- System clock
    i_csel_na       : in  std_logic;      -- SPI chip select (low-active, asynchronous)
    i_sclk_a        : in  std_logic;      -- SPI clock (asynchronous)
    i_sdi_a         : in  std_logic;      -- Serial input data (asynchronous)
    -- Output ports ------------------------------------------------------------
    o_csel_n        : out std_logic;      -- SPI chip select (low-active, synchronous)
    o_sclk          : out std_logic;      -- SPI clock (synchronous)
    o_sdi           : out std_logic       -- Serial input data (synchronous)
  );
end entity spi_io_sync;

--------------------------------------------------------------------------------
-- ARCHITECTURE definition
--------------------------------------------------------------------------------
architecture structural of spi_io_sync is
  -- Types ---------------------------------------------------------------------
  type spi_signal_t is (SDI, SCLK, CSEL_N);                               -- SPI signals
  type spi_signal_vector_t is array (spi_signal_t) of std_logic;          -- SPI signal vector type
  -- Constants -----------------------------------------------------------------
  constant C_SPI_IO_SYNC_GUARD_LEN : natural             := SPI_GUARD_LEN;                                      -- Synchronization guard length
  constant C_SPI_IO_SYNC_VECT_INIT : spi_signal_vector_t := (SPI_SDI_INIT & SPI_SCLK_INIT & SPI_CSEL_N_INIT);   -- Synchronization vector initial values
  -- Aliases -------------------------------------------------------------------
  -- (none)
  -- Signals -------------------------------------------------------------------
  signal spi_signals_a : spi_signal_vector_t := C_SPI_IO_SYNC_VECT_INIT;  -- SPI signal vector (asynchronous)
  signal spi_signals   : spi_signal_vector_t := C_SPI_IO_SYNC_VECT_INIT;  -- SPI signal vector (synchronous)
  -- Attributes ----------------------------------------------------------------
  -- KEEP_HIERARCHY is used to prevent optimizations along the hierarchy
  -- boundaries.  The Vivado synthesis tool attempts to keep the same general
  -- hierarchies specified in the RTL, but for QoR reasons it can flatten or
  -- modify them.
  -- If KEEP_HIERARCHY is placed on the instance, the synthesis tool keeps the
  -- boundary on that level static.
  -- This can affect QoR and also should not be used on modules that describe
  -- the control logic of 3-state outputs and I/O buffers.  The KEEP_HIERARCHY
  -- can be placed in the module or architecture level or the instance.  This
  -- attribute can only be set in the RTL.
--  attribute KEEP_HIERARCHY                     : string;
--  attribute KEEP_HIERARCHY of __example_unit__ : label is "yes";
  -- Use the KEEP attribute to prevent optimizations where signals are either
  -- optimized or absorbed into logic blocks. This attribute instructs the
  -- synthesis tool to keep the signal it was placed on, and that signal is
  -- placed in the netlist.
  -- For example, if a signal is an output of a 2 bit AND gate, and it drives
  -- another AND gate, the KEEP attribute can be used to prevent that signal
  -- from being merged into a larger LUT that encompasses both AND gates.
  -- KEEP is also commonly used in conjunction with timing constraints. If there
  -- is a timing constraint on a signal that would normally be optimized, KEEP
  -- prevents that and allows the correct timing rules to be used.
  -- Note: The KEEP attribute is not supported on the port of a module or
  -- entity. If you need to keep specific ports, either use the
  -- -flatten_hierarchy none setting, or put a DONT_TOUCH on the module or
  -- entity itself.
--  attribute KEEP                       : string;
--  attribute KEEP of __example_signal__ : signal is "true";
begin

-- Assertions ------------------------------------------------------------------
-- (none)

--------------------------------------------------------------------------------
-- SPI IO signal synchronization
--------------------------------------------------------------------------------

-- Input logic -----------------------------------------------------------------

-- SPI Serial-Data-In assignment
proc_in_spi_signals_a_sdi:
spi_signals_a(SDI) <= i_sdi_a;

-- SPI Spi-CLK assignment
proc_in_spi_signals_a_sclk:
spi_signals_a(SCLK) <= i_sclk_a;

-- SPI Chip-SELection (negated) assignment
proc_in_spi_signals_a_csel_n:
spi_signals_a(CSEL_N) <= i_csel_na;

-- Component instantiation -----------------------------------------------------
gen_spi_io_sync_unit:
for i in spi_signal_t generate
  spi_io_sync_unit: sync_bit
    generic map (
      GUARD_LEN => C_SPI_IO_SYNC_GUARD_LEN,
      SYNC_INIT => C_SPI_IO_SYNC_VECT_INIT(i)
    )
    port map (
      -- Input ports -----------------------------------------------------------
      i_rst     => i_rst,
      i_clk     => i_clk,
      i_bit_a   => spi_signals_a(i),
      -- Output ports ----------------------------------------------------------
      o_bit     => spi_signals(i)
    );
end generate;

-- Output logic ----------------------------------------------------------------

-- SPI Serial-Data-In assignment
proc_out_o_sdi:
o_sdi <= spi_signals(SDI);

-- SPI Spi-CLK assignment
proc_out_o_sclk:
o_sclk <= spi_signals(SCLK);

-- SPI Chip-SELection (negated) assignment
proc_out_o_csel_n:
o_csel_n <= spi_signals(CSEL_N);

end architecture structural;