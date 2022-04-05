# xmonad-dbus
xmonad-dbus is DBus monitoring solution inspired by [xmonad-log](https://github.com/xintron/xmonad-log) completely written in Haskell.
It allows you to easily send your status via DBus using XMonad's DynamicLog to any application that can execute custom scripts.
It can be used to easily display XMonad status in [polybar](https://github.com/jaagr/polybar)

## Installation

### With Stack

```bash
    stack build
```

### With AUR

Use your favourite [AUR helper](https://wiki.archlinux.org/title/AUR_helpers) to install on ArchLinux-based distribution:

```bash
    pikaur -S xmonad-dbus-git
```

## Running

```bash
    # start xmonad-dbus, you can optionally specify a path that would be used when receiveing messages, 
    # otherwise all xmonad-dbus related messages will be received)
    stack exec xmonad-dbus -- [path]
    # you can manually send messages from command line too
    stack exec xmonad-dbus -- send string
    # and if you want to send messages only to particular path you can use sendToPath 
    stack exec xmonad-dbus -- sendToPath path string
```

## Configuring XMonad
To send status information from XMonad you need to add xmonad-dbus as dependency either via stack or manually when building your xmonad.hs

```haskell
    import XMonad
    import XMonad.Hooks.DynamicLog
    import qualified XMonad.DBus as D
    import qualified DBus.Client as DC

    -- Override the PP values as you would like (see XMonad.Hooks.DynamicLog documentation)
    myLogHook :: DC.Client -> PP
    myLogHook dbus = def { ppOutput = D.send dbus }

    main :: IO ()
    main = do
        -- Connect to DBus
        dbus <- D.connect
        -- Request access (needed when sending messages)
        D.requestAccess dbus
        -- start xmonad
        xmonad $ def { logHook = dynamicLogWithPP (myLogHook dbus) }
```

## Configuring polybar
To receive status you need to add custom/script module to your polybar config
Don't forget to add compiled xmonad-dbus executable to your PATH

    [module/xmonad]
    type = custom/script
    exec = xmonad-dbus
    tail = true
    interval = 1

