
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

; Check "SortRows", "SortCols" and "SortByCols" features
; "SortRows" and "SortByCols" can affect $iRowCount
; "SortCols" can affect $iColCount
Local $iFeatures = 0
Local $aFeaturesInfo[3]
	; 0 is used by "SortByCols": The markup type in listview header item to mark a column that can be used for sorting
	;                            Listview header item markup types: Up/down arrows (0), item texts (1), item colors (2)
	; 1 is used by "SortByCols": Sort initially the listview by this column
	; 2 is used by "DataTypes":  Data types info mode (1-3, 9-15)
If IsArray( $aFeatures ) Then
	For $i = 0 To UBound( $aFeatures ) - 1
		Switch $aFeatures[$i][0]
			Case "SortRows" ; Cannot be used with "SortByCols"
				If BitAND( $iFeatures, 128+512 ) Then ContinueLoop
				If Not ( IsArray( $aFeatures[$i][1] ) Or IsDllStruct( $aFeatures[$i][1] ) ) Then ContinueLoop
				$aSort_Rows = $aFeatures[$i][1]
				$iFeatures += 128
			Case "SortCols"
				If $iColCount < 2 Then ContinueLoop
				If BitAND( $iFeatures, 256 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aSort_Cols = $aFeatures[$i][1]
				$iFeatures += 256
			Case "SortByCols" ; Cannot be used with "HdrColors" or "SortRows"
				If BitAND( $iFeatures, 64+128+512 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aSort_ByCols = $aFeatures[$i][1]
				$aSort_Rows = DataDisplay_CheckSortByCols( $aSort_ByCols, $iRowCount, $iColCount, $aFeaturesInfo[0], $aFeaturesInfo[1] )
				If Not ( IsArray( $aSort_Rows ) Or IsDllStruct( $aSort_Rows ) ) Then
					$aSort_ByCols = ""
					ContinueLoop
				EndIf
				Switch $aFeaturesInfo[0] ; Markup type
					Case 0 ; Up/down arrows
						ReDim $aSort_ByCols[UBound($aSort_ByCols)][6] ; Add column to store header alignment
				EndSwitch
				$iFeatures += 512
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
