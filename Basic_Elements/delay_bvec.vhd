--------------------------------------------------------------------------------
-- File: delay_bvec.vhd
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
entity delay_bvec is
  generic (
    LEN    : positive         := 8;                 -- Bit vector length
    DELAY  : natural          := 2;                 -- Delay vector length
    INIT   : std_logic_vector := x"00"              -- Initial delay vector value
  );
  port (
    -- Input ports -------------------------------------------------------------
    i_sys  : in  sys_ctrl_t;                        -- System block control
    i_clr  : in  std_logic;                         -- Delay register clear
    i_bvec : in  std_logic_vector(LEN-1 downto 0);  -- Undelayed bit vector
    -- Output ports ------------------------------------------------------------
    o_bvec : out std_logic_vector(LEN-1 downto 0)   -- Delayed bit vector
  );
end entity delay_bvec;

--------------------------------------------------------------------------------
-- ARCHITECTURE definition
--------------------------------------------------------------------------------
architecture rtl of delay_bvec is
  -- Constants -----------------------------------------------------------------
  -- (none)
  -- Types ---------------------------------------------------------------------
  type std_logic_vect2d_t is array(natural range <>) of std_logic_vector(LEN-1 downto 0);
  -- Aliases -------------------------------------------------------------------
  -- (none)
  -- Signals -------------------------------------------------------------------
  signal delay_reg  : std_logic_vect2d_t(DELAY-1 downto 0) := (others => INIT);
  signal delay_next : std_logic_vect2d_t(DELAY-1 downto 0) := (others => INIT);
  signal delay_tmp  : std_logic_vect2d_t(DELAY-1 downto 0) := (others => INIT);
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
  attribute KEEP_HIERARCHY        : string;
  attribute KEEP_HIERARCHY of rtl : architecture is "yes";
begin

-- Assertions ------------------------------------------------------------------
-- (none)

--------------------------------------------------------------------------------
-- Delay bit vector by DELAY clock cycles
--------------------------------------------------------------------------------

-- Registers -------------------------------------------------------------------
proc_register:
process(i_sys.clk)
begin
  if (rising_edge(i_sys.clk)) then
    if (i_sys.rst = '1') then
      delay_reg <= (others => INIT);
    els
      delay_reg <= delay_next;
    end if;
  end if;
end process;

-- Input logic -----------------------------------------------------------------

-- Input bit vector assignment
gen_in_delay_bit_eq_1:
if (DELAY = 1) generate
  delay_tmp(DELAY-1) <= i_bvec;
end generate;

-- Input bit vector assignment to right shifting register
gen_in_delay_bit_gt_1:
if (DELAY > 1) generate
  delay_tmp <= i_bvec & delay_reg(DELAY-1 downto 1);
end generate;

-- Next-state logic ------------------------------------------------------------
proc_next_state:
process(delay_reg, i_sys.ena, i_sys.clr, i_clr, delay_tmp)
begin
  delay_next <= delay_reg;
  if (i_sys.ena = '1') then
    if (i_sys.clr = '1') then
      delay_next <= (others => INIT);
    else
      if (i_clr = '1') then
        delay_next <= (others => INIT);
      else
        delay_next <= delay_tmp;
      end if;
    end if;
  end if;
end process;

-- Output logic ----------------------------------------------------------------
proc_out_o_bvec:
o_bvec <= delay_reg(0);

end architecture rtl;