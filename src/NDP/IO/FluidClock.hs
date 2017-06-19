{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}
module NDP.IO.FluidClock () where

import CLaSH.Prelude hiding (undefined)
import CLaSH.Prelude.Explicit
import Control.DeepSeq
import GHC.Generics (Generic)

import NDP.Utils

-- An oscillator that inverts it's output when 'flip' is 'True'
fluidOsc :: SClock clk -> Signal' clk Bool -> Signal' clk Bool
fluidOsc clk flip = osc
  where osc = register' clk False (mux flip inv osc)
        inv = not <$> osc

-- A variable length strobe. It pulses high every `length` ticks. Currently
-- `length` must not drop below 2 or there won't be enough time for the
-- countdown to reset properly.
strobe :: KnownNat n
       => SClock clk
       -> Signal' clk (Unsigned n) -- The length of the loop
       -> Signal' clk Bool -- Pulses high at the start/end of each loop
strobe clk length = reset
  where counter = sub1 <$> register' clk 2 (mux reset length' counter)
        reset = (==0) <$> counter
        -- delay the length signal otherwise the cycle where it gets used is off by one
        length' = register' clk 2 length
        sub1 x = x-1

testIn :: Signal (Unsigned 4)
testIn = fromList [0, 4, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0 :: Unsigned 4]

testIn' :: Signal (Unsigned 4)
testIn' = fromList [4, 4, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8, 4, 4, 4, 4 :: Unsigned 4]
-- testIn' = uDiv2 <$> testIn


data FluidClock = FC {
  clockBeat :: Bit,
  highStrobe :: Bool,
  lowStrobe :: Bool
  } deriving (Show, Generic, NFData)

fcTuple :: FluidClock -> (Bit, Bool, Bool)
fcTuple (FC b h l) = (b, h, l)

-- A clock signal (with strobes for each phase) whose speed can vary. 'cycleDur'
-- mustn't go lower than 4 or the internal counter doesn't have enough time to
-- reset itself during each transition.
fluidClock :: KnownNat n
           => SClock clk
           -> Signal' clk (Unsigned (n+1))
           -> Signal' clk (FluidClock, Unsigned (n+1))
fluidClock clk cycleDur = (,) <$> answer <*> cycleDur'
  where answer = FC <$> (boolToBit <$> beat) <*> highStrobe <*> lowStrobe
        beat = fluidOsc clk mainStrobe
        lowStrobe = (&&) <$> mainStrobe <*> beat
        highStrobe = (&&) <$> mainStrobe <*> (not <$> beat)
        cycleDur' = latch clk highStrobe cycleDur
        phaseDur = uDiv2 <$> cycleDur'
        mainStrobe = strobe clk phaseDur

x = sampleN 17 $ (boolToBit . highStrobe . fst) <$> fluidClock systemClock testIn'
x1 = sampleN 17 $ (clockBeat . fst) <$> fluidClock systemClock testIn
y = sampleN 17 $ snd <$> fluidClock systemClock testIn'


latch :: SClock clk -> Signal' clk Bool -> Signal' clk a -> Signal' clk a
latch clk cond sig = out
  where out = mux ((||) <$> didReset <*> cond) sig prev
        prev = register' clk undefined out
        didReset = register' clk True (signal False)
        
countUp :: Signal Int
countUp = register 0 ((1+) <$> countUp)



thing = Prelude.take 10 $ sampleN 20 ((,) <$> countUp <*> interesting)
  where interesting = latch systemClock (fromList [True, True, True, False]) countUp

--beats = sampleN 17 $ clockBeat <$> fluidClock systemClock testIn'
--hi = sampleN 17 $ (boolToBit . highStrobe) <$> fluidClock systemClock testIn'
--lo = sampleN 17 $ (boolToBit . lowStrobe) <$> fluidClock systemClock testIn'
