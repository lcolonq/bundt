module Main.Gizmo where

import Prelude

import Config as Config
import Data.Foldable (for_)
import Data.String (Pattern(..), split)
import Data.String as String
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import UI (addOption, onInput, startBufferRefresh)
import Utils (byId, getSelectValue, setIFrameSrc)

loadBuffer :: forall m. MonadEffect m => String -> m Unit
loadBuffer nm = do
  contents <- byId "lcolonq-gizmo-contents"
  setIFrameSrc (Config.apiServer <> "/gizmo?buf=" <> nm) contents

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from gizmo"
  select <- byId "lcolonq-gizmo-select"
  onInput select \d -> loadBuffer d
  { text: text } <- fetch (Config.apiServer <> "/gizmo/list") {}
  glist <- text
  for_ (split (Pattern "\n") glist) \buf -> do
    when (not $ String.null buf) $ addOption buf select
  initial <- getSelectValue =<< byId "lcolonq-gizmo-select"
  loadBuffer initial
  contents <- byId "lcolonq-gizmo-contents"
  startBufferRefresh contents
