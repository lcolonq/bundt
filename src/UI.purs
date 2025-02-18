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
