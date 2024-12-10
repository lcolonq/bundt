module Main.Button where

import Prelude

import Config as Config
import Data.HTTP.Method (Method(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import Utils (byId, listen)

buttonPress :: String -> Aff Unit
buttonPress b = do
  void $ fetch (Config.apiServer <> "/sentiment/" <> b)
    { method: POST
    }
main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from button"
  green <- byId "lcolonq-button-link-green"
  listen green "click" \_ev -> do
    liftEffect $ log "+2"
    launchAff_ $ buttonPress "green"
  red <- byId "lcolonq-button-link-red"
  listen red "click" \_ev -> do
    liftEffect $ log "-2"
    launchAff_ $ buttonPress "red"
