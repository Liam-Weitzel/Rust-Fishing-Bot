#include-once

; Sort 1d arrays by rows and 2d arrays by rows and columns

$aDataDisplay_Info0[2] = ArrayDisplayEx_SortFuncs

Func ArrayDisplayEx_SortFuncs( ByRef $hNotifyFunc, $iDimension, $i1dColumns, ByRef $aSort_Rows, ByRef $aSort_Cols )
	Switch True
		; 2d arrays only: Sorting by columns is only relevant for 2d arrays
		Case $iDimension = 2 And IsDllStruct( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY8 ; Sort rows through struct index and columns through array index
		Case $iDimension = 2 And IsArray( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY7 ; Sort rows and columns through array indexes
		Case $iDimension = 2 And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY6 ; Sort columns through array index
		; 1d and 2d arrays
		Case IsDllStruct( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? $i1dColumns = 0 ? _ArrayDisplayEx_WM_NOTIFY4 : _ArrayDisplayEx_WM_NOTIFY4_Cols : _ArrayDisplayEx_WM_NOTIFY5 ; Sort rows through struct index
		Case IsArray( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? $i1dColumns = 0 ? _ArrayDisplayEx_WM_NOTIFY2 : _ArrayDisplayEx_WM_NOTIFY2_Cols : _ArrayDisplayEx_WM_NOTIFY3 ; Sort rows through array index
	EndSwitch
EndFunc

; === WM_NOTIFY functions ===

; 1d array, sort rows through array index
Func _ArrayDisplayEx_WM_NOTIFY2( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			DllStructSetData( $tText, 1, DllStructGetData($tNMLVDISPINFO,"SubItem") ? $aArray[($bDef_Sort?$aSort_Rows[DllStructGetData($tNMLVDISPINFO,"Item")]:$aSort_Rows[$iRows-DllStructGetData($tNMLVDISPINFO,"Item")])] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through array index, display array in multiple columns
Func _ArrayDisplayEx_WM_NOTIFY2_Cols( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $i1dColumns, $iRowCount

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$i1dColumns = $aDataDisplay_Info[$iIdx][12]
		$iRowCount = UBound( $aArray )
		$iRows = $iRowCount - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iItem = DllStructGetData($tNMLVDISPINFO,"Item"), $iItem0 = $iItem * $i1dColumns, $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			If $iItem0 + $iSubItem > $iRowCount Then Return
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?$aSort_Rows[$iItem0+$iSubItem-1]:$aSort_Rows[$iRows-($iItem0+$iSubItem-1)])] : "[" & StringRegExpReplace( $iItem0, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through array index
Func _ArrayDisplayEx_WM_NOTIFY3( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?$aSort_Rows[DllStructGetData($tNMLVDISPINFO,"Item")]:$aSort_Rows[$iRows-DllStructGetData($tNMLVDISPINFO,"Item")])][$iSubItem-1] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through struct index
Func _ArrayDisplayEx_WM_NOTIFY4( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			DllStructSetData( $tText, 1, DllStructGetData($tNMLVDISPINFO,"SubItem") ? $aArray[($bDef_Sort?DllStructGetData($tSort_Rows,1,DllStructGetData($tNMLVDISPINFO,"Item")+1):DllStructGetData($tSort_Rows,1,$iRows-DllStructGetData($tNMLVDISPINFO,"Item")))] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through struct index, display array in multiple columns
Func _ArrayDisplayEx_WM_NOTIFY4_Cols( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $i1dColumns

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$i1dColumns = $aDataDisplay_Info[$iIdx][12]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iItem = DllStructGetData($tNMLVDISPINFO,"Item"), $iItem0 = $iItem * $i1dColumns, $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			If $iItem0 + $iSubItem > $iRows Then Return
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?DllStructGetData($tSort_Rows,1,$iItem0+$iSubItem):DllStructGetData($tSort_Rows,1,$iRows-$iItem0-$iSubItem+1))] : "[" & StringRegExpReplace( $iItem0, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index
Func _ArrayDisplayEx_WM_NOTIFY5( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?DllStructGetData($tSort_Rows,1,DllStructGetData($tNMLVDISPINFO,"Item")+1):$iRows-DllStructGetData($tSort_Rows,1,DllStructGetData($tNMLVDISPINFO,"Item")+1))][$iSubItem-1] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort columns through array index
Func _ArrayDisplayEx_WM_NOTIFY6( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aSort_Cols

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[DllStructGetData($tNMLVDISPINFO,"Item")][$aSort_Cols[$iSubItem-1]] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Cols = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows and columns through array indexes
Func _ArrayDisplayEx_WM_NOTIFY7( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aSort_Cols

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?$aSort_Rows[DllStructGetData($tNMLVDISPINFO,"Item")]:$aSort_Rows[$iRows-DllStructGetData($tNMLVDISPINFO,"Item")])][$aSort_Cols[$iSubItem-1]] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
			$aSort_Cols = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index and columns through array index
Func _ArrayDisplayEx_WM_NOTIFY8( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aSort_Cols

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[($bDef_Sort?DllStructGetData($tSort_Rows,1,DllStructGetData($tNMLVDISPINFO,"Item")+1):$iRows-DllStructGetData($tSort_Rows,1,DllStructGetData($tNMLVDISPINFO,"Item")+1))][$aSort_Cols[$iSubItem-1]] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
			$aSort_Cols = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc
