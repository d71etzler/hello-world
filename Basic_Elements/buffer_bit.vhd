--------------------------------------------------------------------------------
-- File: buffer_bit.vhd
--
-- !THIS FILE IS UNDER REVISION CONTROL!
--
-- $Author:: uid03580  $: Author of last commit
-- $Date:: 2016-08-25 #$: Date of last commit
-- $Rev:: 18           $: Revision of last commit
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
library basic;
  use basic.basic_elements.all;

--------------------------------------------------------------------------------
-- ENTITY definition
--------------------------------------------------------------------------------
entity buffer_bit is
  generic (
    INIT  : std_logic := '0'  -- Initial buffer value
  );
  port (
    -- Input ports -------------------------------------------------------------
    i_sys : in  sys_ctrl_t;   -- System block control
    i_clr : in  std_logic;    -- Buffer clear
    i_tck : in  std_logic;    -- Buffer tick
    i_bit : in  std_logic;    -- Unbuffered bit
    -- Output ports ------------------------------------------------------------
    o_bit : out std_logic     -- Buffered bit
  );
end entity buffer_bit;

--------------------------------------------------------------------------------
-- ARCHITECTURE definition
--------------------------------------------------------------------------------
architecture rtl of buffer_bit is
  -- Constants -----------------------------------------------------------------
  -- (none)
  -- Types ---------------------------------------------------------------------
  -- (none)
  -- Aliases -------------------------------------------------------------------
  -- (none)
  -- Signals -------------------------------------------------------------------
  signal buf_reg  : std_logic := INIT;  -- Buffer register current state
  signal buf_next : std_logic := INIT;  -- Buffer register next state
  -- Atributes -----------------------------------------------------------------
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
  attribute KEEP_HIERARCHY        : string;
  attribute KEEP_HIERARCHY of rtl : architecture is "yes";
begin

-- Assertions ------------------------------------------------------------------
-- (none)

--------------------------------------------------------------------------------
-- Buffer single bit
--------------------------------------------------------------------------------

-- Registers -------------------------------------------------------------------
proc_register:
process(i_sys.clk)
begin
  if (rising_edge(i_sys.clk)) then
    if (i_sys.rst = '1') then
      buf_reg <= INIT;
    else
      buf_reg <= buf_next;
    end if;
  end if;
end process;

-- Input logic -----------------------------------------------------------------
-- (none)

-- Next-state logic ------------------------------------------------------------
proc_next_state:
process(buf_reg, i_sys.ena, i_sys.clr, i_clr, i_tck, i_bit)
begin
  buf_next <= buf_reg;
  if (i_sys.ena = '1') then
    if (i_sys.clr = '1') then
      buf_next <= INIT;
    else
      if (i_clr = '1') then
        buf_next <= INIT;
      elsif (i_tck = '1') then
        buf_next <= i_bit;
      end if;
    end if;
  end if;
end process;

-- Output logic ----------------------------------------------------------------
proc_out_o_bit:
o_bit <= buf_reg;

end architecture rtl;