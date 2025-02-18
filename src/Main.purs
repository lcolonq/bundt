module Main where

import Prelude

import Config as Config
import Effect (Effect)
import Effect.Exception (throw)
import Main.API as API
import Main.Auth as Auth
import Main.Button as Button
import Main.Extension as Extension
import Main.Greencircle as Greencircle
import Main.Menu as Menu
import Main.OBS as OBS
import Main.Pubnix as Pubnix
import Main.Register as Register
import Main.Throwshade as Throwshade

main :: Effect Unit
main = case Config.mode of
  "api" -> API.main
  "pubnix" -> Pubnix.main
  "extension" -> Extension.main
  "obs" -> OBS.main
  "button" -> Button.main
  "register" -> Register.main
  "menu" -> Menu.main
  "auth" -> Auth.main
  "greencircle" -> Greencircle.main
  "throwshade" -> Throwshade.main
  _ -> throw $ "unknown mode: " <> Config.mode
