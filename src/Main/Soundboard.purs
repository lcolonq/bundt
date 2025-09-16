module Main.Soundboard where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import UI as UI
import Utils (byId, getValue, listen)
import Web.UIEvent.KeyboardEvent as KbEv

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from soundboard"
  el <- byId "lcolonq-soundboard-entry"
  listen el "keydown" \ev -> launchAff_ do
    case KbEv.fromEvent ev of
      Just kbev -> do
        when ("Enter" == KbEv.code kbev) do
          inp <- getValue el
          UI.submitRedeem "sound board" inp
      Nothing -> pure unit
