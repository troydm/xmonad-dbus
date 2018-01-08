module Main where

import XMonad.DBus
import Control.Concurrent
import Data.List (intercalate)
import System.IO (hFlush,stdout)
import System.Environment (getArgs)

printer m = do r <- takeMVar m
               mapM_ putStrLn r
               hFlush stdout
               printer m

main :: IO ()
main = do
        m <- newEmptyMVar
        c <- connect
        args <- getArgs
        if args /= [] && head args == "send" then
            do
                requestAccess c
                send c $ intercalate " " (tail args)
        else if args /= [] && head args == "sendToPath" then
            do
                requestAccess c
                sendToPath c (head $ tail args) $ intercalate " " (tail (tail args))
        else
            do
                case args of
                    (path:_) -> subscribeToPath c path
                    _ -> subscribe c
                    $ \s -> putMVar m (bodyToString s)
                printer m
