module Auth where

import Prelude

import Config (authRedirectURL, clientID)
import Data.Array (fold)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import _startTwitchAuth :: String -> String -> Effect Unit
startTwitchAuth :: forall m. MonadEffect m => m Unit
startTwitchAuth = liftEffect $ _startTwitchAuth clientID authRedirectURL

type AuthInfo = Tuple String String
foreign import _getToken :: forall a. (a -> Maybe a) -> Maybe a -> (a -> a -> Tuple a a) -> Effect (Maybe (Tuple String String))
getToken :: forall m. MonadEffect m => m (Maybe AuthInfo)
getToken = liftEffect $ _getToken Just Nothing Tuple

authHeader :: AuthInfo -> String
authHeader (Tuple t n) =
  fold
  [ "FIG-TWITCH token=\""
  , t
  , "\", nonce=\""
  , n
  , "\""
  ]

foreign import _getSessionCookie :: forall a. (a -> Maybe a) -> Maybe a -> Effect (Maybe String)
getSessionCookie :: forall m. MonadEffect m => m (Maybe String)
getSessionCookie = liftEffect $ _getSessionCookie Just Nothing

foreign import _clearSessionCookie :: Effect Unit
clearSessionCookie :: forall m. MonadEffect m => m Unit
clearSessionCookie = liftEffect _clearSessionCookie
