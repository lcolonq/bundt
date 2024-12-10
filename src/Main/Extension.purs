module Main.Extension where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import UI as UI
import Utils (appendElement, appendText, create, query)

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from extension"
  UI.setInterval 1000.0 do
    e <- query ".chat-scrollable-area__message-container"
    new <- create "div" [".chat-line__message"] []
    appendText new "test"
    appendElement e new
