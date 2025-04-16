module UI where

import Prelude
import Config as Config
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Web.DOM.Element as DOM.El

foreign import _cheatLog :: forall a. a -> Effect Unit
cheatLog :: forall m a. MonadEffect m => a -> m Unit
cheatLog x = liftEffect $ _cheatLog x

foreign import _setInterval :: Number -> Effect Unit -> Effect Unit
setInterval :: forall m. MonadEffect m => Number -> Effect Unit -> m Unit
setInterval d f = liftEffect $ _setInterval d f

foreign import _toJSON :: forall a. a -> String
toJSON :: forall a. a -> String
toJSON = _toJSON

foreign import _reload :: Effect Unit
reload :: forall m. MonadEffect m => m Unit
reload = liftEffect _reload

foreign import _redirect :: String -> Effect Unit
redirect :: forall m. MonadEffect m => String -> m Unit
redirect url = liftEffect $ _redirect url

foreign import _submitRedeem :: String -> DOM.El.Element -> Effect Unit
submitRedeem :: forall m. MonadEffect m => DOM.El.Element -> m Unit
submitRedeem el = liftEffect $ _submitRedeem (Config.secureApiServer <> "/redeem") el

foreign import _setShader :: String -> Effect Unit
setShader :: forall m. MonadEffect m => String -> m Unit
setShader s = liftEffect $ _setShader s

foreign import _submitShader :: String -> String -> Effect Unit
submitShader :: forall m. MonadEffect m => String -> m Unit
submitShader el = liftEffect $ _submitShader (Config.secureApiServer <> "/redeem") el

foreign import _addOption :: String -> DOM.El.Element -> Effect Unit
addOption :: forall m. MonadEffect m => String -> DOM.El.Element -> m Unit
addOption o el = liftEffect $ _addOption o el

foreign import _onInput :: DOM.El.Element -> (String -> Effect Unit) -> Effect Unit
onInput :: forall m. MonadEffect m => DOM.El.Element -> (String -> Effect Unit) -> m Unit
onInput el f = liftEffect $ _onInput el f

foreign import _startBufferRefresh :: String -> DOM.El.Element -> Effect Unit
startBufferRefresh :: forall m. MonadEffect m => DOM.El.Element -> m Unit
startBufferRefresh el = liftEffect $ _startBufferRefresh (Config.apiServer <> "/gizmo/events") el 
