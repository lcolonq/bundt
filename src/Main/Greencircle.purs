module Main.Greencircle where

import Prelude

import Config as Config
import Data.Array as Array
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.String.Pattern as String
import Data.Traversable (for, for_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import UI as UI
import Utils as Utils

adjective :: Int -> String
adjective x
  | x == 0 = "sleepy"
  | x == 1 = "singular"
  | x == 2 = "double trouble"
  | x == 3 = "triplicate"
  | otherwise = "relentless"

updateLive :: Effect Unit
updateLive = launchAff_ do
  { text: resp } <- fetch (Config.apiServer <> "/circle") {}
  res <- resp
  let names =
        Array.filter (not <<< String.null)
        $ String.split (String.Pattern " ")
        $ String.replaceAll (String.Pattern "\"") (String.Replacement "")
        $ String.replaceAll (String.Pattern "(") (String.Replacement "")
        $ String.replaceAll (String.Pattern ")") (String.Replacement "") res
  adj <- Utils.byId "lcolonq-gc-adjective"
  Utils.setText adj $ adjective $ Array.length names
  for_ names \n -> do
    liftEffect $ log n
    p <- Utils.byId $ "lcolonq-gc-panel-" <> n
    Utils.addClass "lcolonq-gc-visible" p

main :: Effect Unit
main = do
  liftEffect $ log "hello it is greencircle"
  updateLive
