module Main.Register where

import Prelude

import Auth (authHeader, getToken, startTwitchAuth)
import Config as Config
import Data.Maybe (Maybe(..))
import Data.String as String
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import Utils (byId, listen, removeClass, setText)

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from registration page"
  link <- byId "lcolonq-register-link"
  getToken >>= case _ of
    Just a@(Tuple _t _n) -> do -- if there's an auth token in the fragment, ask the API to register us
      { text: resp } <- fetch (Config.apiServer <> "/register")
        { headers:
          { "Authorization": authHeader a
          }
        }
      r <- resp
      case String.split (String.Pattern " ") r of
        [user, pass] -> do
          container <- byId "lcolonq-registered-container"
          removeClass "lcolonq-invisible" container
          fieldUsername <- byId "lcolonq-registered-username"
          setText fieldUsername user
          fieldPassword <- byId "lcolonq-registered-password"
          setText fieldPassword pass
        _ -> do
          container <- byId "lcolonq-register-error-container"
          removeClass "lcolonq-invisible" container
    _ -> do -- otherwise, show the button to register
      container <- byId "lcolonq-register-container"
      removeClass "lcolonq-invisible" container
      listen link "click" \_ev -> do
        liftEffect $ log "register"
        startTwitchAuth
