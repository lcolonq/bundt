module Main.OBS where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Model (startModel)

main :: Effect Unit
main = launchAff_ do
  startModel
