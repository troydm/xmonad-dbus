{-# LANGUAGE OverloadedStrings #-}
module XMonad.DBus (connect,subscribe,subscribeToPath,bodyToString,requestAccess,send,sendToPath) where

import Data.Maybe (mapMaybe)
import qualified DBus as D
import qualified DBus.Client as DC

busName = "org.XMonad.DBus"
interface = "org.XMonad.DBus"
pathPrefix = "/org/XMonad"
pathPrefixObjectPath = D.objectPath_ pathPrefix
member = "Update"

connect :: IO DC.Client
connect = DC.connectSession

requestAccess c = DC.requestName c busName [DC.nameAllowReplacement, DC.nameReplaceExisting, DC.nameDoNotQueue]


matchAnyPath :: DC.MatchRule
matchAnyPath = DC.matchAny {
            DC.matchInterface = Just interface,
            DC.matchPathNamespace = Just pathPrefixObjectPath,
            DC.matchMember = Just member
        }

matchPath :: String -> DC.MatchRule
matchPath name = DC.matchAny {
            DC.matchInterface = Just interface,
            DC.matchPath = (D.parseObjectPath $ pathPrefix++"/"++name),
            DC.matchMember = Just member
        }

subscribe c handler = DC.addMatch c matchAnyPath handler
subscribeToPath c path handler = DC.addMatch c (matchPath path) handler

bodyToString :: D.Signal -> [String]
bodyToString s = mapMaybe D.fromVariant (D.signalBody s)


send :: DC.Client -> String -> IO ()
send c s = DC.emit c $ (D.signal pathPrefixObjectPath interface member) {
    D.signalBody = [D.toVariant s]
    }

sendToPath :: DC.Client -> String -> String -> IO ()
sendToPath c p s = DC.emit c $ (D.signal (D.objectPath_ $ pathPrefix++"/"++p) interface member) {
    D.signalBody = [D.toVariant s]
    }
