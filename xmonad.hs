import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import System.IO
import XMonad.Util.NamedScratchpad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import XMonad.Actions.WindowGo(runOrRaise)
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP)
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName(setWMName)
import XMonad.Layout.Maximize(maximize, maximizeRestore)
import XMonad.Layout.ThreeColumns
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Prompt
import XMonad.Prompt.Ssh




-- MyManage hooks defines floating windows 
-- and which application is started on which workspace
--
myManageHook = composeAll . concat $
	[ [ className   =? c --> doFloat | c <- myFloats]
	, [ className   =? c --> doShift "1:web" | c <- ws1]
	, [ className   =? c --> doShift "2:im" | c <- ws2]
	, [ className   =? c --> doShift "5" | c <- ws5]
	]
	where
	myFloats  = 	[ "Dialog", "Gcalctool", "VirtualBox", "Vncviewer"
			, "Gnome-display-properties", "Eclipse"
			, "javax.swing.JDialog", "Downloads"
			]
	ws1       = ["Firefox"]
	ws2       = ["Pidgin"]
	ws5       = ["Tivoli Directory Integrator"]


-- defines possible layouts to be switched from
--
myLayout = maximize tiled
	||| maximize (Mirror tiled)
	||| maximize Full
	||| maximize columns3
	where
		tiled    = Tall nmaster delta ratio
		nmaster  = 1
		ratio    = 1/2
		delta    = 3/100
		columns3 = ThreeColMid 1 (3/100) (2/3)


-- Scratchpads
scratchpads =
	, NS "Zim" "zim" (className =? "Zim" ) defaultFloating
	, NS "stalonetray" "stalonetray" (className =? "stalonetray" ) defaultFloating
	, NS "stardict" "stardict" (className =? "Stardict")
		(customFloating $ W.RationalRect (2/5) (2/5) (1/2) (1/2))
	] where role = stringProperty "WM_WINDOW_ROLE"
		
main = do
	xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobarrc"
	xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
		{ manageHook 	= namedScratchpadManageHook scratchpads <+> manageDocks <+> myManageHook <+> manageHook defaultConfig 
		, startupHook	= setWMName "LG3D"
		, layoutHook 	= avoidStruts  $ smartBorders (myLayout) -- smartBorders assure no borders in fullscreen (Mplayer - neede fstype=none in ~/.mplayer/config 
		, borderWidth	= 2 
		, workspaces	= [ "1:web", "2:im", "3:terms" ] ++ map show [4..8] ++ [ "9:media" ]
		, terminal	= "gnome-terminal"
		, modMask	= mod4Mask
		, logHook	= dynamicLogWithPP $ xmobarPP
			{ ppOutput = hPutStrLn xmproc
			, ppTitle = xmobarColor "red" "" . shorten 50
			, ppHiddenNoWindows	= id
			}
		} `additionalKeysP`
		[ ("M-C-f", spawn "firefox -P default")
		, ("M-C-s", namedScratchpadAction scratchpads "stardict")
		, ("M-C-b", namedScratchpadAction scratchpads "Banshee")
		, ("M-C-z", namedScratchpadAction scratchpads "Zim")
		, ("M-C-S-c", spawn "setxkbmap cz")
		, ("M-C-S-e", spawn "setxkbmap us")
		, ("M-S-s", sshPrompt defaultXPConfig)

 		]		





