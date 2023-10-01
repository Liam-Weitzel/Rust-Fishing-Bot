#include-once

; Project includes
#include "..\..\..\Common\9)MessageLoopCtrl.au3" ; Loop and message handler

; Cleanup and release memory
Func ArrayDisplay_Cleanup( $iIdx )
	; Remove $WM_COMMAND and $WM_SYSCOMMAND event handler
	If $aDataDisplay_Info[$iIdx][15] = 3 Then _ ; Remove WM_COMMAND, WM_SYSCOMMAND message handler (DataDisplayMult_MsgHandler) used to handle events from multiple concurrent and responsive GUIs
		DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$iIdx][21], "ptr", $aDataDisplay_Info[$iIdx][40], "uint_ptr", $iIdx ) ; WM_COMMAND, WM_SYSCOMMAND

	; Remove $WM_COMMAND event handler
	If $aDataDisplay_Info[$iIdx][15] = 2 Then _ ; Remove WM_COMMAND message handler (DataDisplayCtrl_WM_COMMAND) used to handle events from embedded GUI controls
		DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$iIdx][21], "ptr", $aDataDisplay_Info[$iIdx][18], "uint_ptr", $iIdx ) ; WM_COMMAND

	; Remove WM_NOTIFY message handler used to fill the virtual listview
	DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$iIdx][21], "ptr", $aDataDisplay_Info[$iIdx][2], "uint_ptr", $iIdx ) ; WM_NOTIFY

	; Delete ListView header background color resources
	If IsArray( $aDataDisplay_Info[$iIdx][16] ) Then
		Local $aTmp = $aDataDisplay_Info[$iIdx][16] ; [ $hListView, $pHeaderColor, $oHdr_Colors_Dict ]
		; Remove WM_NOTIFY message handler (DataDisplay_HeaderColor) used to draw colors in listview header items
		DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aTmp[0], "ptr", $aTmp[1], "uint_ptr", 9999 )
		For $hBrush In $aTmp[2].Items()
			DllCall( "gdi32.dll", "bool", "DeleteObject", "handle", $hBrush ) ; _WinAPI_DeleteObject
		Next
		$aDataDisplay_Info[$iIdx][16] = 0
	EndIf

	; Delete AutoIt GUI
	If $aDataDisplay_Info[$iIdx][15] <> 2 Then _
		GUIDelete( $aDataDisplay_Info[$iIdx][21] )

	; Release memory
	$aDataDisplay_Info[$iIdx][0] = 0
	$aDataDisplay_Info[$iIdx][3] = 0
	$aDataDisplay_Info[$iIdx][4] = 0
	$aDataDisplay_Info[$iIdx][5] = 0
	$aDataDisplay_Info[$iIdx][6] = 0

	; Release local static memory
	$aDataDisplay_Info[$iIdx][1]( 0, 0x004E, 0, 0, $iIdx, 0 ) ; 0x004E = $WM_NOTIFY
	If $aDataDisplay_Info[$iIdx][15] = 2 Then
		DataDisplayCtrl_MsgHandler( 99999, $iIdx )
		$aDataDisplay_Info[$iIdx][10] = 0
	EndIf

	; Release row in $aDataDisplay_Info
	$aDataDisplay_Info[$iIdx][20] = 0 ; $iIdx
EndFunc
