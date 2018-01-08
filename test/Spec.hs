import XMonad.DBus
import Control.Concurrent
import Control.Applicative ((<|>))
import System.Exit

main :: IO ()
main = do
        m <- newEmptyMVar
        c1 <- connect
        c2 <- connect
        subscribe c2 (\s -> putMVar m (head $ bodyToString s))
        requestAccess c1
        send c1 "Test String!"
        threadDelay 1000000
        r <- tryTakeMVar m <|> return (Just "")
        case r of
            Just "Test String!" -> putStrLn "Test passed"
            _ -> do
                    putStrLn "Test didn't passed"
                    exitWith $ ExitFailure 1
