#include-once

; DataDisplay_HeaderColor callback function
Func DataDisplay_HeaderColor( $hWnd, $iMsg, $wParam, $lParam, $iSubclassId, $hHeader )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $aHdrInfo, $tagNMCUSTOMDRAW = "struct;" & $tagNMHDR & ";dword dwDrawStage;handle hdc;" & $tagRECT & ";dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam;endstruct", $tRECT = DllStructCreate( $tagRECT )
	Local $tNMHDR = DllStructCreate( $tagNMHDR, $lParam ), $hWndFrom = HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) ), $iCode = DllStructGetData( $tNMHDR, "Code" )
	Switch $hWndFrom
		Case $hHeader
			Switch $iCode
				Case -12 ; $NM_CUSTOMDRAW
					Local $tNMCustomDraw = DllStructCreate( $tagNMCUSTOMDRAW, $lParam )
					Switch DllStructGetData( $tNMCustomDraw, "dwDrawStage" ) ; Holds a value that specifies the drawing stage
						Case 0x00000001     ; $CDDS_PREPAINT        ; Before the paint cycle begins
							Return 0x00000020 ; $CDRF_NOTIFYITEMDRAW  ; Notify parent window of any item related drawing operations
						Case 0x00010001     ; $CDDS_ITEMPREPAINT    ; Before an item is drawn: Default painting (frames and background)
							Return 0x00000010 ; $CDRF_NOTIFYPOSTPAINT ; Notify parent window of any post item related drawing operations
						Case 0x00010002     ; $CDDS_ITEMPOSTPAINT   ; After an item is drawn: Custom painting (item texts)
							Local $iIndex = DllStructGetData( $tNMCustomDraw, "dwItemSpec" )         ; Header item index
							If $aHdrInfo[$iIndex][2] = -1 Then Return                                ; No background color
							Local $hDC = DllStructGetData( $tNMCustomDraw, "hdc" )                   ; Header device context
							DllCall( "gdi32.dll", "int", "SetBkMode", "handle", $hDC, "int", 1 )     ; Transparent background, 1 = $TRANSPARENT, _WinAPI_SetBkMode
							DllStructSetData( $tRECT, 1, DllStructGetData( $tNMCustomDraw, 6 ) + 1 ) ; Header item rectangle
							DllStructSetData( $tRECT, 2, DllStructGetData( $tNMCustomDraw, 7 ) + 1 )
							DllStructSetData( $tRECT, 3, DllStructGetData( $tNMCustomDraw, 8 ) - 2 )
							DllStructSetData( $tRECT, 4, DllStructGetData( $tNMCustomDraw, 9 ) - 2 )
							DllCall( "user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $tRect, "handle", $aHdrInfo[$iIndex][2] ) ; Background color, _WinAPI_FillRect
							DllStructSetData( $tNMCustomDraw, "Left",   DllStructGetData( $tNMCustomDraw, "Left" )  + 4 ) ; Left margin
							DllStructSetData( $tNMCustomDraw, "Right",  DllStructGetData( $tNMCustomDraw, "Right" ) - 4 ) ; Right margin
							DllCall( "user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", $aHdrInfo[$iIndex][0], "int", StringLen( $aHdrInfo[$iIndex][0] ), "struct*", DllStructGetPtr( $tNMCustomDraw, "Left" ), "uint", $aHdrInfo[$iIndex][1]+0x20+0x4 ) ; 0x20+0x4 = $DT_SINGLELINE+$DT_VCENTER, _WinAPI_DrawText
							Return 0x00000002 ; $CDRF_NEWFONT         ; $CDRF_NEWFONT must be returned after changing font or colors
					EndSwitch
			EndSwitch
			; Initialize statics
			If $iSubclassId = -1 Then
				$aHdrInfo = $wParam
				Return
			EndIf
	EndSwitch
	; Call next function in subclass chain
	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
EndFunc

; _GUICtrlHeader_SetItemFormat
; Author ........: Paul Campbell (PaulIA)
; Modified.......: Gary Frost (gafrost)
Func DataDisplay_SetHeaderItemFormat($hWnd, $iIndex, $iFormat)
	Local $tItem = DllStructCreate("uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State") ; $tagHDITEM
	DllStructSetData($tItem, "Mask", 0x00000004) ; 0x00000004 = $HDI_FORMAT
	DllStructSetData($tItem, "Fmt", $iFormat)
	Return DataDisplay_SendMessage($hWnd, 0x120C, $iIndex, $tItem, 0, "wparam", "struct*") <> 0 ; 0x120C = $HDM_SETITEMW
EndFunc

; _SendMessage
; Author ........: Valik
; Modified.......: Gary Frost (GaryFrost) aka gafrost
Func DataDisplay_SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
	Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
	If @error Then Return SetError(@error, @extended, "")
	If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
	Return $aResult
EndFunc

Func DataDisplay_SortByCols( $iFeature, ByRef $aSort_ByCols, $iSortCol, ByRef $iSortColPrev, $iIdx, $hNotifyFunc, $idListView, $hHeader, $iRowCount )
	Local $iSort, $iSortArrow
	Switch $iFeature ; Listview header item markup type
		Case 0 ; Header item up/down arrows
			If $iSortCol = $iSortColPrev Then ; Current column
				If Not $aSort_ByCols[2*($iSortCol-1)+1][0] Then Return ; Only one sorting direction
				; Update sorting information in $aSort_ByCols and $aDataDisplay_Info arrays
				$iSort = DataDisplay_SortByColsCurrentColumn( $aSort_ByCols, $iSortCol, $iIdx )
				; Set up/down arrow in listview header item to indicate sort direction
				$iSortArrow = $iSort = 1 ? $HDF_SORTUP : $HDF_SORTDOWN
				DataDisplay_SetHeaderItemFormat( $hHeader, $iSortCol, $HDF_STRING + $iSortArrow + $aSort_ByCols[2*($iSortCol-1)][5] )
			Else ; New column
				; Reset header item mark in previous sorting column
				$iSortArrow = $aSort_ByCols[2*($iSortColPrev-1)+0][0] = 1 ? $HDF_SORTUP : $HDF_SORTDOWN
				DataDisplay_SetHeaderItemFormat( $hHeader, $iSortColPrev, $HDF_STRING + $iSortArrow + $aSort_ByCols[2*($iSortColPrev-1)][5] ) ; Reset prev
				; Update sorting information in $aSort_ByCols and $aDataDisplay_Info arrays
				DataDisplay_SortByColsNewColumn( $aSort_ByCols, $iSortCol, $iIdx )
				; Set up/down arrow in listview header item to indicate sort direction
				$iSortArrow = $aSort_ByCols[2*($iSortCol-1)+0][0] = 1 ? $HDF_SORTUP : $HDF_SORTDOWN
				DataDisplay_SetHeaderItemFormat( $hHeader, $iSortCol, $HDF_STRING + $iSortArrow + $aSort_ByCols[2*($iSortCol-1)][5] )
				; Mark the listview sorting column with a muted gray color
				GUICtrlSendMsg( $idListView, $LVM_SETSELECTEDCOLUMN, $iSortCol, 0 ) ; Set column selected
				$iSortColPrev = $iSortCol ; Current column
			EndIf
	EndSwitch
	; Update data in WM_NOTIFY message handler and force update of ListView
	$hNotifyFunc( 0, 0x004E, 0, 0, $iIdx, 0 ) ; 0x004E = $WM_NOTIFY ; Delete previous $hNotifyFunc data
	$hNotifyFunc( 0, 0x004E, 0, 0, $iIdx, 0 ) ; 0x004E = $WM_NOTIFY	; Update local static $hNotifyFunc data
	GUICtrlSendMsg( $idListView, $LVM_SETITEMCOUNT, $iRowCount, 0 ) ; Update ListView with new sort order
EndFunc

Func DataDisplay_SortByColsCurrentColumn( ByRef $aSort_ByCols, $iSortCol, $iIdx )
	; Change sort direction from the current to the opposite (asc --> desc or desc --> asc)
	Local $iSort = $aSort_ByCols[2*($iSortCol-1)+0][2] = $aSort_ByCols[2*($iSortCol-1)+0][0] ; Default sort?
	If $aSort_ByCols[2*($iSortCol-1)+1][1] <> "" Then ; Two sorting indexes for default and reverse sort direction
		$aDataDisplay_Info[$iIdx][3] = $iSort ? $aSort_ByCols[2*($iSortCol-1)+1][1] : $aSort_ByCols[2*($iSortCol-1)+0][1]
	Else ; Only one sorting index for both default (asc or desc) and reverse (opposite) sort
		$aDataDisplay_Info[$iIdx][9] = $iSort ? 1 : 0 ; Set $bSort_Reverse to true/false
	EndIf
	$iSort = $iSort ? $aSort_ByCols[2*($iSortCol-1)+1][0] : $aSort_ByCols[2*($iSortCol-1)+0][0] ; Reverse sort
	$aSort_ByCols[2*($iSortCol-1)+0][2] = $iSort ; Current sort direction
	Return $iSort
EndFunc

Func DataDisplay_SortByColsNewColumn( ByRef $aSort_ByCols, $iSortCol, $iIdx )
	$aSort_ByCols[2*($iSortCol-1)+0][2] = $aSort_ByCols[2*($iSortCol-1)+0][0] ; Current asc/desc
	$aDataDisplay_Info[$iIdx][3] = $aSort_ByCols[2*($iSortCol-1)+0][1] ; Sorting index
	$aDataDisplay_Info[$iIdx][9] = 0 ; Reset $bSort_Reverse to default
EndFunc

Func DataDisplayMult_MsgHandler( $hWnd, $iMsg, $wParam, $lParam, $iIdx, $pData ) ; $iSubclassId = $iIdx
	If $iMsg <> $WM_COMMAND And $iMsg <> $WM_SYSCOMMAND Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]

	Switch $iMsg
		Case $WM_COMMAND
			Switch BitAND( $wParam, 0xFFFF )      ; LoWord
				Case $aDataDisplay_Info[$iIdx][22]  ; $idTabKey
					$aDataDisplay_Info0[22] = $iIdx ; $idTabKey event
				Case $aDataDisplay_Info[$iIdx][23]  ; $idShiftTab
					$aDataDisplay_Info0[23] = $iIdx ; $idShiftTab event
				Case $aDataDisplay_Info[$iIdx][24]  ; $idEnterKey
					Local $idControlID = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $aDataDisplay_Info[$iIdx][21], "", ControlGetFocus( $aDataDisplay_Info[$iIdx][21] ) ) )[0]
					Switch BitShift( $wParam, 16 )    ; HiWord
						Case 1 ; Accelerator
							Switch $idControlID
								Case $aDataDisplay_Info[$iIdx][25]  ; $idGoto
									$aDataDisplay_Info0[25] = $iIdx ; $idGoto click event
								Case $aDataDisplay_Info[$iIdx][26]  ; $idFunc
									$aDataDisplay_Info0[26] = $iIdx ; $idFunc click event
								Case $aDataDisplay_Info[$iIdx][27]  ; $idExit
									$aDataDisplay_Info0[27] = $iIdx ; $idExit click event
							EndSwitch
					EndSwitch
				Case $aDataDisplay_Info[$iIdx][25]      ; $idGoto
					Switch BitShift( $wParam, 16 )        ; HiWord
						Case 0x100 ; 0x100 = $EN_SETFOCUS
							$aDataDisplay_Info0[24] = $iIdx ; $idGoto focus event
					EndSwitch
				Case $aDataDisplay_Info[$iIdx][26]      ; $idFunc
					Switch BitShift( $wParam, 16 )        ; HiWord
						Case 0 ; 0 = $BN_CLICKED
							$aDataDisplay_Info0[26] = $iIdx ; $idFunc click event
					EndSwitch
				Case $aDataDisplay_Info[$iIdx][27]      ; $idExit
					Switch BitShift( $wParam, 16 )        ; HiWord
						Case 0 ; 0 = $BN_CLICKED
							$aDataDisplay_Info0[27] = $iIdx ; $idExit click event
					EndSwitch
				Case Else
					Local $idEnter = BitAND( $wParam, 0xFFFF )
					For $i = 1 To $aDataDisplay_Info0[21]
						If $aDataDisplay_Info[$i][24] = $idEnter Then ExitLoop
					Next
					If $i < $aDataDisplay_Info0[21] + 1 Then
						$idEnter = DllCall( "user32.dll", "int", "GetDlgCtrlID", "hwnd", ControlGetHandle( $aDataDisplay_Info[$iIdx][21], "", ControlGetFocus( $aDataDisplay_Info[$iIdx][21] ) ) )[0]
						Switch BitShift( $wParam, 16 )    ; HiWord
							Case 1 ; Accelerator
								Switch $idEnter
									Case $aDataDisplay_Info[$iIdx][25]  ; $idGoto
										$aDataDisplay_Info0[25] = $iIdx ; $idGoto click event
									Case $aDataDisplay_Info[$iIdx][26]  ; $idFunc
										$aDataDisplay_Info0[26] = $iIdx ; $idFunc click event
									Case $aDataDisplay_Info[$iIdx][27]  ; $idExit
										$aDataDisplay_Info0[27] = $iIdx ; $idExit click event
								EndSwitch
						EndSwitch
					EndIf
			EndSwitch

		Case $WM_SYSCOMMAND
			Switch $hWnd
				Case $aDataDisplay_Info[$iIdx][21]      ; $hGUI
					Switch $wParam
						Case 0xF060 ; 0xF060 = $SC_CLOSE
							$aDataDisplay_Info0[28] = $iIdx ; GUI close event
					EndSwitch
			EndSwitch
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

Func DataDisplay_ClearGotoField( $iIdx, $bFocus = False )
	Local $aAccelKeys = $aDataDisplay_Info[$iIdx][29] ; 29 = $aAccelKeys
	ReDim $aAccelKeys[1][2]
	GUISetAccelerators( $aAccelKeys )
	If $bFocus Then GUICtrlSetState( $aDataDisplay_Info[$iIdx][25], $GUI_FOCUS ) ; 25 = $idGoto
	GUICtrlSetData($aDataDisplay_Info[$iIdx][25], "") ; 25 = $idGoto
	$aDataDisplay_Info[$iIdx][29] = $aAccelKeys ; 29 = $aAccelKeys
	$aDataDisplay_Info[$iIdx][32] = False ; 32 = $fGotoFirst
EndFunc
