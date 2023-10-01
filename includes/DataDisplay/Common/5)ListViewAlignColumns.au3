
If $iColAlign Or IsArray( $aAlignment ) Then
	; Check $aAlignment parameter
	If IsArray( $aAlignment ) Then
		For $i = 0 To UBound( $aAlignment ) - 1
			Switch $aAlignment[$i][1]
				Case "L", "Left"
					$aAlignment[$i][1] = 0
				Case "R", "Right"
					$aAlignment[$i][1] = 2
				Case "C", "Center"
					$aAlignment[$i][1] = 4
			EndSwitch
		Next
		For $i = 0 To UBound( $aAlignment ) - 1
			; There must be at least one valid row (index -1 included) in $aAlignment
			If ( $aAlignment[$i][0] = -1 Or $aAlignment[$i][0] < $iColCount + 1 ) And $aAlignment[$i][1] / 2 >= 0 And $aAlignment[$i][1] / 2 <= 2 Then ExitLoop
		Next
		If $i = UBound( $aAlignment ) Then $aAlignment = ""
		If IsArray( $aAlignment ) Then
			; Default alignment for unspecified columns
			For $i = 0 To UBound( $aAlignment ) - 1
				If $aAlignment[$i][0] = -1 Then ExitLoop
			Next
			If $i < UBound( $aAlignment ) And $aAlignment[$i][1] / 2 >= 0 And $aAlignment[$i][1] / 2 <= 2 Then $iColAlign = $aAlignment[$i][1]
		EndIf
	EndIf
	Local $bAlignment = IsArray( $aAlignment )
	; Set column alignment
	Local Const $LVCF_FMT = 0x01
	Local Const $LVM_SETCOLUMNW = (0x1000 + 96)
	Local $tColumn = DllStructCreate("uint Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order;int cxMin;int cxDefault;int cxIdeal")
	DllStructSetData($tColumn, "Mask", $LVCF_FMT)
	DllStructSetData($tColumn, "Fmt", $iColAlign / 2) ; Left = 0; Right = 1; Center = 2
	Local $pColumn = DllStructGetPtr($tColumn)
	; Loop through columns
	Local $iAlign
	For $i = 0 To $iColCount + ($iColCount=0)
		If $bAlignment Then
			For $j = 0 To UBound( $aAlignment ) - 1
				If $aAlignment[$j][0] = $i Then ExitLoop
			Next
			$iAlign = ( ( $j < UBound( $aAlignment ) And $aAlignment[$j][1] / 2 >= 0 And $aAlignment[$j][1] / 2 <= 2 ) ? $aAlignment[$j][1] : $iColAlign ) / 2
			If IsArray( $aHdr_Info ) Then $aHdr_Info[$i][1] = $iAlign = 0 ? 0 : $iAlign = 1 ? 2 : 1 ; $DT_LEFT = 0x0, $DT_RIGHT = 0x2, $DT_CENTER = 0x1
			If $i And IsArray( $aSort_ByCols ) And Not $aFeaturesInfo[0] Then $aSort_ByCols[2*($i-1)][5] = $iAlign
			DllStructSetData($tColumn, "Fmt", $iAlign) ; Left = 0; Right = 1; Center = 2
		Else
			$iAlign = $iColAlign / 2
			If IsArray( $aHdr_Info ) Then $aHdr_Info[$i][1] = $iAlign = 0 ? 0 : $iAlign = 1 ? 2 : 1 ; $DT_LEFT = 0x0, $DT_RIGHT = 0x2, $DT_CENTER = 0x1
			If $i And IsArray( $aSort_ByCols ) And Not $aFeaturesInfo[0] Then $aSort_ByCols[2*($i-1)][5] = $iAlign
		EndIf
		GUICtrlSendMsg($idListView, $LVM_SETCOLUMNW, $i, $pColumn)
	Next
	If $i1dColumns Then
		; Display 1d array in multiple columns
		; Set column alignment for columns 2 to $i1dColumns
		If IsArray( $aHdr_Info ) Then ReDim $aHdr_Info[$i1dColumns+1][3]
		If Not IsArray( $aHdr_Info ) Then Dim $aHdr_Info[$i1dColumns+1][3]
		For $i = 2 To $i1dColumns ; $i is the ListView column index
			$aHdr_Info[$i][1] = $aHdr_Info[1][1]
			GUICtrlSendMsg($idListView, $LVM_SETCOLUMNW, $i, $pColumn)
		Next
	EndIf
EndIf

; Sort rows by multiple columns
; Mark which columns can be used for sorting in listview header items
; This must be done after listview column alignment in code section above
Local $hHeader = HWnd( GUICtrlSendMsg( $idListView, $LVM_GETHEADER, 0, 0 ) )
Local $iSortArrow, $iSortColPrev = 0
If IsArray( $aSort_ByCols ) Then
	Switch $aFeaturesInfo[0] ; Listview header item markup type
		Case 0 ; Header item up/down arrows
			For $i = 0 To $iColCount + ($iColCount=0) - 1
				If Not $aSort_ByCols[2*$i][0] Then ContinueLoop ; No sorting by this column
				$iSortArrow = $aSort_ByCols[2*$i+0][0] = 1 ? $HDF_SORTUP : $HDF_SORTDOWN ; Sorting arrow
				DataDisplay_SetHeaderItemFormat( $hHeader, $i+1, $HDF_STRING + $iSortArrow + $aSort_ByCols[2*$i][5] ) ; Mark column
				If $i = $aFeaturesInfo[1] And Not $iSortColPrev Then
					GUICtrlSendMsg( $idListView, $LVM_SETSELECTEDCOLUMN, $i+1, 0 ) ; Set column selected
					$aSort_ByCols[2*$i+0][2] = $aSort_ByCols[2*$i+0][0] ; Current asc/desc
					$iSortColPrev = $i+1 ; Current column
				EndIf
			Next
	EndSwitch

	If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then
		; "SortByCols" variables used in main message loop
		$aDataDisplay_Info[$iIdx][44] = $aFeaturesInfo[0]
		$aDataDisplay_Info[$iIdx][45] = $aSort_ByCols
		$aDataDisplay_Info[$iIdx][46] = $iSortColPrev
		$aDataDisplay_Info[$iIdx][47] = $hHeader
	EndIf
EndIf
