
; Separator handling
Local $sSeparator = "|"
; Split custom header on separator
Local $aTmp = StringSplit($sHeader, $sSeparator, 2) ; No count element
If UBound($aTmp) = 0 Then Local $aTmp[1] = [""]
$sHeader = "Row"
Local $iIndex = 0
; Create custom header with available items
If $aTmp[0] Then
	; Set as many as available
	For $iIndex = 0 To $iColCount - 1 + ($iColCount=0)
		; Check custom header available
		If $iIndex >= UBound($aTmp) Then ExitLoop
		$sHeader &= $sSeparator & $aTmp[$iIndex]
	Next
EndIf
; Add default headers to fill to end
For $j = $iIndex To $iDimension = 2 ? $iColCount - 1 : 0
	$sHeader &= $sSeparator & "Col " & $j
Next
; Header background colors
If IsArray( $aHdr_Info ) Then
	; Header background colors, header texts
	$aTmp = StringSplit($sHeader, $sSeparator, 2)
	For $i = 0 To UBound($aTmp) - 1
		$aHdr_Info[$i][0] = $aTmp[$i]
	Next
EndIf