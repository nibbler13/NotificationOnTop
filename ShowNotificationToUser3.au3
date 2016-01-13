#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <GuiConstantsEx.au3>
#include <StaticConstants.au3>
#include <File.au3>
Global Const $AC_SRC_ALPHA = 1

Opt("TrayIconHide", 1)

Local $fileContent
Local $fileHandler
Local $filePath
Local $isThisUserInOMS = 0
Local $currentWindow

$currentWindow = WinGetHandle("")
$filePath = @ScriptDir & "\oms_doctors.txt"

If FileExists($filePath) Then
   $fileHandler = FileOpen($filePath)
   $fileContent = FileReadToArray($fileHandler)
   FileClose($fileHandler)

   If $fileContent = 0 Then
	  MsgBox(0,"ERROR!","The file has nothing inside")
	  Exit
   EndIf

   For $userNameInList In $fileContent
	  If $userNameInList = @UserName Then $isThisUserInOMS = 1
   Next

Else
   MsgBox(0,"ERROR!","There is no file: " & $filePath)
EndIf

_GDIPlus_Startup()

Local $maxShowindImage = 4
If $isThisUserInOMS = 1 Then $maxShowindImage = 7

Local $whatTimeIsIt = Random(0, $maxShowindImage, 1)
Local $pngSrc
Local $imageWidth = 526 ;841
Local $imageHeigh = 144 ;230

If $whatTimeIsIt > 4 Then
   $imageWidth = 841
   $imageHeigh = 230
EndIf

Local $whereToMoveX = Random(10, @DesktopWidth - $imageWidth - 10, 1)
Local $whereToMoveY = @DesktopHeight - $imageHeigh - 40

$pngSrc = @ScriptDir & "\Background" & $whatTimeIsIt & ".png"

;This allows the png to be dragged by clicking anywhere on the main image.
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
$GUI = _GUICreate_Alpha("Notification", $pngSrc)
$myGuiHandle = WinGetHandle("Notification")
GUISetState()

;This is an invisible control container. You can create regular windows controls on this panel.
$controlGui = GUICreate("ControlGUI", 600, 600, 0, 0, BitOR($WS_POPUP, $WS_DISABLED), BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD, $WS_EX_TOPMOST), $myGuiHandle)
GUICtrlSetBkColor($controlGui, 0xFF00FF)
GUICtrlSetState(-1, $GUI_DISABLE)

WinActivate($currentWindow)
WinMove($myGuiHandle,Default,$whereToMoveX,$whereToMoveY,Default,Default,1000)

Sleep(15000)

WinMove($myGuiHandle,Default,@DesktopWidth + $imageWidth,$whereToMoveY,Default,Default,1000)

_GDIPlus_Shutdown()

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
    If ($hwnd = WinGetHandle("Notification")) And ($iMsg = $WM_NCHITTEST) Then
    Return $HTCAPTION
    EndIf
EndFunc

Func _GUICreate_Alpha($sTitle, $sPath, $iX=-$imageWidth, $iY=$whereToMoveY, $iOpacity=255)
    Local $hGUI, $hImage, $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
    $hImage = _GDIPlus_ImageLoadFromFile($sPath)
    $width = _GDIPlus_ImageGetWidth($hImage)
    $height = _GDIPlus_ImageGetHeight($hImage)
    $hGUI = GUICreate($sTitle, $width, $height, $iX, $iY, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOPMOST))
    $hScrDC = _WinAPI_GetDC(0)
    $hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
    $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
    $hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
    $tSize = DllStructCreate($tagSIZE)
    $pSize = DllStructGetPtr($tSize)
    DllStructSetData($tSize, "X", $width)
    DllStructSetData($tSize, "Y", $height)
    $tSource = DllStructCreate($tagPOINT)
    $pSource = DllStructGetPtr($tSource)
    $tBlend = DllStructCreate($tagBLENDFUNCTION)
    $pBlend = DllStructGetPtr($tBlend)
    DllStructSetData($tBlend, "Alpha", $iOpacity)
    DllStructSetData($tBlend, "Format", 1)
    _WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, 2)
    _WinAPI_ReleaseDC(0, $hScrDC)
    _WinAPI_SelectObject($hMemDC, $hOld)
    _WinAPI_DeleteObject($hBitmap)
    _WinAPI_DeleteObject($hImage)
    _WinAPI_DeleteDC($hMemDC)
EndFunc ;==>_GUICreate_Alpha

Func SetBitmap($hGUI, $hImage, $iOpacity)
    Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
    $hScrDC = _WinAPI_GetDC(0)
    $hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
    $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
    $hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
    $tSize = DllStructCreate($tagSIZE)
    $pSize = DllStructGetPtr($tSize)
    DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
    DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
    $tSource = DllStructCreate($tagPOINT)
    $pSource = DllStructGetPtr($tSource)
    $tBlend = DllStructCreate($tagBLENDFUNCTION)
    $pBlend = DllStructGetPtr($tBlend)
    DllStructSetData($tBlend, "Alpha", $iOpacity)
    DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
    _WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
    _WinAPI_ReleaseDC(0, $hScrDC)
    _WinAPI_SelectObject($hMemDC, $hOld)
    _WinAPI_DeleteObject($hBitmap)
    _WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap


Func _ImageDrawText($hImage, $sText, $iX = 0, $iY = 0, $iRGB = 0x000000, $iSize = 9, $iStyle = 0, $sFont = "Arial")
    Local $w, $h, $hGraphic1, $hBitmap, $hGraphic2, $hBrush, $hFormat, $hFamily, $hFont, $tLayout, $aInfo
    $w = _GDIPlus_ImageGetWidth($hImage)
    $h = _GDIPlus_ImageGetHeight($hImage)

    ;Create a new bitmap, this way the original opened png is left unchanged
    $hGraphic1 = _GDIPlus_GraphicsCreateFromHWND(_WinAPI_GetDesktopWindow())
    $hBitmap = _GDIPlus_BitmapCreateFromGraphics($w, $h, $hGraphic1)
    $hGraphic2 = _GDIPlus_ImageGetGraphicsContext($hBitmap)

    ; Draw the original opened png into my newly created bitmap
    _GDIPlus_GraphicsDrawImageRect($hGraphic2, $hImage, 0, 0, $w, $h)

    ;Create the font
    $hBrush = _GDIPlus_BrushCreateSolid ("0xFF" & Hex($iRGB, 6))
    $hFormat = _GDIPlus_StringFormatCreate()
    $hFamily = _GDIPlus_FontFamilyCreate ($sFont)
    $hFont = _GDIPlus_FontCreate ($hFamily, $iSize, $iStyle)
    $tLayout = _GDIPlus_RectFCreate ($iX, $iY, 0, 0)
    $aInfo = _GDIPlus_GraphicsMeasureString ($hGraphic2, $sText, $hFont, $tLayout, $hFormat)

    ;Draw the font onto the new bitmap
    _GDIPlus_GraphicsDrawStringEx ($hGraphic2, $sText, $hFont, $aInfo[0], $hFormat, $hBrush)

    ;Cleanup the no longer needed resources
    _GDIPlus_FontDispose ($hFont)
    _GDIPlus_FontFamilyDispose ($hFamily)
    _GDIPlus_StringFormatDispose ($hFormat)
    _GDIPlus_BrushDispose ($hBrush)
    _GDIPlus_GraphicsDispose ($hGraphic2)
    _GDIPlus_GraphicsDispose ($hGraphic1)

    ;Return the new bitmap
    Return $hBitmap
EndFunc