#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <StaticConstants.au3>

Local $currentWindow = WinGetHandle("")
Local $hGUI = GUICreate("Внимание!", 500, 170, Default, @DesktopHeight-240, BitOR($WS_BORDER, $WS_POPUP), $WS_EX_TOPMOST)
Local $id2OK = GUICtrlCreateButton("OK", 250-45, 120, 90, 30)
Local $label = GUICtrlCreateLabel("Необходимо закрыть кассовый день", 20, 20, 460, 100, $SS_CENTER)
GUICtrlSetFont($label,27, $FW_LIGHT)
GUICtrlSetColor($label, $COLOR_BLUE)

GUISetState(@SW_SHOW, $hGUI)
WinActivate($currentWindow)

While 1
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE, $id2OK
		 ExitLoop
   EndSwitch
WEnd

GUIDelete($hGUI)