#include-once

Func DataDisplayCtrl_MsgHandler( $iMsg, $iIdx )
	Local Static $iIndex = -1
	Local Static $hGUI, $idListView, $idGoto, $idTabKey, $idShiftTab, $idEnterKey, $fGotoFirst, _
	             $aAccelKeys, $bAccelKeys, $iRowCount, $idFunc, $hUser_Function, $iItemIdx, _
	             $aFeaturesInfo, $aSort_ByCols, $iSortColPrev, $hNotifyFunc, $hHeader, $aHdr_Info

	If $iIndex <> $iIdx Then
		Local $aMsgData
		If $iIndex <> -1 Then
			$aMsgData = $aDataDisplay_Info[$iIndex][10]
			$aMsgData[6]  = $fGotoFirst
			$aMsgData[7]  = $aAccelKeys
			$aMsgData[8]  = $bAccelKeys
			$aMsgData[12] = $iItemIdx
			$aMsgData[14] = $aSort_ByCols
			$aMsgData[15] = $iSortColPrev
			$aMsgData[18] = $aHdr_Info
			$aDataDisplay_Info[$iIndex][10] = $aMsgData
		EndIf
		$aMsgData = $aDataDisplay_Info[$iIdx][10]
		$hGUI            = $aMsgData[0]
		$idListView      = $aMsgData[1]
		$idGoto          = $aMsgData[2]
		$idTabKey        = $aMsgData[3]
		$idShiftTab      = $aMsgData[4]
		$idEnterKey      = $aMsgData[5]
		$fGotoFirst      = $aMsgData[6]
		$aAccelKeys      = $aMsgData[7]
		$bAccelKeys      = $aMsgData[8]
		$iRowCount       = $aMsgData[9]
		$idFunc          = $aMsgData[10]
		$hUser_Function  = $aMsgData[11]
		$iItemIdx        = $aMsgData[12]
		$aFeaturesInfo   = $aMsgData[13] 
		$aSort_ByCols    = $aMsgData[14]
		$iSortColPrev    = $aMsgData[15]
		$hNotifyFunc     = $aMsgData[16]
		$hHeader         = $aMsgData[17]
		$aHdr_Info       = $aMsgData[18]
		GUISetAccelerators( $aAccelKeys )
		$iIndex = $iIdx
	EndIf

	Local $idControlID
	Local $tItem = DllStructCreate($tagLVITEM)
	DllStructSetData($tItem, "Mask", $LVIF_STATE)
	DllStructSetData($tItem, "StateMask", $LVIS_FOCUSED+$LVIS_SELECTED)

	Switch $iMsg
		Case $idTabKey
			$idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $hGUI, "", ControlGetFocus( $hGUI ) ) )[0]
			Switch $idControlID
				Case $idListView
					If $fGotoFirst Then
						; Delete "Goto row" first time field gets focus
						ReDim $aAccelKeys[1][2]
						GUISetAccelerators( $aAccelKeys )
						GUICtrlSetData($idGoto, "")
						$fGotoFirst = False
					EndIf
					GUICtrlSetState( $idGoto, $GUI_FOCUS )
				Case $idGoto
					GUICtrlSetState( IsFunc( $hUser_Function ) ? $idFunc : $idListView, $GUI_FOCUS )
				Case $idFunc
					GUICtrlSetState( $idListView, $GUI_FOCUS )
			EndSwitch

		Case $idShiftTab
			$idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $hGUI, "", ControlGetFocus( $hGUI ) ) )[0]
			Switch $idControlID
				Case $idListView
					If IsFunc( $hUser_Function ) Then
						GUICtrlSetState( $idFunc, $GUI_FOCUS )
					Else
						If $fGotoFirst Then
							; Delete "Goto row" first time field gets focus
							ReDim $aAccelKeys[1][2]
							GUISetAccelerators( $aAccelKeys )
							GUICtrlSetData($idGoto, "")
							$fGotoFirst = False
						EndIf
						GUICtrlSetState( $idGoto, $GUI_FOCUS )
					EndIf
				Case $idGoto
					GUICtrlSetState( $idListView, $GUI_FOCUS )
				Case $idFunc
					If $fGotoFirst Then
						; Delete "Goto row" first time field gets focus
						ReDim $aAccelKeys[1][2]
						GUISetAccelerators( $aAccelKeys )
						GUICtrlSetData($idGoto, "")
						$fGotoFirst = False
					EndIf
					GUICtrlSetState( $idGoto, $GUI_FOCUS )
			EndSwitch

		Case $idEnterKey
			$idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $hGUI, "", ControlGetFocus( $hGUI ) ) )[0]
			Switch $idControlID
				Case $idGoto
					; Set previous Goto-item unfocused and unselected
					If $iItemIdx > -1 Then
						DllStructSetData($tItem, "State", 0) ; State unfocused + unselected
						DllStructSetData($tItem, "Item", $iItemIdx) ; Set item index
						GUICtrlSendMsg($idListView, $LVM_SETITEMSTATE, $iItemIdx, DllStructGetPtr($tItem)) ; Set state
					EndIf
					; Goto ListView item (set state focused + selected)
					$iItemIdx = Int(StringRegExpReplace(GUICtrlRead($idGoto), "\,", "")) ; Read item index
					If 0 <= $iItemIdx And $iItemIdx < $iRowCount Then
						GUICtrlSetData($idGoto, StringRegExpReplace($iItemIdx, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1,")) ; 1000 separator
						DllStructSetData($tItem, "Item", $iItemIdx) ; Set item index
						DllStructSetData($tItem, "State", $LVIS_FOCUSED+$LVIS_SELECTED) ; State focused + selected
						GUICtrlSendMsg($idListView, $LVM_ENSUREVISIBLE, $iItemIdx, 0) ; Make item visible
						GUICtrlSendMsg($idListView, $LVM_SETITEMSTATE, $iItemIdx, DllStructGetPtr($tItem)) ; Set state
						GUICtrlSetState($idListView, $GUI_FOCUS) ; Set focus to ListView
					EndIf
				Case $idFunc
					$hUser_Function()
			EndSwitch

		Case $idListView
			Local $iSortCol = GUICtrlGetState( $idListView )
			If $iSortCol And IsArray( $aSort_ByCols ) And $aSort_ByCols[2*($iSortCol-1)+0][0] Then _
				DataDisplay_SortByCols( $aFeaturesInfo[0], $aSort_ByCols, $iSortCol, $iSortColPrev, $iIdx, $hNotifyFunc, $idListView, $hHeader, $iRowCount )

		Case $idFunc
			$hUser_Function()

		Case 99998
			If $fGotoFirst Then
				If ControlGetFocus($hGUI) = "Edit1" Then
					; Delete "Goto row" first time field gets focus
					ReDim $aAccelKeys[1][2]
					GUISetAccelerators( $aAccelKeys )
					GUICtrlSetData($idGoto, "")
					$fGotoFirst = False
				EndIf
			EndIf

		Case 99999
			$aSort_ByCols = 0
			$aDataDisplay_Info0[20] -= 1 ; Decrease GUIs
	EndSwitch

	If $bAccelKeys Then
		$bAccelKeys = False
		GUISetAccelerators( $aAccelKeys )
	EndIf
EndFunc

Func DataDisplayCtrl_WM_COMMAND( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x0111 Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x0111 = WM_COMMAND
	Local Static $oDict = ObjCreate( "Scripting.Dictionary" )
	If Not $hWnd And $pData Then
		$oDict( $iIndex ) = Int( $pData )
		Return
	EndIf

	Local Static $iIdx = 0
	If $iIdx = $iIndex Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	$iIdx = $iIndex

	If $oDict.Exists( $iIndex ) Then
		Local $idFunc = $oDict( $iIndex )
		If $wParam = $idFunc - 1 Or $wParam = $idFunc Then $iIdx = 0
	EndIf          ; $idLabel

	Switch BitShift( $wParam, 16 ) ; HiWord
		Case 0x100 ; $EN_SETFOCUS
			DataDisplayCtrl_MsgHandler( 99998, $iIdx )
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc
