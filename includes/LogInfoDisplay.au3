#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#AutoIt3Wrapper_UseX64=Y

Opt( "MustDeclareVars", 1 )

#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiListView.au3>

Global $idListView, $aArray

Example()

Func Example()
	Local $iRows = 1000, $iCols = 1, $iLvColWidth = 1350          ; Rows, columns, column width
	;Local $iGuiWidth = $iCols*$iLvColWidth+21, $iGuiHeight = 788 ; 788 => 40 rows, 598 => 30 rows, +$WS_EX_CLIENTEDGE
	Local $iGuiWidth = $iCols*$iLvColWidth+17, $iGuiHeight = 784  ; 784 => 40 rows, 594 => 30 rows, -$WS_EX_CLIENTEDGE
	Dim $aArray[$iRows][$iCols]                                   ; Data array

	; Create Runtime LogInfo GUI
	Local $hLogInfo = GUICreate( "LogInfoDisplay", $iGuiWidth, $iGuiHeight )
	GUIRegisterMsg( $WM_NOTIFY, "WM_NOTIFY" ) ; Fill data in ListView

	; Subclass Runtime LogInfo GUI for communication with application
	Local $pLogInfoMessageHandler = DllCallbackGetPtr( DllCallbackRegister( "LogInfoMessageHandler", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr" ) )
	DllCall( "comctl32.dll", "bool", "SetWindowSubclass", "hwnd", $hLogInfo, "ptr", $pLogInfoMessageHandler, "uint_ptr", 0, "dword_ptr", NULL ) ; $iSubclassId = 0, $pData = NULL

	; Create LogInfo ListView                                               Default style            Virtual         -$WS_EX_CLIENTEDGE
	$idListView = GUICtrlCreateListView( "", 0, 0, $iGuiWidth, $iGuiHeight, $GUI_SS_DEFAULT_LISTVIEW+$LVS_OWNERDATA, 0 )
	_GUICtrlListView_SetExtendedListViewStyle( $idListView, $LVS_EX_DOUBLEBUFFER+$LVS_EX_GRIDLINES )
	Local $hListView = GUICtrlGetHandle( $idListView )    ; Reduce flicker       Grid lines
	; Disable focused and selected items                  4 - Disable focused item
	_GUICtrlListView_SetCallBackMask( $idListView, 12 ) ; 8 - Disable selected items
	; Get font of ListView control
	; Copied from _GUICtrlGetFont example by KaFu
	; See https://www.autoitscript.com/forum/index.php?showtopic=124526
	Local $hDC = _WinAPI_GetDC( $hListView ), $hFont = _SendMessage( $hListView, $WM_GETFONT )
	Local $hObject = _WinAPI_SelectObject( $hDC, $hFont ), $tLvLogFont = DllStructCreate( $tagLOGFONT )
	_WinAPI_GetObject( $hFont, DllStructGetSize( $tLvLogFont ), DllStructGetPtr( $tLvLogFont ) )
	Local $hLvFont = _WinAPI_CreateFontIndirect( $tLvLogFont ) ; Original ListView font
	_WinAPI_SelectObject( $hDC, $hObject )
	_WinAPI_ReleaseDC( $hListView, $hDC )
	_WinAPI_DeleteObject( $hFont )
	; Set ListView font to Courier New
	DllStructSetData( $tLvLogFont, "FaceName", "Courier New" )
	$hFont = _WinAPI_CreateFontIndirect( $tLvLogFont )
	_WinAPI_SetFont( $hListView, $hFont )
	; Restore font of Header control
	_WinAPI_SetFont( _GUICtrlListView_GetHeader( $hListView ), $hLvFont )
	; Add column
	_GUICtrlListView_AddColumn( $idListView, $CmdLine[1] & ": Runtimes and Speed Comparisons", $iLvColWidth )
	; Set number of rows
	GUICtrlSendMsg( $idListView, $LVM_SETITEMCOUNT, 0, 0 )

	; Show Runtime LogInfo GUI
	GUISetState( @SW_SHOW )

	; Main loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	; Cleanup
	; Remove the subclass that was used for communication with application
	DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $hLogInfo, "ptr", $pLogInfoMessageHandler, "uint_ptr", 0 ) ; $iSubclassId = 0
	_WinAPI_DeleteObject( $hLvFont )
	_WinAPI_DeleteObject( $hFont )
	GUIDelete( $hLogInfo )
EndFunc

Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
	Local Static $tText = DllStructCreate( "wchar[1000]" ), $pText = DllStructGetPtr( $tText )

	Switch DllStructGetData( DllStructCreate( $tagNMHDR, $lParam ), "Code" )
		Case $LVN_GETDISPINFOW
			Local $tDispInfo = DllStructCreate( $tagNMLVDISPINFO, $lParam )
			If Not BitAND( DllStructGetData( $tDispInfo, "Mask" ), $LVIF_TEXT ) Then Return
			DllStructSetData( $tText, 1, $aArray[DllStructGetData( $tDispInfo,"Item" )][DllStructGetData( $tDispInfo,"SubItem" )] )
			DllStructSetData( $tDispInfo, "Text", $pText )
			Return
	EndSwitch

	Return
	#forceref $hWnd, $iMsg, $wParam
EndFunc

Func LogInfoMessageHandler( $hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $pData ) ; $iSubclassId = 0, $pData = NULL
	Local Static $iCount = 0
	Switch $iMsg
		Case 0x004A ; $WM_COPYDATA
			Local $tCopyData = DllStructCreate( "ulong_ptr dwData;dword cbData;ptr lpData", $lParam )
			Local $aSplit = StringSplit( DllStructGetData( DllStructCreate( "wchar[" & DllStructGetData( $tCopyData, 2 ) & "]", DllStructGetData( $tCopyData, 3 ) ), 1 ), "|", 2 ), $iRow = Int( $aSplit[0] ) ; 2 = $STR_NOCOUNT
			$aArray[$iRow][0] = $aSplit[1]
			If $iCount < $iRow + 1 Then
				$iCount = $iRow + 1
				GUICtrlSendMsg( $idListView, $LVM_SETITEMCOUNT, $iCount, 0 )
			Else
				GUICtrlSendMsg( $idListView, $LVM_REDRAWITEMS, $iRow, $iRow )
			EndIf
			GUICtrlSendMsg( $idListView, $LVM_ENSUREVISIBLE, $iRow, 0 )
			Return 1
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $iSubclassId, $pData
EndFunc
