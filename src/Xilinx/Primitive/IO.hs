{-# LANGUAGE MagicHash #-}
module Xilinx.Primitive.IO () where

import CLaSH.Prelude
import CLaSH.Prelude.Explicit
import Prelude hiding (undefined)

-- default -> tristate enable -> signal input -> tristate output
tristate :: Bit -> Bit -> Bit -> Bit
tristate d 1 _ = d
tristate _ 0 i = i

--
-- Basic primitives
--

obuft# :: Signal' clk Bit -> -- Tristate enable. Output is undefined when high.
          Signal' clk Bit -> -- Buffer input.
          Signal' clk Bit    -- Tristate buffer output.
obuft# tri input = tristate undefined <$> tri <*> input
{-# NOINLINE obuft# #-}

iobuf# :: Signal' clk Bit -> -- Tristate enable.
          Signal' clk Bit -> -- Buffer input.
          (Signal' clk Bit -> -- Bidirectional input.
           Signal' clk Bit)   -- Bidirectional output.
iobuf# tri bufIn pad

-- no json blob
pulldown# :: Signal' clk Bit -> Signal' clk Bit
pulldown# x = x
{-# NOINLINE pulldown# #-}

-- no json blob
pullup# :: Signal' clk Bit -> Signal' clk Bit
pullup# x = x
{-# NOINLINE pullup# #-}

--
-- Compound primitives
--

-- no json blob
obuftUp# :: Signal' clk Bit -> Signal' clk Bit -> Signal' clk Bit
obuftUp# tri x = tristate 1 <$> tri <*> x
{-# NOINLINE obuftUp# #-}

-- no json blob
obuftDown# :: Signal' clk Bit -> Signal' clk Bit -> Signal' clk Bit
obuftDown# tri x = tristate 0 <$> tri <*> x
{-# NOINLINE obuftDown# #-}
