module Make.Xilinx (xilinxSSH) where

import Development.Shake
import Development.Shake.Config

import Make.Vagrant

xilinxSSH :: [String] -> Action ()
xilinxSSH args = do
  -- grab the settings file
  (Just settingsF) <- getConfig "XILINX_SETTINGS"

  -- Run the command
  vagrantSSH $ ["source", settingsF, ";"] ++ args

