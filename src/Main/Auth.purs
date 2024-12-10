module Main.Auth where

import Prelude

import Auth (getQueryRedirect, getResponseRedirect)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Fetch (fetch)
import UI as UI
import Utils (byId, getValue, listen, removeClass)
import Web.Event.Event as Ev

main :: Effect Unit
main = launchAff_ do
  liftEffect $ log "hello from auth"
  container <- byId "lcolonq-auth-login"
  removeClass "lcolonq-invisible" container
  form <- byId "lcolonq-auth-form"
  listen form "submit" \ev -> launchAff_ do
    liftEffect $ Ev.preventDefault ev
    usernameInp <- byId "lcolonq-auth-username"
    passwordInp <- byId "lcolonq-auth-password"
    username <- getValue usernameInp
    password <- getValue passwordInp
    rd <- getQueryRedirect
    { json: resp } <- fetch "/api/firstfactor"
      { method: POST
      , headers: { "Content-Type": "application/json" }
      , body: UI.toJSON
        { username
        , password
        , targetURL: case rd of
            Just r -> r
            Nothing -> "https://secure.colonq.computer"
        }
      }
    res <- resp
    getResponseRedirect res >>= case _ of
      Nothing -> do
        err <- byId "lcolonq-auth-error"
        removeClass "lcolonq-invisible" err
      Just r -> UI.redirect r
