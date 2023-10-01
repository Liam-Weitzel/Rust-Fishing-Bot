
; User supplied function
Local $sUserFuncName = ""
If Not $bNoControls Then ; Ie. there are controls at bottom of child window
	If IsArray( $hUser_Function ) And ( UBound( $hUser_Function, 0 ) <> 1 Or UBound( $hUser_Function ) <> 2 ) Then  $hUser_Function = 0
	If IsArray( $hUser_Function ) And IsFunc( $hUser_Function[0] ) Then
		$sUserFuncName = $hUser_Function[1]
		$hUser_Function = $hUser_Function[0]
	EndIf
EndIf

; Create GUI
Local $iMinSize = 250
If $w < $iMinSize Then $w = $iMinSize
If $h < $iMinSize Then $h = $iMinSize
Local $iOrgWidth = $w, $iHeight = $h, $iButtonWidth = $iOrgWidth / ( IsFunc($hUser_Function) ? 3 : 2 )
Local $hGUI = GUICreate( "", $iOrgWidth, $iHeight, $x, $y, $WS_POPUP, $WS_EX_MDICHILD, $hUserGui )
If Not $bNoControls Then ; Ie. there are controls at bottom of child window
	GUICtrlCreateLabel( "", 0, 0, $iOrgWidth, $iHeight, $WS_BORDER )
	GUICtrlSetState( -1, $GUI_DISABLE )
	$iHeight -= 20
EndIf
; Create ListView
Local $idListView = GUICtrlCreateListView($sHeader, 0, 0, $iOrgWidth, $iHeight, $LVS_SHOWSELALWAYS + $LVS_OWNERDATA)
If Not $bNoGridLines Then GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_FULLROWSELECT, $LVS_EX_FULLROWSELECT)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_DOUBLEBUFFER, $LVS_EX_DOUBLEBUFFER)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $WS_EX_CLIENTEDGE, $WS_EX_CLIENTEDGE)
GUICtrlSendMsg($idListView, $LVM_SETTEXTBKCOLOR, 0, $iLvBackColor)
GUICtrlSendMsg($idListView, $LVM_SETBKCOLOR, 0, $iLvBackColor)
; Create "Goto row" control
Local $idGoto = $bNoControls ? GUICtrlCreateDummy() : GUICtrlCreateInput( "Goto row (press Tab)", 1, $iHeight, $iButtonWidth-1, 20-1, 0x2000 )
Local $idTabKey = GUICtrlCreateDummy(), $idShiftTab = GUICtrlCreateDummy(), $idEnterKey = GUICtrlCreateDummy(), $fGotoFirst = True
Local $aAccelKeys[3][2] = [ [ "{ENTER}", $idEnterKey ], [ "{TAB}", $idTabKey ], [ "+{TAB}", $idShiftTab ] ], $bAccelKeys = False
GUISetAccelerators( $aAccelKeys )
; Create data label
Local $idLabel = $bNoControls ? GUICtrlCreateDummy() : GUICtrlCreateLabel($sLabelData, $iButtonWidth, $iHeight, $iButtonWidth-1, 18, BitOR($SS_CENTER, $SS_CENTERIMAGE))
; Create Func button
Local $idFunc = $bNoControls ? GUICtrlCreateDummy() : IsFunc($hUser_Function) _
                ? GUICtrlCreateButton( ( $sUserFuncName ? $sUserFuncName : "User Func" ), $iButtonWidth * 2, $iHeight, $iButtonWidth-1, 20-1 ) _
                : GUICtrlCreateDummy()

; ControlIds must be an uninterrupted continuous sequence of integers
; This is a prerequisite for the message handling in the user code to work
$iRet = 5
If $idFunc - $idListView <> 6 Then
	GUIDelete( $hGUI )
	$sMsg = "ControlId error:" & @CRLF & "ControlIds isn't a continuous sequence of integers."
	If $bVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
			$sMbTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
		Exit
	Else
		Return SetError($iRet, 0, "")
	EndIf
EndIf

; Set resizing
GUICtrlSetResizing($idListView, $GUI_DOCKBORDERS)
If Not $bNoControls Then ; Ie. there are controls at bottom of child window
	GUICtrlSetResizing($idGoto, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	If IsFunc($hUser_Function) Then
		GUICtrlSetResizing($idLabel, $GUI_DOCKHCENTER + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
		GUICtrlSetResizing($idFunc, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	Else
		GUICtrlSetResizing($idLabel, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	EndIf
EndIf

; Register data display GUI
If $aDataDisplay_Info0[20] = $aDataDisplay_Info0[21] Then
	$sMsg = "Too many data display GUIs"
	If $bVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
			$sMbTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
		Exit
	Else
		Return SetError(6, 0, "")
	EndIf
EndIf
; Increase number of GUIs
$aDataDisplay_Info0[20] += 1
; Find first available index
For $iIdx = 1 To $aDataDisplay_Info0[21]
	If Not $aDataDisplay_Info[$iIdx][20] Then ExitLoop
Next
; Store GUI info
$aDataDisplay_Info[$iIdx][20] = $iIdx
$aDataDisplay_Info[$iIdx][21] = $hGUI

$aDataDisplay_Info[$iIdx][15] = $sDataDisplay_Func = "ArrayDisplayEx"   ?  2 _
                              : $sDataDisplay_Func = "CSVfileDisplay"   ?  5 _
                              : $sDataDisplay_Func = "SafeArrayDisplay" ?  8 _
                              : $sDataDisplay_Func = "SQLiteDisplay"    ? 11 : 0
