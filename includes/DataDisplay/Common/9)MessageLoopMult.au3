
Local $iMsg, $idControlID
Local $tItem = DllStructCreate($tagLVITEM)
DllStructSetData($tItem, "Mask", $LVIF_STATE)
DllStructSetData($tItem, "StateMask", $LVIS_FOCUSED+$LVIS_SELECTED)

While Sleep(10)
	If $aDataDisplay_Info0[20] = 0 Then ExitLoop
	; Exit message loop if no more Mult-GUIs
	For $i = 1 To $aDataDisplay_Info0[21]
		If $aDataDisplay_Info[$i][20] And Not Mod( $aDataDisplay_Info[$i][15], 3 ) Then ExitLoop
	Next
	If $i = $aDataDisplay_Info0[21] + 1 Then ExitLoop

	;$iMsg = GUIGetMsg()
	For $iMsg = 22 To 30
		If $aDataDisplay_Info0[$iMsg] Then ExitLoop
	Next
	If $iMsg = 31 Then ContinueLoop
	$iIdx = $aDataDisplay_Info0[$iMsg]
	$aDataDisplay_Info0[$iMsg] = 0
	GUISetAccelerators( $aDataDisplay_Info[$iIdx][29] ) ; 29 = $aAccelKeys

	Switch $iMsg
		;Case $idTabKey, $idShiftTab
		Case 22, 23
			$idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $aDataDisplay_Info[$iIdx][21], "", ControlGetFocus( $aDataDisplay_Info[$iIdx][21] ) ) )[0] ; 21 = $hGUI
			If ( $iMsg = 22 And $idControlID = $aDataDisplay_Info[$iIdx][28] ) Or ( $iMsg = 23 And $idControlID = $aDataDisplay_Info[$iIdx][31] ) Then ; 28 = $idListView, 31 = $idGotoSuccessor
				; Delete "Goto row" first time field gets focus
				If $aDataDisplay_Info[$iIdx][32] Then _ ; 32 = $fGotoFirst
					DataDisplay_ClearGotoField( $iIdx, True )
			Else
				GUISetAccelerators(0)
				$aDataDisplay_Info[$iIdx][30] = True ; 30 = $bAccelKeys
				ControlSend( $aDataDisplay_Info[$iIdx][21], "", $idControlID, $iMsg = 22 ? "{TAB}" : "+{TAB}" )
			EndIf

		;Case $idListView
		Case 29
			Local $iSortCol = GUICtrlGetState( $aDataDisplay_Info[$iIdx][28] )
			$iSortCol = Not $i1dColumns ? $iSortCol : $iSortCol = 1 ? 1 : 0
			If $iSortCol And IsArray( $aSort_ByCols ) And $aSort_ByCols[2*($iSortCol-1)+0][0] Then _
				DataDisplay_SortByCols( $aDataDisplay_Info[$iIdx][44], $aDataDisplay_Info[$iIdx][45], $iSortCol, $aDataDisplay_Info[$iIdx][46], $iIdx, $aDataDisplay_Info[$iIdx][1], $aDataDisplay_Info[$iIdx][28], $aDataDisplay_Info[$iIdx][47], $aDataDisplay_Info[$iIdx][34] )
				                      ; $aFeaturesInfo[0],             $aSort_ByCols,                            $iSortColPrev                         $hNotifyFunc,                 $idListView,                   $hHeader,                      $iRowCount

		;Case $idListView
		Case 30
			; Delete "Goto row" if necessary
			If $aDataDisplay_Info[$iIdx][32] Then _ ; 32 = $fGotoFirst
				DataDisplay_ClearGotoField( $iIdx )
			; Reset original separator while display function is running
			Opt("GUIDataSeparatorChar", $sCurr_Separator)
			If IsArray( ($aDataDisplay_Info[$iIdx][36])[0] ) And IsFunc( $aDataDisplay_Info0[7] ) Then
				$aDataDisplay_Info0[7]( ($aDataDisplay_Info[$iIdx][36])[0], ($aDataDisplay_Info[$iIdx][36])[1], "", 0, $aFeatures ) ; _ArrayDisplayMult
			ElseIf IsPtr( ($aDataDisplay_Info[$iIdx][36])[0] ) And IsFunc( $aDataDisplay_Info0[37] ) Then
				$aDataDisplay_Info0[37]( ($aDataDisplay_Info[$iIdx][36])[0], ($aDataDisplay_Info[$iIdx][36])[1], "", 0, $aFeatures ) ; SafeArrayDisplayMult
			EndIf
			Opt("GUIDataSeparatorChar", $sAD_Separator)

		;Case Else
		Case 24
			; Delete "Goto row" first time field gets focus
			If $aDataDisplay_Info[$iIdx][32] _ ; $fGotoFirst
			And ControlGetFocus($aDataDisplay_Info[$iIdx][21]) = "Edit1" Then _
				DataDisplay_ClearGotoField( $iIdx )

		;Case $idGoto
		Case 25
			; Set previous Goto-item unfocused and unselected
			If $aDataDisplay_Info[$iIdx][35] > -1 Then ; 35 = $iItemIdx
				DllStructSetData($tItem, "State", 0) ; State unfocused + unselected
				DllStructSetData($tItem, "Item", $aDataDisplay_Info[$iIdx][35]) ; Set item index
				GUICtrlSendMsg($aDataDisplay_Info[$iIdx][28], $LVM_SETITEMSTATE, $aDataDisplay_Info[$iIdx][35], DllStructGetPtr($tItem))  ; 28 = $idListView, Set state
			EndIf
			; Goto ListView item (set state focused + selected)
			$aDataDisplay_Info[$iIdx][35] = Int(StringRegExpReplace(GUICtrlRead($aDataDisplay_Info[$iIdx][25]), "\,", "")) ; Read item index
			If 0 <= $aDataDisplay_Info[$iIdx][35] And $aDataDisplay_Info[$iIdx][35] < $aDataDisplay_Info[$iIdx][34] Then ; 34 = $iRowCount
				GUICtrlSetData($aDataDisplay_Info[$iIdx][25], StringRegExpReplace($aDataDisplay_Info[$iIdx][35], "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1,")) ; 1000 separator
				DllStructSetData($tItem, "Item", $aDataDisplay_Info[$iIdx][35]) ; Set item index
				DllStructSetData($tItem, "State", $LVIS_FOCUSED+$LVIS_SELECTED) ; State focused + selected
				GUICtrlSendMsg($aDataDisplay_Info[$iIdx][28], $LVM_ENSUREVISIBLE, $aDataDisplay_Info[$iIdx][35], 0) ; Make item visible
				GUICtrlSendMsg($aDataDisplay_Info[$iIdx][28], $LVM_SETITEMSTATE, $aDataDisplay_Info[$iIdx][35], DllStructGetPtr($tItem)) ; Set state
				GUICtrlSetState($aDataDisplay_Info[$iIdx][28], $GUI_FOCUS) ; Set focus to ListView
			EndIf

		;Case $idFunc
		Case 26
			; Delete "Goto row" if necessary
			If $aDataDisplay_Info[$iIdx][32] Then _ ; 32 = $fGotoFirst
				DataDisplay_ClearGotoField( $iIdx )
			; Reset original separator while user function is running
			Opt("GUIDataSeparatorChar", $sCurr_Separator)
			$aDataDisplay_Info[$iIdx][33]() ; $hUser_Function
			Opt("GUIDataSeparatorChar", $sAD_Separator)

		;Case $idExit
		Case 27
			Exit

		;Case $GUI_EVENT_CLOSE
		Case 28
			$aDataDisplay_Info[$iIdx][17]( $iIdx )
			$aDataDisplay_Info0[20] -= 1 ; Decrease GUIs
			If $aDataDisplay_Info0[20] = 0 Then ExitLoop
			; Exit message loop if no more Mult-GUIs
			For $i = 1 To $aDataDisplay_Info0[21]
				If $aDataDisplay_Info[$i][20] And Not Mod( $aDataDisplay_Info[$i][15], 3 ) Then ExitLoop
			Next
			If $i = $aDataDisplay_Info0[21] + 1 Then ExitLoop
	EndSwitch

	If $aDataDisplay_Info[$iIdx][30] Then
		$aDataDisplay_Info[$iIdx][30] = False ; 30 = $bAccelKeys
		GUISetAccelerators( $aDataDisplay_Info[$iIdx][29] ) ; 29 = $aAccelKeys
	EndIf
WEnd
