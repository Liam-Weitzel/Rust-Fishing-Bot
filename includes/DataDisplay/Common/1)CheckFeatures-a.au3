
; Features
;
; Features implemented through Common\ files (always usable):
;     "ColAlign"    => Column alignment
;     "ColWidthMin" => Min. column width
;     "ColWidthMax" => Max. column width
;     "BackColor"   => Listview background color
;     "HdrColors"   => Listview header background colors
;     "UserFunc"    => User supplied function
;
; Features implemented through include files
;   End user features:                                         ; Include file:
;     "ColFormats"  => Column text formats                     ; <Display function>_ColumnFormats.au3
;     "ColColors"   => Column background colors                ; <Display function>_ColumnColors.au3
;     "SortRows"    => Sort rows in data source by index       ; <Display function>_SortFuncs.au3
;     "SortCols"    => Sort columns in data source by index    ; <Display function>_SortFuncs.au3
;     "SortByCols"  => Sort rows by multiple columns           ; <Display function>_SortFuncs.au3
;     "1dColumns"   => 1d array display columns                ; <Display function>_BasicFuncs.au3
;
;   Debugging features:                                        ; Include file:
;     "DataTypes"   => Data types info                         ; <Display function>_DataTypesInfo.au3
;
; See DisplayFeatures.txt for docu of features

; Check feature type
Local $aFeaturesInfo[3]
	; 0 is used by "SortByCols": The markup type in listview header item to mark a column that can be used for sorting
	;                            Listview header item markup types: Up/down arrows (0), item texts (1), item colors (2)
	; 1 is used by "SortByCols": Sort initially the listview by this column
	; 2 is used by "DataTypes":  Data types info mode (1-3, 9-15)
If IsArray( $aFeatures ) Then
	For $i = 0 To UBound( $aFeatures ) - 1
		Switch $aFeatures[$i][0]
			; Features implemented through Common\ files (always usable):
			Case "ColAlign"
				If BitAND( $iFeatures, 1 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aAlignment = DataDisplay_CheckArray( $aFeatures[$i][1], 2 )
				If Not IsArray( $aAlignment ) Then ContinueLoop
				$iFeatures += 1
			Case "ColWidthMin"
				If BitAND( $iFeatures, 2 ) Then ContinueLoop
				$aMin_ColWidth = $aFeatures[$i][1]
				If IsArray( $aMin_ColWidth ) Then $aMin_ColWidth = DataDisplay_CheckArray( $aMin_ColWidth, 2, 55 )
				$iFeatures += 2
			Case "ColWidthMax"
				If BitAND( $iFeatures, 4 ) Then ContinueLoop
				$iMax_ColWidth = Int( $aFeatures[$i][1] )
				If $iMax_ColWidth <= 0 Then $iMax_ColWidth = 350
				$iFeatures += 4
			Case "BackColor"
				If BitAND( $iFeatures, 32 ) Then ContinueLoop
				If Not $aFeatures[$i][1] Or BitAND( $aFeatures[$i][1], 0xFF000000 ) Then ContinueLoop
				$iLvBackColor = DataDisplay_ColorConvert( $aFeatures[$i][1] )
				$iFeatures += 32
			Case "HdrColors" ; Cannot be used with "SortByCols"
				If BitAND( $iFeatures, 64 ) Then ContinueLoop
				If BitAND( $iFeatures, 512 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then
					Dim $aHdr_Colors[2]
					$aHdr_Colors[0] = -1
					$aHdr_Colors[1] = $aFeatures[$i][1]
					$aFeatures[$i][1] = $aHdr_Colors
				EndIf
				$aHdr_Colors = DataDisplay_CheckArray( $aFeatures[$i][1], 2 )
				If Not IsArray( $aHdr_Colors ) Then ContinueLoop
				Dim $aHdr_Info[$iColCount+($iColCount=0)+1][3]
				$iFeatures += 64
			Case "UserFunc"
				If BitAND( $iFeatures, 1024 ) Then ContinueLoop
				If Not IsFunc( $aFeatures[$i][1] ) And Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$hUser_Function = $aFeatures[$i][1]
				$iFeatures += 1024

			; Features implemented through include files
			; End user features:
			Case "ColFormats"
				If BitAND( $iFeatures, 8 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				If UBound( $aFeatures[$i][1], 0 ) > 2 Then ContinueLoop
				$aColumn_Formats = DataDisplay_CheckColumnFormats( $aFeatures[$i][1], $iColCount )
				If Not IsArray( $aColumn_Formats ) Then ContinueLoop
				$iFeatures += 8
			Case "ColColors"
				If BitAND( $iFeatures, 16 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aColumn_Colors = DataDisplay_CheckArray( $aFeatures[$i][1], 2 )
				If Not IsArray( $aColumn_Colors ) Then ContinueLoop
				$iFeatures += 16
			;Case "SortRows" ; Checked in 0)CheckDataSource.au3 ; 128
			;Case "SortCols" ; Checked in 0)CheckDataSource.au3 ; 256
			Case "SortByCols" ; Cannot be used with "HdrColors" or "SortRows"
				If BitAND( $iFeatures, 192 ) Then ContinueLoop ; 64 + 128
				If BitAND( $iFeatures, 512 ) Then ContinueLoop
				If Not IsArray( $aFeatures[$i][1] ) Then ContinueLoop
				$aSort_ByCols = $aFeatures[$i][1]
				$aSort_Rows = DataDisplay_CheckSortByCols( $aSort_ByCols, $iRowCount, $iColCount, $aFeaturesInfo[0], $aFeaturesInfo[1] )
				If Not IsArray( $aSort_Rows ) And Not IsDllStruct( $aSort_Rows ) Then
					$aSort_ByCols = ""
					ContinueLoop
				EndIf
				Switch $aFeaturesInfo[0] ; Markup type
					Case 0 ; Up/down arrows
						ReDim $aSort_ByCols[UBound($aSort_ByCols)][6] ; Add column to store header alignment
				EndSwitch
				$iFeatures += 512
			Case "1dColumns"
				If $iDimension <> 1 Then ContinueLoop
				If BitAND( $iFeatures, 4096 ) Then ContinueLoop
				$i1dColumns = Int( $aFeatures[$i][1] )
				If $i1dColumns <= 1 Then $i1dColumns = 0
				If Not $i1dColumns Then ContinueLoop
				$iFeatures += 4096

			; Features implemented through include files
			; Debugging features:
			Case "DataTypes"
				If BitAND( $iFeatures, 2048 ) Then ContinueLoop
				If Not StringInStr( $sDataDisplay_Func, "ArrayDisplay" ) Then ContinueLoop ; ArrayDisplayEx or SafeArrayDisplay
				Switch $aFeatures[$i][1]
					Case 1, 2, 3 ; 9 To 15
						$aFeaturesInfo[2] = $aFeatures[$i][1]
					Case Else
						ContinueLoop
				EndSwitch
				$iFeatures += 2048
		EndSwitch
	Next
	If BitAND( $iFeatures, 16 ) Then _
		$aColumn_Colors = DataDisplay_CheckColumnColors( $aColumn_Colors, $iLvBackColor, $iColCount, $i1dColumns )
EndIf

; --- Check include files ---

$iRet = 3
$sMsg = ""
$iFeatures = 0

; Basic functionality
Local $hGetNotifyFunc = 0, $hNotifyFunc
Local $iColOffset = $sDataDisplay_Func = "ArrayDisplayEx"   ? 00 _
                  : $sDataDisplay_Func = "CSVfileDisplay"   ? 10 _
                  : $sDataDisplay_Func = "SafeArrayDisplay" ? 30 _
                  : $sDataDisplay_Func = "SQLiteDisplay"    ? 40 : 0
$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+1]
Switch $sDataDisplay_Func
	Case "ArrayDisplayEx"
		$hGetNotifyFunc( $hNotifyFunc, $iDimension, $i1dColumns )
	Case "CSVfileDisplay"
		$hGetNotifyFunc( $hNotifyFunc )
	Case "SQLiteDisplay"
		$hGetNotifyFunc( $hNotifyFunc )
	Case "SafeArrayDisplay"
		$hGetNotifyFunc( $hNotifyFunc, $iDimension )
EndSwitch

; Additional features
; Implemented through includes
If IsArray( $aFeatures ) Then
	If IsArray( $aSort_Rows ) Or IsDllStruct( $aSort_Rows ) Or IsArray( $aSort_Cols ) Then $iFeatures += 1
	If IsArray( $aColumn_Formats ) Then $iFeatures += 2
	If IsArray( $aColumn_Colors ) Then $iFeatures += 4
	If $aFeaturesInfo[2] Then $iFeatures += 8

	Switch $iFeatures
		Case 0 ; Basic functionality
			; Implemented through Common\ files
		Case 1 ; Sort 1d arrays by rows and 2d arrays by rows and columns
			If IsFunc( $aDataDisplay_Info0[$iColOffset+2] ) Then
				$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+2]
				Switch $sDataDisplay_Func
					Case "ArrayDisplayEx"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $i1dColumns, $aSort_Rows, $aSort_Cols )
					Case "CSVfileDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SQLiteDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SafeArrayDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $aSort_Rows, $aSort_Cols )
				EndSwitch
			Else
				$sMsg = $sDataDisplay_Func & "_SortFuncs.au3"
			EndIf
		Case 2, 3 ; Sort 1d arrays by rows and 2d arrays by rows and columns. Display subitems as formatted text.
			If IsFunc( $aDataDisplay_Info0[$iColOffset+3] ) Then
				$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+3]
				Switch $sDataDisplay_Func
					Case "ArrayDisplayEx"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $i1dColumns, $aSort_Rows, $aSort_Cols )
					Case "CSVfileDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SQLiteDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SafeArrayDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $aSort_Rows, $aSort_Cols )
				EndSwitch
			Else
				$sMsg = $sDataDisplay_Func & "_ColumnFormats.au3"
			EndIf
		Case 4, 5 ; Sort 1d arrays by rows and 2d arrays by rows and columns. Draw columns with colored background.
			If IsFunc( $aDataDisplay_Info0[$iColOffset+4] ) Then
				$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+4]
				Switch $sDataDisplay_Func
					Case "ArrayDisplayEx"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $i1dColumns, $aSort_Rows, $aSort_Cols )
					Case "CSVfileDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SQLiteDisplay"
						$hGetNotifyFunc( $hNotifyFunc )
					Case "SafeArrayDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension )
				EndSwitch
			Else
				$sMsg = $sDataDisplay_Func & "_ColumnColors.au3"
			EndIf
		Case 6, 7 ; Sort 1d arrays by rows and 2d arrays by rows and columns. Display subitems as formatted text. Draw columns with colored background.
			If IsFunc( $aDataDisplay_Info0[$iColOffset+5] ) Then
				$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+5]
				Switch $sDataDisplay_Func
					Case "ArrayDisplayEx"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $aSort_Rows, $aSort_Cols )
					Case "CSVfileDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $aSort_Rows, $aSort_Cols )
					Case "SQLiteDisplay"
						$hGetNotifyFunc( $hNotifyFunc )
					Case "SafeArrayDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension )
				EndSwitch
			Else
				$sMsg = $sDataDisplay_Func & "_FormatsColors.au3"
			EndIf
		Case 8
			If IsFunc( $aDataDisplay_Info0[$iColOffset+6] ) Then
				$hGetNotifyFunc = $aDataDisplay_Info0[$iColOffset+6]
				Switch $sDataDisplay_Func
					Case "ArrayDisplayEx"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $aFeaturesInfo[2] )
					Case "SafeArrayDisplay"
						$hGetNotifyFunc( $hNotifyFunc, $iDimension, $aFeaturesInfo[2] )
				EndSwitch
			Else
				$sMsg = $sDataDisplay_Func & "_DataTypesInfo.au3"
			EndIf
		Case Else
			$sMsg = "Unsupported feature or combination of features."
			If $bVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
					$sMbTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
				Exit
			Else
				Return SetError(4, 0, "")
			EndIf
	EndSwitch
EndIf

If $sMsg Then
	$sMsg = "Missing include file:" & @CRLF & $sMsg
	If $bVerbose And MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, _
			$sMbTitle, $sMsg & @CRLF & @CRLF & "Exit the script?") = $IDYES Then
		Exit
	Else
		Return SetError($iRet, 0, "")
	EndIf
EndIf
