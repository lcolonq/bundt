module Main.Throwshade where

import Prelude

import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import UI (setShader, submitShader)
import Utils (byId, getTextArea, listen)

main :: Effect Unit
main = do
  liftEffect $ log "hello it is throwshade"
  input <- byId "lcolonq-throwshade-textarea"
  test <- byId "lcolonq-throwshade-button-test"
  listen test "click" \_ -> do
    s <- getTextArea input
    setShader s
  submit <- byId "lcolonq-throwshade-button-submit"
  listen submit "click" \_ -> do
    s <- getTextArea input
    submitShader s
