#include-once

Func DataDisplay_CheckArray( $aArray, $iCols, $vDef = "" )
	If UBound( $aArray, 0 ) > 2 Then Return $vDef
	If UBound( $aArray, 0 ) = 1 And UBound( $aArray, 1 ) <> $iCols Then Return $vDef ; 1d array with $iCols elements?
	If UBound( $aArray, 0 ) = 2 And UBound( $aArray, 2 ) <> $iCols Then Return $vDef ; 2d array with $iCols columns?

	If UBound( $aArray, 0 ) = 2 Then Return $aArray

	; Make $aArray a 2d array
	Local $aTmp = [ [ $aArray[0], $aArray[1] ] ]
	Return $aTmp
EndFunc


; --- "ColFormats" => Column text formats ---

; Necessary checks to prevent that format-
; ting functions fails with a fatal error.
Func DataDisplay_CheckColumnFormats( $aFormats, $iColCount )

	; Formatting functions:                                             ; $aFormats 1d/2d array:                                                  ; Fields
	;
	; IntCustom( $iInt, $sFmt, $sNeg = "" )                             ; [ Col index, "IntCustom",        $sFmt, ($sNeg)                      ]  ; 3 + 1
	; Int1000Sep( $iInt, $sSep )                                        ; [ Col index, "Int1000Sep",       $sSep                               ]  ; 3
	; Int1000SepCustom( $iInt, $sSep, $sFmt, $sNeg )                    ; [ Col index, "Int1000SepCustom", $sSep, $sFmt, $sNeg                 ]  ; 5
	;
	; FltCustom( $fFlt, $sFmt, $sNeg = "" )                             ; [ Col index, "FltCustom",        $sFmt, ($sNeg)                      ]  ; 3 + 1
	; Flt1000Sep( $fFlt, $sSep, $sDec, $iDec = 2 )                      ; [ Col index, "Flt1000Sep",       $sSep, $sDec, ($iDec)               ]  ; 4 + 1
	; Flt1000SepCustom( $fFlt, $sSep, $sDec, $sFmt, $sNeg, $iDec = 2 )  ; [ Col index, "Flt1000SepCustom", $sSep, $sDec, $sFmt, $sNeg, ($iDec) ]  ; 6 + 1
	;
	; DateDMY( $iYMD, $sSep )                                           ; [ Col index, "DateDMY",          $sSep                               ]  ; 3
	; DateMDY( $iYMD, $sSep )                                           ; [ Col index, "DateMDY",          $sSep                               ]  ; 3
	; DateYMD( $iYMD, $sSep )                                           ; [ Col index, "DateYMD",          $sSep                               ]  ; 3
	;
	; TimeHM( $iHMS )                                                   ; [ Col index, "TimeHM",                                               ]  ; 2
	; TimeHMS( $iHMS )                                                  ; [ Col index, "TimeHMS",                                              ]  ; 2

	Local $aInfo = [ _
		[ "IntCustom",        3, 4, DataDisplay_IntCustom        ], _
		[ "Int1000Sep",       3, 3, DataDisplay_Int1000Sep       ], _
		[ "Int1000SepCustom", 5, 5, DataDisplay_Int1000SepCustom ], _
		[ "FltCustom",        3, 4, DataDisplay_FltCustom        ], _
		[ "Flt1000Sep",       4, 5, DataDisplay_Flt1000Sep       ], _
		[ "Flt1000SepCustom", 6, 7, DataDisplay_Flt1000SepCustom ], _
		[ "DateDMY",          3, 3, DataDisplay_DateDMY          ], _
		[ "DateMDY",          3, 3, DataDisplay_DateMDY          ], _
		[ "DateYMD",          3, 3, DataDisplay_DateYMD          ], _
		[ "TimeHM",           2, 2, DataDisplay_TimeHM           ], _
		[ "TimeHMS",          2, 2, DataDisplay_TimeHMS          ] ]

	Local $iCols, $kMax

	; $aFormats 1d array
	If UBound( $aFormats, 0 ) = 1 Then
		$iCols = UBound( $aFormats, 1 )
		If $iCols < 2 Then Return ""
		Local $aTmp[1][$iCols+1]
		; Formatting function name
		For $j = 0 To 10
			If $aInfo[$j][0] = $aFormats[1] Then ExitLoop
		Next
		; Enough information
		If $j = 11 Or $iCols < $aInfo[$j][1] Then Return ""
		; Data source column index
		If $aFormats[0] < 0 Or $aFormats[0] > $iColCount+($iColCount=0) - 1 Then Return ""
		; Number of info fields
		$kMax = ( $aInfo[$j][2] <= $iCols And $aFormats[$aInfo[$j][2]-1] ) ? $aInfo[$j][2] : $aInfo[$j][1]
		; Make $aFormats a 2d array
		For $k = 0 To $kMax - 1
			If $k > 1 And Not $aFormats[$k] Then Return ""
			$aTmp[0][$k] = $aFormats[$k]
		Next
		$aTmp[0][1] = $aInfo[$j][3] ; Formatting function
		$aTmp[0][$iCols] = $kMax    ; Number of info fields in last col
		Return DataDisplay_ColumnFormatsCol2Idx( $aTmp, $iColCount )
	EndIf

	; $aFormats 2d array
	Local $iRows = UBound( $aFormats, 1 )
	$iCols = UBound( $aFormats, 2 )
	If $iCols < 2 Then Return ""
	Local $aTmp2[$iRows][$iCols+1], $iTmp2 = 0
	For $i = 0 To $iRows - 1
		; Formatting function name
		For $j = 0 To 10
			If $aInfo[$j][0] = $aFormats[$i][1] Then ExitLoop
		Next
		; Enough information
		If $j = 11 Or $iCols < $aInfo[$j][1] Then ContinueLoop
		; Data source column index
		If $aFormats[$i][0] < 0 Or $aFormats[$i][0] > $iColCount+($iColCount=0) - 1 Then ContinueLoop
		; Number of info fields
		$kMax = ( $aInfo[$j][2] <= $iCols And $aFormats[$i][$aInfo[$j][2]-1] ) ? $aInfo[$j][2] : $aInfo[$j][1]
		For $k = 0 To $kMax - 1
			If $k > 1 And Not $aFormats[$i][$k] Then ContinueLoop 2
			$aTmp2[$iTmp2][$k] = $aFormats[$i][$k]
		Next
		$aTmp2[$iTmp2][1] = $aInfo[$j][3] ; Formatting function
		$aTmp2[$iTmp2][$iCols] = $kMax    ; Number of info fields in last col
		$iTmp2 += 1
	Next
	If Not $iTmp2 Then Return ""
	If $iTmp2 < $iRows Then ReDim $aTmp2[$iTmp2][$iCols+1]
	Return DataDisplay_ColumnFormatsCol2Idx( $aTmp2, $iColCount )
EndFunc

Func DataDisplay_ColumnFormatsCol2Idx( $aFormats, $iColCount )
	Local $iCols = UBound( $aFormats, 2 )
	Local $aTmp[$iColCount+($iColCount=0)][$iCols]
	For $i = 0 To UBound( $aFormats ) - 1
		$aTmp[$aFormats[$i][0]][0] = 1
		For $j = 1 To $iCols - 1
			$aTmp[$aFormats[$i][0]][$j] = $aFormats[$i][$j]
		Next
	Next
	Return $aTmp
EndFunc

Func DataDisplay_IntCustom( $iInt, $sFmt, $sNeg = "" )
	Return ( $sNeg ? StringFormat( ( $iInt < 0 ? $sNeg : $sFmt ), StringRegExpReplace( $iInt, "-?(\d+)", "\1" ) ) : StringFormat( $sFmt, $iInt ) )
EndFunc
Func DataDisplay_Int1000Sep( $iInt, $sSep )
	Return StringRegExpReplace( $iInt, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1" & $sSep )
EndFunc
Func DataDisplay_Int1000SepCustom( $iInt, $sSep, $sFmt, $sNeg )
	Return StringFormat( ( $iInt < 0 ? $sNeg : $sFmt ), StringRegExpReplace( $iInt, "-?(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1" & $sSep ) )
EndFunc
Func DataDisplay_FltCustom( $fFlt, $sFmt, $sNeg = "" )
	$fFlt = StringRegExpReplace( $fFlt, "\,", "." )
	Return ( $sNeg ? StringFormat( ( $fFlt < 0 ? $sNeg : $sFmt ), StringRegExpReplace( $fFlt, "-?(.+)", "\1" ) ) : StringFormat( $sFmt, $fFlt ) )
EndFunc
Func DataDisplay_Flt1000Sep( $fFlt, $sSep, $sDec, $iDec = 2 )
	Local $a = StringRegExp( StringFormat( "%." & ( $iDec ? $iDec : 2 ) & "f", $fFlt ), "(-?\d+)(\.|\,)(\d+)$", 1 )
	Return ( StringIsFloat( $fFlt ) Or StringIsInt( $fFlt ) ) ? StringRegExpReplace( $a[0], "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1" & $sSep ) & $sDec & $a[2] : $fFlt
EndFunc
Func DataDisplay_Flt1000SepCustom( $fFlt, $sSep, $sDec, $sFmt, $sNeg, $iDec = 2 )
	Local $a = StringRegExp( StringFormat( "%." & ( $iDec ? $iDec : 2 ) & "f", $fFlt ), "(\d+)(\.|\,)(\d+)$", 1 )
	Return StringFormat( ( $fFlt < 0 ? $sNeg : $sFmt ), StringRegExpReplace( $a[0], "-?(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1" & $sSep ) & $sDec & $a[2] )
EndFunc
Func DataDisplay_DateDMY( $iYMD, $sSep )
	Local $a = StringRegExp( "0000" & $iYMD, "(\d\d\d\d)(\d\d)(\d\d)$", 1 )
	Return @error = 0 ? $a[2] & $sSep & $a[1] & $sSep & $a[0] : $iYMD
EndFunc
Func DataDisplay_DateMDY( $iYMD, $sSep )
	Local $a = StringRegExp( "0000" & $iYMD, "(\d\d\d\d)(\d\d)(\d\d)$", 1 )
	Return @error = 0 ? $a[1] & $sSep & $a[2] & $sSep & $a[0] : $iYMD
EndFunc
Func DataDisplay_DateYMD( $iYMD, $sSep )
	Local $a = StringRegExp( "0000" & $iYMD, "(\d\d\d\d)(\d\d)(\d\d)$", 1 )
	Return @error = 0 ? $a[0] & $sSep & $a[1] & $sSep & $a[2] : $iYMD
EndFunc
Func DataDisplay_TimeHM( $iHMS )
	Local $a = StringRegExp( "00000" & $iHMS, "(\d\d)(\d\d)(\d\d)$", 1 )
	Return @error = 0 ? $a[0] & ":" & $a[1] : $iHMS
EndFunc
Func DataDisplay_TimeHMS( $iHMS )
	Local $a = StringRegExp( "00000" & $iHMS, "(\d\d)(\d\d)(\d\d)$", 1 )
	Return @error = 0 ? $a[0] & ":" & $a[1] & ":" & $a[2] : $iHMS
EndFunc


; --- "ColColors" => Column background colors ---

; Check valid colors and convert $aColors to a for-
; mat that is efficient in WM_NOTIFY message handlers.
Func DataDisplay_CheckColumnColors( $aColors, $iLvBackColor, $iColCount, $i1dColumns )
	$iColCount += ($iColCount=0) + 1
	Local $aColColors[$iColCount]
	For $i = 0 To $iColCount - 1
		$aColColors[$i] = $iLvBackColor
	Next
	For $i = 0 To UBound( $aColors ) - 1
		Switch $aColors[$i][0]
			Case 0 To $iColCount - 1
				If Not $aColors[$i][1] Or BitAND( $aColors[$i][1], 0xFF000000 ) Then ContinueLoop
				$aColColors[$aColors[$i][0]] = DataDisplay_ColorConvert( $aColors[$i][1] )
		EndSwitch
	Next
	If $i1dColumns Then
		; Display 1d array in multiple columns
		; Set column colors for columns 2 to $i1dColumns
		ReDim $aColColors[$i1dColumns+1]
		For $i = 2 To $i1dColumns ; $i is the ListView column index
			$aColColors[$i] = $aColColors[1]
		Next
	EndIf
	Return $aColColors
EndFunc

; RGB to BGR or BGR to RGB
Func DataDisplay_ColorConvert($iColor)
	Return BitOR(BitAND($iColor, 0x00FF00), BitShift(BitAND($iColor, 0x0000FF), -16), BitShift(BitAND($iColor, 0xFF0000), 16))
EndFunc


; --- "SortCols" => Sort columns in data source by index ---

; Check valid column indices in $aSort_Cols
Func DataDisplay_CheckSortingColumns( ByRef $aSort_Cols, ByRef $iColCount )
	Local $iColCount2 = UBound( $aSort_Cols )
	For $i = 0 To $iColCount2 - 1
		If $aSort_Cols[$i] < 0 Or $aSort_Cols[$i] > $iColCount - 1 Then ExitLoop
	Next
	If $i = $iColCount2 Then
		$iColCount = $iColCount2
	Else
		Local $aSort_Cols2[$iColCount2], $j = 0
		For $i = 0 To $iColCount2 - 1
			If $aSort_Cols[$i] < 0 Or $aSort_Cols[$i] > $iColCount - 1 Then ContinueLoop
			$aSort_Cols2[$j] = $aSort_Cols[$i]
			$j += 1
		Next
		If $j = 0 Then
			$aSort_Cols = ""
		Else
			If $j < $iColCount2 Then ReDim $aSort_Cols2[$j]
			$aSort_Cols = $aSort_Cols2
			$iColCount = $j
		EndIf
	EndIf
EndFunc


; --- "SortByCols" => Sort rows by multiple columns ---

; Check valid column indices, sorting indexes and asc/desc specifications
Func DataDisplay_CheckSortByCols( ByRef $aSort_ByCols, $iRows, $iCols, ByRef $iMarkupType, ByRef $iFirstCol )
	If UBound( $aSort_ByCols, 0 ) > 2 Then Return ""
	If UBound( $aSort_ByCols, 0 ) = 1 And ( UBound( $aSort_ByCols, 1 ) < 3 Or UBound( $aSort_ByCols, 1 ) > 5 ) Then Return ""
	If UBound( $aSort_ByCols, 0 ) = 2 And ( UBound( $aSort_ByCols, 2 ) < 3 Or UBound( $aSort_ByCols, 2 ) > 5 ) Then Return ""

	If UBound( $aSort_ByCols, 0 ) = 1 Then
		; Make $aSort_ByCols a 2d array
		Switch UBound( $aSort_ByCols, 1 )
			Case 3
				Local $aTmp3 = [ [ $aSort_ByCols[0], $aSort_ByCols[1], $aSort_ByCols[2] ] ]
				$aSort_ByCols = $aTmp3
			Case 4
				Local $aTmp4 = [ [ $aSort_ByCols[0], $aSort_ByCols[1], $aSort_ByCols[2], $aSort_ByCols[3] ] ]
				$aSort_ByCols = $aTmp4
			Case 5
				Local $aTmp5 = [ [ $aSort_ByCols[0], $aSort_ByCols[1], $aSort_ByCols[2], $aSort_ByCols[3], $aSort_ByCols[4] ] ]
				$aSort_ByCols = $aTmp5
		EndSwitch
	EndIf

	If $iCols = 0 Then $iCols = 1
	Local $iSort_ByCols = UBound( $aSort_ByCols ), $aSort_ByCols2[$iSort_ByCols][5], $bArray = Default, $j = 0
	If UBound( $aSort_ByCols, 2 ) < 5 Then ReDim $aSort_ByCols[$iSort_ByCols][5]
	For $i = 0 To $iSort_ByCols - 1
		; Check column index
		If $aSort_ByCols[$i][0] < 0 Or $aSort_ByCols[$i][0] > $iCols - 1 Then ContinueLoop
		; Check sorting index
		If Not IsArray( $aSort_ByCols[$i][1] ) And Not IsDllStruct( $aSort_ByCols[$i][1] ) Then ContinueLoop
		If IsArray( $aSort_ByCols[$i][1] ) And Not ( UBound( $aSort_ByCols[$i][1], 0 ) = 1 And UBound( $aSort_ByCols[$i][1] ) = $iRows ) Then ContinueLoop
		If IsDllStruct( $aSort_ByCols[$i][1] ) And DllStructGetSize( $aSort_ByCols[$i][1] ) / 4 <> $iRows Then ContinueLoop
		If $bArray = Default Then $bArray = IsArray( $aSort_ByCols[$i][1] )
		; Sorting indexes must be same type: Array or DllStruct
		If $bArray <> IsArray( $aSort_ByCols[$i][1] ) Then ContinueLoop
		; Check asc/desc specifications
		$aSort_ByCols[$i][3] = StringStripWS( $aSort_ByCols[$i][3], 8 ) ; 8 = $STR_STRIPALL
		$aSort_ByCols[$i][4] = StringStripWS( $aSort_ByCols[$i][4], 8 ) ; 8 = $STR_STRIPALL
		If Not ( $aSort_ByCols[$i][3] = "Asc" Or $aSort_ByCols[$i][3] = "Desc" Or $aSort_ByCols[$i][3] = "" ) Then ContinueLoop
		If Not ( $aSort_ByCols[$i][4] = "Asc" Or $aSort_ByCols[$i][4] = "Desc" Or $aSort_ByCols[$i][4] = "" ) Then ContinueLoop
		If $aSort_ByCols[$i][3] = "" Then $aSort_ByCols[$i][3] = $aSort_ByCols[$i][4]
		If $aSort_ByCols[$i][3] = $aSort_ByCols[$i][4] Then $aSort_ByCols[$i][4] = ""
		; Change asc/desc --> 1/2
		If ( $aSort_ByCols[$i][3] = "" And $aSort_ByCols[$i][4] = "" ) Or _
		   ( $aSort_ByCols[$i][3] = "Asc" And $aSort_ByCols[$i][4] = "Desc" ) Then
		     $aSort_ByCols[$i][3] = 1 ; Asc
		     $aSort_ByCols[$i][4] = 2 ; Desc
		ElseIf $aSort_ByCols[$i][3] = "Desc" And $aSort_ByCols[$i][4] = "Asc" Then
		     $aSort_ByCols[$i][3] = 2 ; Desc
		     $aSort_ByCols[$i][4] = 1 ; Asc
		ElseIf $aSort_ByCols[$i][3] = "Asc" Then
		     $aSort_ByCols[$i][3] = 1 ; Asc
		ElseIf $aSort_ByCols[$i][3] = "Desc" Then
		     $aSort_ByCols[$i][3] = 2 ; Desc
		EndIf
		; Store valid rows in $aSort_ByCols2
		$aSort_ByCols2[$j][0] = $aSort_ByCols[$i][0]
		$aSort_ByCols2[$j][1] = $aSort_ByCols[$i][1]
		$aSort_ByCols2[$j][2] = $aSort_ByCols[$i][2]
		$aSort_ByCols2[$j][3] = $aSort_ByCols[$i][3]
		$aSort_ByCols2[$j][4] = $aSort_ByCols[$i][4]
		$j += 1
	Next
	If $j = 0 Then
		Return ""
	Else
		; Check listview header item markup types: Up/down arrows (0), item texts (1), item colors (2)
		$iMarkupType = DataDisplay_CheckMarkupType( StringSplit( $aSort_ByCols2[0][2], "|", 2 )[0] )
		; Store $aSort_ByCols2 in a more convenient array format in $aSort_ByCols3
		Local $aSort_ByCols3[2*$iCols][5] ; 0: Asc/desc = 1/2, 1: Sort index, 2: Current asc/desc,
		For $i = 0 To $j - 1              ;                    3: Hdr info,   4: Hdr info
			Local $aSplit = StringSplit( $aSort_ByCols2[$i][2], "|", 2 ), $iSplit = UBound( $aSplit ) ; 2 = $STR_NOCOUNT
			If $aSort_ByCols2[$i][3] And $aSort_ByCols2[$i][4] And Not $aSort_ByCols3[2*$aSort_ByCols2[$i][0]][0] Then
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][1] = $aSort_ByCols2[$i][1] ; Sort index (only one)
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][0] = $aSort_ByCols2[$i][3] ; First  sort (asc/desc)
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][0] = $aSort_ByCols2[$i][4] ; Second sort (desc/asc)
				If $iMarkupType And $iSplit > 2 Then
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[0] ) Then $iMarkupType = 0
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[1] ) Then $iMarkupType = 0
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[2] ) Then $iMarkupType = 0
					If $iMarkupType Then
						$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][3] = $aSplit[0]
						$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][4] = $aSplit[1]
						$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][4] = $aSplit[2]
					EndIf
				Else
					$iMarkupType = 0
				EndIf
			ElseIf $aSort_ByCols2[$i][3] And Not $aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][0] Then
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][1] = $aSort_ByCols2[$i][1] ; First sort index
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][0] = $aSort_ByCols2[$i][3] ; First sort (asc/desc)
				If $iMarkupType And $iSplit > 1 Then
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[0] ) Then $iMarkupType = 0
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[1] ) Then $iMarkupType = 0
					If $iMarkupType Then
						$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][3] = $aSplit[0]
						$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][4] = $aSplit[1]
					EndIf
				Else
					$iMarkupType = 0
				EndIf
			ElseIf $aSort_ByCols2[$i][3] And $aSort_ByCols2[$i][3] <> $aSort_ByCols3[2*$aSort_ByCols2[$i][0]+0][0] And Not $aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][0] Then
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][1] = $aSort_ByCols2[$i][1] ; Second sort index
				$aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][0] = $aSort_ByCols2[$i][3] ; Second sort (desc/asc)
				If $iMarkupType And $iSplit > 0 Then
					If $iMarkupType And $iMarkupType <> DataDisplay_CheckMarkupType( $aSplit[0] ) Then $iMarkupType = 0
					If $iMarkupType Then $aSort_ByCols3[2*$aSort_ByCols2[$i][0]+1][4] = $aSplit[0]
				Else
					$iMarkupType = 0
				EndIf
			EndIf
		Next
		$iFirstCol = $aSort_ByCols2[0][0]
		$aSort_ByCols = $aSort_ByCols3
		Return $aSort_ByCols2[0][1]
	EndIf
EndFunc

; Check listview header item markup types:
; Up/down arrows (0), item texts (1), item colors (2)
Func DataDisplay_CheckMarkupType( $s )
	If Not $s Then Return 0
	Return ( StringLen( $s ) > 2 And StringLeft( $s, 2 ) = "0x" And StringIsXDigit( StringRight( $s, StringLen( $s ) - 2 ) ) ) ? 2 : 1
EndFunc

Func DataDisplay_SortByColsHdrColors( ByRef $aSort_ByCols, $iFirstCol )
	Local $oHdr_Colors_Dict = ObjCreate( "Scripting.Dictionary" )
	Local $iSort_ByCols = UBound( $aSort_ByCols ), $aHdr_Colors[$iSort_ByCols/2][2], $j = 0
	For $i = 0 To $iSort_ByCols / 2 - 1
		If Not $aSort_ByCols[2*$i][0] Then ContinueLoop
		$aHdr_Colors[$j][0] = $i+1
		$aHdr_Colors[$j][1] = $aSort_ByCols[2*$i][($i=$iFirstCol?4:3)]
		$j += 1
		; Create solid brushes from header colors
		If Not $oHdr_Colors_Dict.Exists( $aSort_ByCols[2*$i][3] ) Then _
			$oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i][3] ) = DllCall( "gdi32.dll", "handle", "CreateSolidBrush", "int", DataDisplay_ColorConvert( $aSort_ByCols[2*$i][3] ) )[0] ; _WinAPI_CreateSolidBrush
		$aSort_ByCols[2*$i][3] = $oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i][3] )
		If Not $oHdr_Colors_Dict.Exists( $aSort_ByCols[2*$i][4] ) Then _
			$oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i][4] ) = DllCall( "gdi32.dll", "handle", "CreateSolidBrush", "int", DataDisplay_ColorConvert( $aSort_ByCols[2*$i][4] ) )[0] ; _WinAPI_CreateSolidBrush
		$aSort_ByCols[2*$i][4] = $oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i][4] )
		If Not $aSort_ByCols[2*$i+1][0] Then ContinueLoop
		If Not $oHdr_Colors_Dict.Exists( $aSort_ByCols[2*$i+1][4] ) Then _
			$oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i+1][4] ) = DllCall( "gdi32.dll", "handle", "CreateSolidBrush", "int", DataDisplay_ColorConvert( $aSort_ByCols[2*$i+1][4] ) )[0] ; _WinAPI_CreateSolidBrush
		$aSort_ByCols[2*$i+1][4] = $oHdr_Colors_Dict.Item( $aSort_ByCols[2*$i+1][4] )
	Next
	ReDim $aHdr_Colors[$j][2]
	Return $aHdr_Colors
EndFunc
