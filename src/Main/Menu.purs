module Main.Menu where

import Prelude

import Data.Foldable (for_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import UI as UI
import Utils (listen, queryAll)
import Web.Event.Event as Ev

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from menu"
  textareas <- queryAll "textarea"
  for_ textareas \ta -> listen ta "click" Ev.stopPropagation
  boxes <- queryAll ".lcolonq-menu-box"
  for_ boxes \box -> do
    listen box "click" \_ev -> do
      UI.submitRedeem box
