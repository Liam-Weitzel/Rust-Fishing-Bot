
; Separator handling
Local $sAD_Separator = ChrW(0xFAB1)
; Set separator to use in this UDF and store existing one
Local $sCurr_Separator = Opt("GUIDataSeparatorChar", $sAD_Separator)
; Create custom header with available items
Local $aTmp, $iTmp, $iIdx
If $sHeader Then
	$aTmp = StringSplit($sHeader, $sCurr_Separator, 2)
	$iTmp = UBound($aTmp)
	$sHeader = $aTmp[0]
	For $iIdx = 1 To $iColCount + ($iColCount=0)
		If $iIdx = $iTmp Then ExitLoop
		$sHeader &= $sAD_Separator & $aTmp[$iIdx]
	Next
Else
	$sHeader = "Row"
	$iIdx = 1
EndIf
; Add default headers to fill to end
For $j = $iIdx To $iColCount + ($iColCount=0)
	$sHeader &= $sAD_Separator & "Col " & $j-1
Next
If $i1dColumns Then
	; Display 1d array in multiple columns
	; Set listview column headers for columns 2 to $i1dColumns
	$aTmp = StringSplit($sHeader, $sAD_Separator, 2) ; No count element
	ReDim $aTmp[$i1dColumns+1]
	For $k = $j To $i1dColumns
		$sHeader &= $sAD_Separator & $aTmp[1]
	Next
EndIf
; Header background colors
If IsArray( $aHdr_Info ) Then
	; Header background colors, header texts
	$aTmp = StringSplit($sHeader, $sAD_Separator, 2)
	If $i1dColumns Then ReDim $aHdr_Info[$i1dColumns+1][3]
	For $i = 0 To UBound($aTmp) - 1
		$aHdr_Info[$i][0] = $aTmp[$i]
	Next
EndIf