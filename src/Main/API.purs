module Main.API where

import Control.Monad (pure)
import Data.Unit (Unit, unit)
import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit
main = launchAff_ do
  pure unit
