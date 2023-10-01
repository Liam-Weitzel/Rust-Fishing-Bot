#include-once

; Implements basic functionality: Displays a 1d or 2d array in a virtual listview.

$aDataDisplay_Info0[1] = ArrayDisplayEx_BasicFuncs

Func ArrayDisplayEx_BasicFuncs( ByRef $hNotifyFunc, $iDimension, $i1dColumns )
	Switch $iDimension
		Case 1
			$hNotifyFunc = $i1dColumns = 0 ? _ArrayDisplayEx_WM_NOTIFY0 : _ArrayDisplayEx_WM_NOTIFY0_Cols
		Case 2
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY1
	EndSwitch
EndFunc

; === WM_NOTIFY functions ===

; 1d array, basic functionality
Func _ArrayDisplayEx_WM_NOTIFY0( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			DllStructSetData( $tText, 1, DllStructGetData($tNMLVDISPINFO,"SubItem") ? $aArray[DllStructGetData($tNMLVDISPINFO,"Item")] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, basic functionality, display array in multiple columns
Func _ArrayDisplayEx_WM_NOTIFY0_Cols( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $i1dColumns, $iRowCount

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$i1dColumns = $aDataDisplay_Info[$iIdx][12]
		$iRowCount = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tag
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iItem0 = DllStructGetData($tNMLVDISPINFO,"Item") * $i1dColumns, $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			If $iItem0 + $iSubItem > $iRowCount Then Return
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[$iItem0+$iSubItem-1] : "[" & StringRegExpReplace( $iItem0, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, basic functionality
Func _ArrayDisplayEx_WM_NOTIFY1( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
			If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
			Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
			DllStructSetData( $tText, 1, $iSubItem ? $aArray[DllStructGetData($tNMLVDISPINFO,"Item")][$iSubItem-1] : "[" & StringRegExpReplace( DllStructGetData($tNMLVDISPINFO,"Item"), "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
			DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc
