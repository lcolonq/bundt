module Main.Charsheet where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from charsheet"
