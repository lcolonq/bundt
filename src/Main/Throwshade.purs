module Main.Throwshade where

import Prelude

import Config as Config
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import UI (setShader, submitShader)
import Utils (byId, getTextArea, listen, setText)

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello it is throwshade"
  input <- byId "lcolonq-throwshade-textarea"
  test <- byId "lcolonq-throwshade-button-test"
  { text: shader } <- fetch (Config.apiServer <> "/shader") {}
  cur <- byId "lcolonq-throwshade-current"
  setText cur =<< shader
  listen test "click" \_ -> do
    s <- getTextArea input
    setShader s
  submit <- byId "lcolonq-throwshade-button-submit"
  listen submit "click" \_ -> do
    s <- getTextArea input
    submitShader s
