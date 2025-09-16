module Main where

import Prelude

import Config as Config
import Effect (Effect)
import Effect.Exception (throw)
import Main.API as API
import Main.Auth as Auth
import Main.Button as Button
import Main.Extension as Extension
import Main.Gizmo as Gizmo
import Main.Greencircle as Greencircle
import Main.Menu as Menu
import Main.OBS as OBS
import Main.Pubnix as Pubnix
import Main.Register as Register
import Main.Soundboard as Soundboard
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
  "soundboard" -> Soundboard.main
  "auth" -> Auth.main
  "greencircle" -> Greencircle.main
  "throwshade" -> Throwshade.main
  "gizmo" -> Gizmo.main
  _ -> throw $ "unknown mode: " <> Config.mode
