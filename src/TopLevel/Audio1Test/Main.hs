{-# LANGUAGE DataKinds #-}
module TopLevel.Audio1Test.Main where

import CLaSH.Prelude
import CLaSH.Signal.Explicit

{-# ANN topEntity
    defTop {
      t_name = "audio1test",
      t_outputs = ["audio"],
      t_extraIn = [("clk_in", 1),
                   ("switch", 1)],
      t_clocks = [
        ClockSource {
          c_name = "passthrough_clock",
          c_inp = [("raw_clk_in", "clk_in(0)")],
          c_outp = [("clk_out", show (sclock :: SClock SystemClock))],
          c_reset = Just ("reset_in", "switch(0)"),
          c_lock = "valid_out",
          c_sync = False
        }
      ]
    } #-}
topEntity :: Signal (BitVector 2)
topEntity = (++#) <$> pulse <*> pulse
  where pulse = register 0 (flipPulse <$> pulse <*> counter)

flipPulse :: Bit -> Unsigned 17 -> Bit
flipPulse dac 0 = complement dac
flipPulse dac _ = dac

counter :: Signal (Unsigned 17)
counter = register 0 (inc <$> counter)

inc :: Unsigned 17 -> Unsigned 17
inc n = n + 1
