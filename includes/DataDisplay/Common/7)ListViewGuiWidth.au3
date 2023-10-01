
; Check $aMin_ColWidth parameter
Local $iMin_ColWidth = 55 ; Array columns
Local $aMin_ColWidth_OK = 0
If IsArray( $aMin_ColWidth ) And UBound( $aMin_ColWidth, 0 ) <> 2 Then $aMin_ColWidth = 55
If IsArray( $aMin_ColWidth ) Then
	$aMin_ColWidth_OK = 1
	For $i = 0 To UBound( $aMin_ColWidth ) - 1
		; Check ListView minimum column width
		If $aMin_ColWidth[$i][1] < 55 Then
			$aMin_ColWidth[$i][1] = 55
			ContinueLoop
		EndIf
		; Default minimum column width
		If $aMin_ColWidth[$i][0] = -1 And $aMin_ColWidth[$i][1] > 55 And $iMin_ColWidth = 55 Then $iMin_ColWidth = $aMin_ColWidth[$i][1]
	Next
Else
	If $aMin_ColWidth < 55 Then $aMin_ColWidth = 55
	$iMin_ColWidth = $aMin_ColWidth
EndIf
; Adjust dialog width
Local $iWidth = 65, $iColWidth = 0, $aiColWidth[$iColCount+($iColCount=0)+1] ; $aiColWidth[($iColCount?$iColCount+1:2)]
; Get required column widths to fit items
Local $iMin_ColWidth_Current = $iMin_ColWidth
For $i = 0 To $iColCount + ($iColCount=0)
	; $i is the ListView column index
	If $aMin_ColWidth_OK Then
		; Does column exist in $aMin_ColWidth
		For $j = 0 To UBound( $aMin_ColWidth ) - 1
			If $aMin_ColWidth[$j][0] = $i Then ExitLoop
		Next
		$iMin_ColWidth_Current = $j < UBound( $aMin_ColWidth ) ? $aMin_ColWidth[$j][1] : $iMin_ColWidth
	EndIf
	GUICtrlSendMsg($idListView, $LVM_SETCOLUMNWIDTH, $i, $LVSCW_AUTOSIZE)
	$iColWidth = GUICtrlSendMsg($idListView, $LVM_GETCOLUMNWIDTH, $i, 0)
	; Set minimum if required
	If $iColWidth < $iMin_ColWidth_Current Then
		GUICtrlSendMsg($idListView, $LVM_SETCOLUMNWIDTH, $i, $iMin_ColWidth_Current)
		$iColWidth = $iMin_ColWidth_Current
	EndIf
	; Add to total width
	$iWidth += $iColWidth
	; Store  value
	$aiColWidth[$i] = $iColWidth
Next
If $i1dColumns Then
	; Display 1d array in multiple columns
	; Set column widths for columns 2 to $i1dColumns
	ReDim $aiColWidth[$i1dColumns+1]
	;$iColWidth = GUICtrlSendMsg($idListView, $LVM_GETCOLUMNWIDTH, 1, 0) ; $iColWidth is calculated above
	For $i = 2 To $i1dColumns ; $i is the ListView column index
		GUICtrlSendMsg($idListView, $LVM_SETCOLUMNWIDTH, $i, $iColWidth)
		; Add to total width
		$iWidth += $iColWidth
		; Store  value
		$aiColWidth[$i] = $iColWidth
	Next
EndIf
; Now check max size
If $iWidth > @DesktopWidth - 100 Then
	; Apply max col width limit to reduce width
	$iWidth = 65
	For $i = 0 To $iColCount
		If $aiColWidth[$i] > $iMax_ColWidth Then
			; Reset width
			GUICtrlSendMsg($idListView, $LVM_SETCOLUMNWIDTH, $i, $iMax_ColWidth)
			$iWidth += $iMax_ColWidth
		Else
			; Retain width
			$iWidth += $aiColWidth[$i]
		EndIf
	Next
EndIf
; Check max/min width
If $iWidth > @DesktopWidth - 100 Then
	$iWidth = @DesktopWidth - 100
ElseIf $iWidth < $iMinSize Then
	$iWidth = $iMinSize
EndIf
