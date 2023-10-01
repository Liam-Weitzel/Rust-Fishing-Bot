
; User supplied function
Local $sUserFuncName = ""
If IsArray( $hUser_Function ) And ( UBound( $hUser_Function, 0 ) <> 1 Or UBound( $hUser_Function ) <> 2 ) Then  $hUser_Function = 0
If IsArray( $hUser_Function ) And IsFunc( $hUser_Function[0] ) Then
	$sUserFuncName = $hUser_Function[1]
	$hUser_Function = $hUser_Function[0]
EndIf

; Create GUI
Local $iOrgWidth = 210, $iHeight = 200, $iMinSize = 250
Local $hGUI = GUICreate($sTitle, $iOrgWidth, $iHeight, Default, Default, BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX))
Local $aiGUISize = WinGetClientSize($hGUI), $iButtonWidth = $aiGUISize[0] / ( IsFunc($hUser_Function) ? 4 : 3 )
; Create ListView
Local $idListView = GUICtrlCreateListView($sHeader, 0, 0, $aiGUISize[0], $aiGUISize[1] - 20, $LVS_SHOWSELALWAYS + $LVS_OWNERDATA)
If Not $bNoGridLines Then GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_FULLROWSELECT, $LVS_EX_FULLROWSELECT)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_DOUBLEBUFFER, $LVS_EX_DOUBLEBUFFER)
GUICtrlSendMsg($idListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $WS_EX_CLIENTEDGE, $WS_EX_CLIENTEDGE)
GUICtrlSendMsg($idListView, $LVM_SETTEXTBKCOLOR, 0, $iLvBackColor)
GUICtrlSendMsg($idListView, $LVM_SETBKCOLOR, 0, $iLvBackColor)
; Init control IDs
Local $idGoto = 99999, $idGotoSuccessor = 99999, $idTabKey = 99999, $idShiftTab = 99999, $idEnterKey = 99999, $fGotoFirst = True
Local $idLabel = 99999, $idFunc = 99999, $idExit = 99999
; Create "Goto row" control
$idTabKey = GUICtrlCreateDummy()
$idShiftTab = GUICtrlCreateDummy()
$idEnterKey = GUICtrlCreateDummy()
$idGoto = GUICtrlCreateInput( "Goto row (press Tab)", 0, $aiGUISize[1] - 20, $iButtonWidth, 20, 0x2000 )
Local $aAccelKeys[3][2] = [ [ "{ENTER}", $idEnterKey ], [ "{TAB}", $idTabKey ], [ "+{TAB}", $idShiftTab ] ], $bAccelKeys = False
; Create data label
$idLabel = GUICtrlCreateLabel($sLabelData, $iButtonWidth, $aiGUISize[1] - 20, $iButtonWidth, 18, BitOR($SS_CENTER, $SS_CENTERIMAGE))
; Create Func button
If IsFunc($hUser_Function) Then $idFunc = GUICtrlCreateButton( ( $sUserFuncName ? $sUserFuncName : "User Func" ), $iButtonWidth * 2, $aiGUISize[1] - 20, $iButtonWidth, 20)
; Create Exit button
$idExit = GUICtrlCreateButton("Exit Script", $iButtonWidth * ( IsFunc($hUser_Function) ? 3 : 2 ), $aiGUISize[1] - 20, $iButtonWidth, 20)
$idGotoSuccessor = IsFunc($hUser_Function) ? $idFunc : $idExit
; Set resizing
GUICtrlSetResizing($idListView, $GUI_DOCKBORDERS)
GUICtrlSetResizing($idGoto, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
If IsFunc($hUser_Function) Then
	GUICtrlSetResizing($idLabel, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
	GUICtrlSetResizing($idFunc, $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
Else
	GUICtrlSetResizing($idLabel, $GUI_DOCKHCENTER + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)
EndIf
GUICtrlSetResizing($idExit, $GUI_DOCKRIGHT + $GUI_DOCKBOTTOM + $GUI_DOCKHEIGHT)

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
; Register non-blocked message handler
Local $pMultMsgHandler = DllCallbackGetPtr( DllCallbackRegister( "DataDisplayMult_MsgHandler", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr" ) )
DllCall( "comctl32.dll", "bool", "SetWindowSubclass", "hwnd", $hGUI, "ptr", $pMultMsgHandler, "uint_ptr", $iIdx, "dword_ptr", 0 ) ; $iSubclassId = $iIdx, $pData = 0
; Store GUI info
$aDataDisplay_Info[$iIdx][20] = $iIdx
$aDataDisplay_Info[$iIdx][21] = $hGUI
$aDataDisplay_Info[$iIdx][22] = $idTabKey           ; Events from these controls must be detected by DataDisplayMult_MsgHandler()
$aDataDisplay_Info[$iIdx][23] = $idShiftTab
$aDataDisplay_Info[$iIdx][24] = $idEnterKey
$aDataDisplay_Info[$iIdx][25] = $idGoto
$aDataDisplay_Info[$iIdx][26] = $idFunc
$aDataDisplay_Info[$iIdx][27] = $idExit
$aDataDisplay_Info[$iIdx][28] = $idListView         ; These controls/variables are used in main message loop
$aDataDisplay_Info[$iIdx][29] = $aAccelKeys
$aDataDisplay_Info[$iIdx][30] = $bAccelKeys
$aDataDisplay_Info[$iIdx][31] = $idGotoSuccessor
$aDataDisplay_Info[$iIdx][32] = $fGotoFirst
$aDataDisplay_Info[$iIdx][33] = $hUser_Function
$aDataDisplay_Info[$iIdx][34] = $iRowCount
$aDataDisplay_Info[$iIdx][35] = -1 ; $iItemIdx
$aDataDisplay_Info[$iIdx][40] = $pMultMsgHandler    ; Pointer to DataDisplayMult_MsgHandler()

$aDataDisplay_Info[$iIdx][15] = $sDataDisplay_Func = "ArrayDisplayEx"   ?  3 _
                              : $sDataDisplay_Func = "CSVfileDisplay"   ?  6 _
                              : $sDataDisplay_Func = "SafeArrayDisplay" ?  9 _
                              : $sDataDisplay_Func = "SQLiteDisplay"    ? 12 : 0
