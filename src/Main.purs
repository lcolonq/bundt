module Main where

import Prelude

import Audio as Audio
import Auth (AuthInfo, authHeader, getToken, startTwitchAuth, getSessionCookie, clearSessionCookie)
import Config as Config
import Data.String as String
import Data.Array (head)
import Data.Array as Array
import Data.Foldable (fold)
import Data.Maybe (Maybe(..))
import Data.Traversable (for, for_)
import Data.Tuple (Tuple(..))
import Data.HTTP.Method (Method(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console (log)
import Effect.Exception (throw)
import Fetch (fetch)
import Model (startModel)
import UI as UI
import Web.DOM as DOM
import Web.DOM.DOMTokenList as DOM.DTL
import Web.DOM.Document (doctype)
import Web.DOM.Document as DOM.Doc
import Web.DOM.Element as DOM.El
import Web.DOM.Node as DOM.Node
import Web.DOM.NodeList as DOM.NL
import Web.DOM.NonElementParentNode as DOM.NEP
import Web.DOM.ParentNode as DOM.P
import Web.DOM.Text as DOM.Text
import Web.Event.Event as Ev
import Web.Event.EventTarget as Ev.Tar
import Web.HTML as HTML
import Web.HTML.HTMLDocument as HTML.Doc
import Web.HTML.HTMLInputElement as HTML.Input
import Web.HTML.Window as HTML.Win

maybeToArray :: forall a. Maybe a -> Array a
maybeToArray (Just x) = [x]
maybeToArray Nothing = []

byId :: forall m. MonadEffect m => String -> m DOM.Element
byId i = do
  w <- liftEffect HTML.window
  d <- liftEffect $ HTML.Doc.toDocument <$> HTML.Win.document w
  liftEffect (DOM.NEP.getElementById i (DOM.Doc.toNonElementParentNode d)) >>= case _ of
    Nothing -> liftEffect $ throw $ "could not find element with id: " <> i
    Just e -> pure e

queryAll :: forall m. MonadEffect m => String -> m (Array DOM.Element)
queryAll q = do
  w <- liftEffect HTML.window
  d <- liftEffect $ HTML.Doc.toDocument <$> HTML.Win.document w
  nl <- liftEffect (DOM.P.querySelectorAll (DOM.P.QuerySelector q) (DOM.Doc.toParentNode d))
  ns <- liftEffect $ DOM.NL.toArray nl
  pure $ fold $ (maybeToArray <<< DOM.El.fromNode) <$> ns

query :: forall m . MonadEffect m => String -> m DOM.Element
query q = do
  queryAll q >>= head >>> case _ of
    Nothing -> liftEffect $ throw $ "could not find element matching query: " <> q
    Just x -> pure x

listen :: forall m. MonadEffect m => DOM.Element -> String -> (Ev.Event -> Effect Unit) -> m Unit
listen e ev f = do
  l <- liftEffect $ Ev.Tar.eventListener f
  liftEffect $ Ev.Tar.addEventListener (Ev.EventType ev) l false $ DOM.El.toEventTarget e

create :: forall m. MonadEffect m => String -> Array String -> Array DOM.Element -> m DOM.Element
create tag classes children = do
  w <- liftEffect HTML.window
  d <- liftEffect $ HTML.Doc.toDocument <$> HTML.Win.document w
  el <- liftEffect $ DOM.Doc.createElement tag d
  cl <- liftEffect $ DOM.El.classList el
  for_ classes \c ->
    liftEffect $ DOM.DTL.add cl c
  for_ children \c ->
    appendElement el c
  pure el

appendElement :: forall m. MonadEffect m => DOM.Element -> DOM.Element -> m Unit
appendElement parent child = liftEffect $ DOM.Node.appendChild (DOM.El.toNode child) (DOM.El.toNode parent)

appendText :: forall m. MonadEffect m => DOM.Element -> String -> m Unit
appendText parent s = do
  w <- liftEffect HTML.window
  d <- liftEffect $ HTML.Doc.toDocument <$> HTML.Win.document w
  n <- liftEffect $ DOM.Doc.createTextNode s d
  liftEffect $ DOM.Node.appendChild (DOM.Text.toNode n) (DOM.El.toNode parent)

setText :: forall m. MonadEffect m => DOM.Element -> String -> m Unit
setText e s = liftEffect $ DOM.Node.setTextContent s $ DOM.El.toNode e

getValue :: forall m. MonadEffect m => DOM.Element -> m String
getValue e = case HTML.Input.fromElement e of
  Just inp -> liftEffect $ HTML.Input.value inp
  Nothing -> liftEffect $ throw "element is not an input"

addClass :: forall m. MonadEffect m => String -> DOM.Element -> m Unit
addClass c e = do
  cl <- liftEffect $ DOM.El.classList e
  _ <- liftEffect $ DOM.DTL.add cl c
  pure unit

removeClass :: forall m. MonadEffect m => String -> DOM.Element -> m Unit
removeClass c e = do
  cl <- liftEffect $ DOM.El.classList e
  _ <- liftEffect $ DOM.DTL.remove cl c
  pure unit

toggleClass :: forall m. MonadEffect m => String -> DOM.Element -> m Unit
toggleClass c e = do
  cl <- liftEffect $ DOM.El.classList e
  _ <- liftEffect $ DOM.DTL.toggle cl c
  pure unit

updateSubtitle :: Aff Unit
updateSubtitle = do
  subtitle <- byId "lcolonq-pubnix-index-subtitle"
  { text: catchphrase } <- fetch (Config.apiServer <> "/catchphrase") {}
  catchphrase >>= setText subtitle

checkAuth :: AuthInfo -> Aff String
checkAuth auth = do
  { text: resp } <-
    fetch (Config.apiServer <> "/check")
    { headers:
      { "Authorization": authHeader auth
      }
    }
  resp

mainApi :: Effect Unit
mainApi = launchAff_ do
  pure unit

mainPubnix :: Effect Unit
mainPubnix = launchAff_ do
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

mainExtension :: Effect Unit
mainExtension = launchAff_ do
  liftEffect $ log "hello from extension"
  UI.setInterval 1000.0 do
    e <- query ".chat-scrollable-area__message-container"
    new <- create "div" [".chat-line__message"] []
    appendText new "test"
    appendElement e new

mainObs :: Effect Unit
mainObs = launchAff_ do
  startModel

buttonPress :: String -> Aff Unit
buttonPress b = do
  void $ fetch (Config.apiServer <> "/sentiment/" <> b)
    { method: POST
    }
mainButton :: Effect Unit
mainButton = launchAff_ do
  liftEffect $ log "hello from button"
  green <- byId "lcolonq-button-link-green"
  listen green "click" \_ev -> do
    liftEffect $ log "+2"
    launchAff_ $ buttonPress "green"
  red <- byId "lcolonq-button-link-red"
  listen red "click" \_ev -> do
    liftEffect $ log "-2"
    launchAff_ $ buttonPress "red"

mainRegister :: Effect Unit
mainRegister = launchAff_ do
  liftEffect $ log "hello from registration page"
  link <- byId "lcolonq-register-link"
  getToken >>= case _ of
    Just a@(Tuple t n) -> do -- if there's an auth token in the fragment, ask the API to register us
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

mainMenu :: Effect Unit
mainMenu = launchAff_ do
  liftEffect $ log "hello from menu"

mainAuth :: Effect Unit
mainAuth = launchAff_ do
  liftEffect $ log "hello from auth"
  getSessionCookie >>= case _ of
    Nothing -> do
      container <- byId "lcolonq-auth-login"
      removeClass "lcolonq-invisible" container
      form <- byId "lcolonq-auth-form"
      listen form "submit" \ev -> launchAff_ do
        liftEffect $ Ev.preventDefault ev
        usernameInp <- byId "lcolonq-auth-username"
        passwordInp <- byId "lcolonq-auth-password"
        username <- getValue usernameInp
        password <- getValue passwordInp
        { text: resp } <- fetch ("/api/firstfactor")
          { method: POST
          , headers: { "Content-Type": "application/json" }
          , body: UI.toJSON { username, password }
          }
        res <- resp
        liftEffect $ log res
    Just _ -> do
      container <- byId "lcolonq-auth-logout"
      removeClass "lcolonq-invisible" container
      logout <- byId "lcolonq-auth-logout-link"
      listen logout "click" \_ev -> do
        clearSessionCookie
        UI.reload

main :: Effect Unit
main = case Config.mode of
  "api" -> mainApi
  "pubnix" -> mainPubnix
  "extension" -> mainExtension
  "obs" -> mainObs
  "button" -> mainButton
  "register" -> mainRegister
  "menu" -> mainMenu
  "auth" -> mainAuth
  _ -> throw $ "unknown mode: " <> Config.mode
