
Local $iMsg, $idControlID, $iItemIdx = -1, $s
Local $tItem = DllStructCreate($tagLVITEM)
DllStructSetData($tItem, "Mask", $LVIF_STATE)
DllStructSetData($tItem, "StateMask", $LVIS_FOCUSED+$LVIS_SELECTED)

While 1
	$iMsg = GUIGetMsg()
	Switch $iMsg
		Case 0, $GUI_EVENT_MOUSEMOVE
			ContinueLoop

		Case $idTabKey, $idShiftTab
			$idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $hGUI, "", ControlGetFocus( $hGUI ) ) )[0]
			If ( $iMsg = $idTabKey And $idControlID = $idListView ) Or ( $iMsg = $idShiftTab And $idControlID = $idGotoSuccessor ) Then
				; Delete "Goto row" first time field gets focus
				If $fGotoFirst Then
					ReDim $aAccelKeys[1][2]
					GUISetAccelerators( $aAccelKeys )
					GUICtrlSetState( $idGoto, $GUI_FOCUS )
					GUICtrlSetData($idGoto, "")
					$fGotoFirst = False
				EndIf
			Else
				$bAccelKeys = True
				GUISetAccelerators(0)
				ControlSend( $hGUI, "", $idControlID, $iMsg = $idTabKey ? "{TAB}" : "+{TAB}" )
			EndIf

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
					$s = StringRegExpReplace(GUICtrlRead($idGoto), "\,", "")
					$iItemIdx = Int( $s == "" ? -1 : $s ) ; Read item index
					If 0 <= $iItemIdx And $iItemIdx < $iRowCount Then
						GUICtrlSetData($idGoto, StringRegExpReplace($iItemIdx, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1,")) ; 1000 separator
						$iItemIdx = $i1dColumns ? ( $iItemIdx - Mod( $iItemIdx, $i1dColumns ) ) / $i1dColumns : $iItemIdx
						DllStructSetData($tItem, "Item", $iItemIdx) ; Set item index
						DllStructSetData($tItem, "State", $LVIS_FOCUSED+$LVIS_SELECTED) ; State focused + selected
						GUICtrlSendMsg($idListView, $LVM_ENSUREVISIBLE, $iItemIdx, 0) ; Make item visible
						GUICtrlSendMsg($idListView, $LVM_SETITEMSTATE, $iItemIdx, DllStructGetPtr($tItem)) ; Set state
						GUICtrlSetState($idListView, $GUI_FOCUS) ; Set focus to ListView
					ElseIf $iItemIdx = -1 Then
						GUICtrlSetState($idListView, $GUI_FOCUS) ; Set focus to ListView
					EndIf
				Case $idFunc
					; Reset original separator while user function is running
					Opt("GUIDataSeparatorChar", $sCurr_Separator)
					$hUser_Function()
					$sCurr_Separator = Opt("GUIDataSeparatorChar", $sAD_Separator)
				Case $idExit
					GUISetAccelerators(0)
					ControlSend( $hGUI, "", $idControlID, "{ENTER}" )
			EndSwitch

		Case $idListView
			Local $iSortCol = GUICtrlGetState( $idListView )
			If $iSortCol And IsArray( $aSort_ByCols ) And $aSort_ByCols[2*($iSortCol-1)+0][0] Then _
				DataDisplay_SortByCols( $aFeaturesInfo[0], $aSort_ByCols, $iSortCol, $iSortColPrev, $iIdx, $hNotifyFunc, $idListView, $hHeader, $i1dRows ? $i1dRows : $iRowCount )

		Case $idFunc
			; Reset original separator while user function is running
			Opt("GUIDataSeparatorChar", $sCurr_Separator)
			$hUser_Function()
			$sCurr_Separator = Opt("GUIDataSeparatorChar", $sAD_Separator)

		Case $idExit
			Exit

		Case $GUI_EVENT_CLOSE
			$aDataDisplay_Info[$iIdx][17]( $iIdx )
			$aDataDisplay_Info0[20] -= 1 ; Decrease GUIs
			ExitLoop

		Case Else
			; Delete "Goto row" first time field gets focus
			If $fGotoFirst Then
				If ControlGetFocus($hGUI) = "Edit1" Then
					ReDim $aAccelKeys[1][2]
					GUISetAccelerators( $aAccelKeys )
					GUICtrlSetData($idGoto, "")
					$fGotoFirst = False
				EndIf
			EndIf
	EndSwitch

	If $bAccelKeys Then
		$bAccelKeys = False
		GUISetAccelerators( $aAccelKeys )
	EndIf
WEnd
