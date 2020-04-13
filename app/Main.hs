module Main where

import XMonad.DBus
import Control.Concurrent
import Data.List (intercalate)
import System.IO (hFlush,stdout)
import System.Environment (getArgs)

import qualified DBus.Client as DC

printer m = do r <- takeMVar m
               mapM_ putStrLn r
               hFlush stdout
               printer m

work :: DC.Client -> [String] -> IO ()

work c ("send":xs) = do
        requestAccess c
        send c $ intercalate " " xs

work c ("sendToPath":x:xs) = do
        requestAccess c
        sendToPath c x $ intercalate " " xs

work c args = do
        m <- newEmptyMVar
        case args of
            (path:_) -> subscribeToPath c path
            _ -> subscribe c
            $ \s -> putMVar m (bodyToString s)
        printer m

main :: IO ()
main = do
        c <- connect
        args <- getArgs
        work c args
