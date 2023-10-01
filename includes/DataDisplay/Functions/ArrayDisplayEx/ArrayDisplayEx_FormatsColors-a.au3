#include-once

; Sort 1d arrays by rows and 2d arrays by rows and columns. Display subitems as formatted text. Draw columns with colored background.

$aDataDisplay_Info0[5] = ArrayDisplayEx_FormatsColors

Func ArrayDisplayEx_FormatsColors( ByRef $hNotifyFunc, $iDimension, ByRef $aSort_Rows, ByRef $aSort_Cols )
	Switch True
		; 2d arrays only: Sorting by columns is only relevant for 2d arrays
		Case $iDimension = 2 And IsDllStruct( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY38 ; Sort rows through struct index and columns through array index, column text formatting, column background colors
		Case $iDimension = 2 And IsArray( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY37 ; Sort rows and columns through array indexes, column text formatting, column background colors
		Case $iDimension = 2 And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY36 ; Sort columns through array index, column text formatting, column background colors
		; 1d and 2d arrays
		Case IsDllStruct( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? _ArrayDisplayEx_WM_NOTIFY34 : _ArrayDisplayEx_WM_NOTIFY35 ; Sort rows through struct index, column text formatting, column background colors
		Case IsArray( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? _ArrayDisplayEx_WM_NOTIFY32 : _ArrayDisplayEx_WM_NOTIFY33 ; Sort rows through array index, column text formatting, column background colors
		Case Else
			$hNotifyFunc = $iDimension = 1 ? _ArrayDisplayEx_WM_NOTIFY30 : _ArrayDisplayEx_WM_NOTIFY31 ; Basic functionality, column text formatting and column background colors
	EndSwitch
EndFunc

; === WM_NOTIFY functions ===

; 1d array, basic functionality, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY30( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aFormats, $iFmtPars, $aColors, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				Switch $aFormats[0][$iFmtPars]
					Case 2
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i] )
					Case 3
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i], $aFormats[0][2] )
					Case 4
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i], $aFormats[0][2], $aFormats[0][3] )
					Case 5
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4] )
					Case 6
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5] )
					Case 7
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$i], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5], $aFormats[0][6] )
				EndSwitch
			Next
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
			$aFormats = 0
			$aColors = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, basic functionality, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY31( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[$i][$j]
					EndIf
				Next
			Next
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through array index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY32( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aColors, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				Switch $aFormats[0][$iFmtPars]
					Case 2
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]] )
					Case 3
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]], $aFormats[0][2] )
					Case 4
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]], $aFormats[0][2], $aFormats[0][3] )
					Case 5
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4] )
					Case 6
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5] )
					Case 7
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5], $aFormats[0][6] )
				EndSwitch
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
			$aFormats = 0
			$aColors = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through array index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY33( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$j]
					EndIf
				Next
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through struct index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY34( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aColors, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				Switch $aFormats[0][$iFmtPars]
					Case 2
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)] )
					Case 3
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)], $aFormats[0][2] )
					Case 4
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)], $aFormats[0][2], $aFormats[0][3] )
					Case 5
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4] )
					Case 6
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5] )
					Case 7
						$aDisplay[$i-$iFrom] = $aFormats[0][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5], $aFormats[0][6] )
				EndSwitch
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
			$aFormats = 0
			$aColors = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY35( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$j]
					EndIf
				Next
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort columns through array index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY36( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aSort_Cols, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$i][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[$i][$aSort_Cols[$j]]
					EndIf
				Next
			Next
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Cols = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows and columns through array indexes, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY37( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aSort_Cols, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[$aSort_Rows[($bDef_Sort?$i:$iRows-$i)]][$aSort_Cols[$j]]
					EndIf
				Next
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$aSort_Rows = 0
			$aSort_Cols = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index and columns through array index, column text formatting, column background colors
Func _ArrayDisplayEx_WM_NOTIFY38( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aSort_Cols, $aFormats, $iFmtPars, $aColors, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$aColors = $aDataDisplay_Info[$iIdx][6]
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
		Case  -12 ; $NM_CUSTOMDRAW
			#include "..\..\Common\WM_NOTIFY_CustomDraw.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam )
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				For $j = 0 To $iColCount - 1
					If $aFormats[$j][0] Then
						Switch $aFormats[$j][$iFmtPars]
							Case 2
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]] )
							Case 3
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]], $aFormats[$j][2] )
							Case 4
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3] )
							Case 5
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4] )
							Case 6
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5] )
							Case 7
								$aDisplay[$i-$iFrom][$j] = $aFormats[$j][1]( $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]], $aFormats[$j][2], $aFormats[$j][3], $aFormats[$j][4], $aFormats[$j][5], $aFormats[$j][6] )
						EndSwitch
					Else
						$aDisplay[$i-$iFrom][$j] = $aArray[DllStructGetData($tSort_Rows,1,$bDef_Sort?$i+1:$iRows-$i)][$aSort_Cols[$j]]
					EndIf
				Next
			Next
			Return
		Case -108 ; $LVN_COLUMNCLICK
			If Not Mod( $aDataDisplay_Info[$iIdx][15], 3 ) Then _
				$aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
		Case 0
			$iIdx = 0
			$aArray = 0
			$tSort_Rows = 0
			$aSort_Cols = 0
			$aFormats = 0
			$aColors = 0
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc
