module Utils where

import Prelude

import Auth (AuthInfo, authHeader)
import Config as Config
import Data.Array (head)
import Data.Foldable (fold, for_)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (throw)
import Fetch (fetch)
import Web.DOM as DOM
import Web.DOM.DOMTokenList as DOM.DTL
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
import Web.HTML.HTMLSelectElement as HTML.Select
import Web.HTML.HTMLTextAreaElement as HTML.TextArea
import Web.HTML.HTMLIFrameElement as HTML.IFrame
import Web.HTML.Window as HTML.Win

maybeToArray :: forall a. Maybe a -> Array a
maybeToArray (Just x) = [x]
maybeToArray Nothing = []

maybeById :: forall m. MonadEffect m => String -> m (Maybe DOM.Element)
maybeById i = do
  w <- liftEffect HTML.window
  d <- liftEffect $ HTML.Doc.toDocument <$> HTML.Win.document w
  liftEffect (DOM.NEP.getElementById i (DOM.Doc.toNonElementParentNode d))

byId :: forall m. MonadEffect m => String -> m DOM.Element
byId i = do
  maybeById i >>= case _ of
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

getId :: forall m. MonadEffect m => DOM.Element -> m String
getId e = liftEffect $ DOM.El.id e

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

getTextArea :: forall m. MonadEffect m => DOM.Element -> m String
getTextArea e = case HTML.TextArea.fromElement e of
  Just inp -> liftEffect $ HTML.TextArea.value inp
  Nothing -> liftEffect $ throw "element is not a text area"

getValue :: forall m. MonadEffect m => DOM.Element -> m String
getValue e = case HTML.Input.fromElement e of
  Just inp -> liftEffect $ HTML.Input.value inp
  Nothing -> liftEffect $ throw "element is not an input"

getSelectValue :: forall m. MonadEffect m => DOM.Element -> m String
getSelectValue e = case HTML.Select.fromElement e of
  Just inp -> liftEffect $ HTML.Select.value inp
  Nothing -> liftEffect $ throw "element is not a select"

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

setIFrameSrc :: forall m. MonadEffect m => String -> DOM.Element -> m Unit
setIFrameSrc src e = case HTML.IFrame.fromElement e of
  Just iframe -> liftEffect $ HTML.IFrame.setSrc src iframe
  Nothing -> liftEffect $ throw "element is not an iframe"

checkAuth :: AuthInfo -> Aff String
checkAuth auth = do
  { text: resp } <-
    fetch (Config.apiServer <> "/check")
    { headers:
      { "Authorization": authHeader auth
      }
    }
  resp
