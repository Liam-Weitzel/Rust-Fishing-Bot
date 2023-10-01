
; Get row height
Local $tRECT = DllStructCreate("struct; long Left;long Top;long Right;long Bottom; endstruct"), $pRECT = DllStructGetPtr( $tRECT ) ; $tagRECT
GUICtrlSendMsg( $idListView, $LVM_GETITEMRECT, 0, $pRECT )
; Set required GUI height
Local $aiWin_Pos = WinGetPos($hGUI)
Local $aiLV_Pos = ControlGetPos($hGUI, "", $idListView)
$iHeight = (($i1dRows ? $i1dRows : $iRowCount) + 2) * (DllStructGetData($tRECT, "Bottom") - DllStructGetData($tRECT, "Top")) + $aiWin_Pos[3] - $aiLV_Pos[3]
; Check min/max height
If $bHalfHeight And $iHeight > @DesktopHeight / 2 Then
	$iHeight = @DesktopHeight / 2 + 2
ElseIf $iHeight > @DesktopHeight - 100 Then
	$iHeight = @DesktopHeight - 100
ElseIf $iHeight < $iMinSize Then
	$iHeight = $iMinSize
EndIf
