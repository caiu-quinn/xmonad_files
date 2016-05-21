import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Hooks.DynamicLog
import System.IO
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Hooks.UrgencyHook

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ withUrgencyHook NoUrgencyHook $ (defaultConfig {
        manageHook = myManageHook <+> (isFullscreen --> doFullFloat),
        modMask = mod4Mask,
        layoutHook = lessBorders OnlyFloat $ avoidStruts $
                     layoutHook defaultConfig,
        logHook = dynamicLogWithPP $ xmobarPP
            { ppOutput = hPutStrLn xmproc,
              ppTitle = xmobarColor "green" "" . shorten 75,
              ppUrgent = xmobarColor "yellow" "red" . xmobarStrip
            },
        workspaces = myWorkspaces,
        terminal = "xterm"
    } `removeKeys` removedKeys) `additionalKeys` myKeys

myKeys =
    [((mod4Mask, xK_s), windows W.focusDown),
     ((mod4Mask .|. shiftMask, xK_s), windows W.swapDown),
     ((mod4Mask, xK_r), windows W.focusUp),
     ((mod4Mask .|. shiftMask, xK_r), windows W.swapUp),
     ((mod4Mask, xK_t), sendMessage Shrink),
     ((mod4Mask, xK_n), sendMessage Expand),
     ((mod4Mask, xK_egrave), withFocused $ windows . W.sink),
     ((mod4Mask, xK_apostrophe), refresh),
     ((mod4Mask .|. shiftMask, xK_l), spawn "setxkbmap fr"),
     ((mod4Mask .|. shiftMask, xK_o), spawn "setxkbmap fr bepo")] ++
    [((m .|. mod4Mask, k), windows $ f i)
      | (i, k) <- zip myWorkspaces numBepo
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

removedKeys =
    [(mod4Mask, xK_k), (mod4Mask .|. shiftMask, xK_j),
     (mod4Mask, xK_j), (mod4Mask .|. shiftMask, xK_k),
     (mod4Mask, xK_h),
     (mod4Mask, xK_l),
     (mod4Mask, xK_t),
     (mod4Mask, xK_n)]

myWorkspaces = ["1","2","3","4","5","IRC","web","mail","9","A","B","bg"]
numBepo = [0x22,0xab,0xbb,0x28,0x29,0x40,0x2b,0x2d,0x2f,0x2a,0x3d,0x25]

myManageHook = composeAll
    [ className =? "Gimp" --> doFloat,
      manageDocks]
