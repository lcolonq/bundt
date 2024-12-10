module Main.Pubnix where

import Prelude

import Audio as Audio
import Auth (getToken)
import Config as Config
import Data.Array as Array
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import Model (startModel)
import Utils (byId, checkAuth, listen, setText)

updateSubtitle :: Aff Unit
updateSubtitle = do
  subtitle <- byId "lcolonq-pubnix-index-subtitle"
  { text: catchphrase } <- fetch (Config.apiServer <> "/catchphrase") {}
  catchphrase >>= setText subtitle

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hi"
  startModel
  marq <- byId "lcolonq-pubnix-index-marquee"
  { text: motd } <- fetch (Config.apiServer <> "/motd") {}
  motd >>= setText marq

  getToken >>= case _ of
    Just a@(Tuple t n) -> do
      liftEffect $ log t
      liftEffect $ log n
      checkAuth a >>= log >>> liftEffect
    _ -> pure unit

  updateSubtitle
  subtitle <- byId "lcolonq-pubnix-index-subtitle"
  listen subtitle "click" \_ev -> do
    -- startTwitchAuth
    launchAff_ updateSubtitle
  
  for_ (Array.range 0 6) \i -> do
    letter <- byId $ "lcolonq-pubnix-index-letter-" <> show i
    listen letter "click" \_ev -> do
      Audio.playVoice true i
    listen letter "mouseover" \_ev -> do
      Audio.playVoice false i
