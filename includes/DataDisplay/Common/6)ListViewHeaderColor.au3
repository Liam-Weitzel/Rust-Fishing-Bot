
Local $oHdr_Colors_Dict, $hListView, $pHeaderColor
If IsArray( $aHdr_Colors ) And IsArray( $aHdr_Info ) Then
	; Default Header item color
	Local $iDef_Hdr_Color = -1
	Local $iHdr_Colors = UBound( $aHdr_Colors )
	For $i = 0 To $iHdr_Colors - 1
		If $aHdr_Colors[$i][0] = -1 Then ExitLoop
	Next
	If $i < $iHdr_Colors And $aHdr_Colors[$i][1] And Not BitAND( $aHdr_Colors[$i][1], 0xFF000000 ) Then $iDef_Hdr_Color = $aHdr_Colors[$i][1]
	; Set default Header color for all items
	For $i = 0 To $iColCount + ($iColCount=0)
		$aHdr_Info[$i][2] = $iDef_Hdr_Color
	Next
	; Get Header item colors
	For $i = 0 To $iHdr_Colors - 1
		Switch $aHdr_Colors[$i][0]
			Case 0 To $iColCount + ($iColCount=0)
				If $aHdr_Colors[$i][1] <> -1 And ( Not $aHdr_Colors[$i][1] Or BitAND( $aHdr_Colors[$i][1], 0xFF000000 ) ) Then ContinueLoop
				$aHdr_Info[$aHdr_Colors[$i][0]][2] = $aHdr_Colors[$i][1]
		EndSwitch
	Next
	If $i1dColumns Then
		; Display 1d array in multiple columns
		; Set Header item colors for items 2 to $i1dColumns
		For $i = 2 To $i1dColumns ; $i is the Header item index
			$aHdr_Info[$i][2] = $aHdr_Info[1][2]
		Next
	EndIf
	; Create solid brushes from Header item colors
	$oHdr_Colors_Dict = ObjCreate( "Scripting.Dictionary" )
	For $i = 0 To $iColCount + ($iColCount=0)
		If $aHdr_Info[$i][2] = -1 Then ContinueLoop
		If Not $oHdr_Colors_Dict.Exists( $aHdr_Info[$i][2] ) Then _
			$oHdr_Colors_Dict.Item( $aHdr_Info[$i][2] ) = DllCall( "gdi32.dll", "handle", "CreateSolidBrush", "int", DataDisplay_ColorConvert( $aHdr_Info[$i][2] ) )[0] ; _WinAPI_CreateSolidBrush
		$aHdr_Info[$i][2] = $oHdr_Colors_Dict.Item( $aHdr_Info[$i][2] )
	Next
	If $i1dColumns Then
		; Display 1d array in multiple columns
		; Set solid brushes for Header items 2 to $i1dColumns
		For $i = 2 To $i1dColumns ; $i is the Header item index
			$aHdr_Info[$i][2] = $aHdr_Info[1][2]
		Next
	EndIf
	; ListView handle
	$hListView = GUICtrlGetHandle( $idListView )
	; Register callback function to subclass ListView and draw Header colors
	$pHeaderColor = DllCallbackGetPtr( DllCallbackRegister( "DataDisplay_HeaderColor", "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr" ) )
	DllCall( "comctl32.dll", "bool", "SetWindowSubclass", "hwnd", $hListView, "ptr", $pHeaderColor, "uint_ptr", 9999, "dword_ptr", $hHeader ) ; $iSubclassId = 9999, $pData = $hHeader
	; Initialize callback function
	DataDisplay_HeaderColor( $hHeader, 0x004E, $aHdr_Info, 0, -1, 0 ) ; $iMsg = 0x004E = $WM_NOTIFY, $wParam = $aHdr_Info, $iSubclassId = -1
	Local $aTmp = [ $hListView, $pHeaderColor, $oHdr_Colors_Dict ]
	$aDataDisplay_Info[$iIdx][16] = $aTmp
	$aTmp = 0
EndIf

; This section is added to draw column colors correctly in the row number column
; The row number column is drawn with post paint code in WM_NOTIFY_CustomDraw.au3
If ( Not IsArray( $aHdr_Info ) And $aHdr_Info == "" ) Or ( IsArray( $aHdr_Info ) And $aHdr_Info[0][1] == "" ) Then
	Local $tColumn2 = DllStructCreate( "uint Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order;int cxMin;int cxDefault;int cxIdeal" )
	DllStructSetData( $tColumn2, "Mask", $LVCF_FMT )
	GUICtrlSendMsg( $idListView, $LVM_GETCOLUMNW, 0, DllStructGetPtr( $tColumn2 ) )
	Local $iAlign2 = BitAND( $tColumn2.Fmt, $LVCFMT_JUSTIFYMASK )
	$iAlign2 = $iAlign2 ? $iAlign2 = 2 ? 1 : 2 : 0
	If Not IsArray( $aHdr_Info ) Then $aHdr_Info = $iAlign2
	If IsArray( $aHdr_Info ) Then $aHdr_Info[0][1] = $iAlign2
EndIf
