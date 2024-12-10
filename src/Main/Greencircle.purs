module Main.Greencircle where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)

main :: Effect Unit
main = do
  liftEffect $ log "hello it is greencircle"
