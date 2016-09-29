module Main where

import Data.Maybe
import Development.Shake
import Development.Shake.Config
import Development.Shake.FilePath


import Clash
import Config
import Oracles
import TileROM



main :: IO ()
main = shakeArgs shakeOptions $ do
  installOracles
  setupConfig "NDP.config"

  phony "setup" $ do
    cmd "stack build clash-ghc"

  phony "clean" $ do
    cmd "rm -rvf build"

  phony "test" $ do
    cmd "stack exec test-ndp"

  clashRules
  tileROMRules
