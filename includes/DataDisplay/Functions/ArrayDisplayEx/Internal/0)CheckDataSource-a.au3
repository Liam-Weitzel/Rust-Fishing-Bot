
Local $sMsg = "", $iRet = 1
If IsArray($aArray) Then
	; Dimension checking
	Local $iDimension = UBound($aArray, 0)
	If $iDimension > 2 Then
		$sMsg = "Larger than 2D array passed to function."
		$iRet = 2
	EndIf
Else
	$sMsg = "No array variable passed to function."
EndIf
If $sMsg Then
	If $bVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
			$sMbTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
		Exit
	Else
		Return SetError($iRet, 0, "")
	EndIf
EndIf

; $iRowCount, $iColCount
Local $iRowCount = UBound($aArray, 1), $iColCount = UBound($aArray, 2)

; Check "SortRows" and "SortCols" features at this point
; "SortRows" and "SortCols" can affect $iRowCount and $iColCount
Local $iFeatures = 0
If IsArray( $aFeatures ) Then
	For $i = 0 To UBound( $aFeatures ) - 1
		Switch $aFeatures[$i][0]
			Case "SortRows"
				If BitAND( $iFeatures, 128 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) And Not IsDllStruct( $aFeatures[$i][1] ) Then ContinueLoop
				$aSort_Rows = $aFeatures[$i][1]
				$iFeatures += 128
			Case "SortCols"
				If $iColCount < 2 Then ContinueLoop
				If BitAND( $iFeatures, 256 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aSort_Cols = $aFeatures[$i][1]
				$iFeatures += 256
		EndSwitch
	Next
EndIf

; Check $aSort_Rows, array
If IsArray( $aSort_Rows ) And UBound( $aSort_Rows, 0 ) <> 1 Then $aSort_Rows = ""
If IsArray( $aSort_Rows ) Then $iRowCount = UBound( $aSort_Rows )
; Check $aSort_Rows, struct
If IsDllStruct( $aSort_Rows ) Then $iRowCount = DllStructGetSize( $aSort_Rows ) / 4

; Check $aSort_Cols
If $iDimension = 2 Then
	If IsArray( $aSort_Cols ) And UBound( $aSort_Cols, 0 ) <> 1 Then $aSort_Cols = ""
	If IsArray( $aSort_Cols ) Then DataDisplay_CheckSortingColumns( $aSort_Cols, $iColCount )
EndIf
