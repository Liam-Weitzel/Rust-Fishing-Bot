#include-once

; Sort 1d arrays by rows and 2d arrays by rows and columns. Display subitems as formatted text.

$aDataDisplay_Info0[3] = ArrayDisplayEx_ColumnFormats

Func ArrayDisplayEx_ColumnFormats( ByRef $hNotifyFunc, $iDimension, $i1dColumns, ByRef $aSort_Rows, ByRef $aSort_Cols )
	Switch True
		; 2d arrays only: Sorting by columns is only relevant for 2d arrays
		Case $iDimension = 2 And IsDllStruct( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY18 ; Sort rows through struct index and columns through array index, column text formatting
		Case $iDimension = 2 And IsArray( $aSort_Rows ) And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY17 ; Sort rows and columns through array indexes, column text formatting
		Case $iDimension = 2 And IsArray( $aSort_Cols )
			$hNotifyFunc = _ArrayDisplayEx_WM_NOTIFY16 ; Sort columns through array index, column text formatting
		; 1d and 2d arrays
		Case IsDllStruct( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? _ArrayDisplayEx_WM_NOTIFY14 : _ArrayDisplayEx_WM_NOTIFY15 ; Sort rows through struct index, column text formatting
		Case IsArray( $aSort_Rows )
			$hNotifyFunc = $iDimension = 1 ? $i1dColumns = 0 ? _ArrayDisplayEx_WM_NOTIFY12 : _ArrayDisplayEx_WM_NOTIFY12_Cols : _ArrayDisplayEx_WM_NOTIFY13 ; Sort rows through array index, column text formatting
		Case Else
			$hNotifyFunc = $iDimension = 1 ? $i1dColumns = 0 ? _ArrayDisplayEx_WM_NOTIFY10 : _ArrayDisplayEx_WM_NOTIFY10_Cols : _ArrayDisplayEx_WM_NOTIFY11 ; Basic functionality and column text formatting
	EndSwitch
EndFunc

; === WM_NOTIFY functions ===

; 1d array, basic functionality, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY10( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aFormats, $iFmtPars, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
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
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, basic functionality, column text formatting, display array in multiple columns
Func _ArrayDisplayEx_WM_NOTIFY10_Cols( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aFormats, $iFmtPars, $aDisplay[100], $iFrom, $iTo, $i1dColumns, $iRowCount

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$i1dColumns = $aDataDisplay_Info[$iIdx][12]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iRowCount = UBound( $aArray ) - 1
		ReDim $aDisplay[100][$i1dColumns]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1dCols.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam ), $j, $i1dCols
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				$j = $i * $i1dColumns
				$i1dCols = $j + $i1dColumns - 1 > $iRowCount ? $iRowCount - $j : $i1dColumns - 1
				For $k = $i1dCols + 1 To $i1dColumns - 1
					$aDisplay[$i-$iFrom][$k] = ""
				Next
				Switch $aFormats[0][$iFmtPars]
					Case 2
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k] )
						Next
					Case 3
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k], $aFormats[0][2] )
						Next
					Case 4
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k], $aFormats[0][2], $aFormats[0][3] )
						Next
					Case 5
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4] )
						Next
					Case 6
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5] )
						Next
					Case 7
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$j+$k], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5], $aFormats[0][6] )
						Next
				EndSwitch
			Next
			Return
		Case 0
			$iIdx = 0
			$aArray = 0
			$aFormats = 0
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, basic functionality, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY11( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through array index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY12( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
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
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through array index, column text formatting, display array in multiple columns
Func _ArrayDisplayEx_WM_NOTIFY12_Cols( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aDisplay[100], $iFrom, $iTo, $i1dColumns

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$i1dColumns = $aDataDisplay_Info[$iIdx][12]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		ReDim $aDisplay[100][$i1dColumns]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1dCols.au3"
		Case -113 ; $LVN_ODCACHEHINT
			Local $tNMLVCACHEHINT = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int iFrom;int iTo", $lParam ), $j, $i1dCols
			$iFrom = DllStructGetData( $tNMLVCACHEHINT, "iFrom" )
			$iTo = DllStructGetData( $tNMLVCACHEHINT, "iTo" )
			For $i = $iFrom To $iTo
				$j = $i * $i1dColumns
				$i1dCols = $j + $i1dColumns - 1 > $iRows ? $iRows - $j : $i1dColumns - 1
				For $k = $i1dCols + 1 To $i1dColumns - 1
					$aDisplay[$i-$iFrom][$k] = ""
				Next
				Switch $aFormats[0][$iFmtPars]
					Case 2
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]] )
						Next
					Case 3
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]], $aFormats[0][2] )
						Next
					Case 4
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]], $aFormats[0][2], $aFormats[0][3] )
						Next
					Case 5
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4] )
						Next
					Case 6
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5] )
						Next
					Case 7
						For $k = 0 To $i1dCols
							$aDisplay[$i-$iFrom][$k] = $aFormats[0][1]( $aArray[$aSort_Rows[($bDef_Sort?$j+$k:$iRows-$j-$k)]], $aFormats[0][2], $aFormats[0][3], $aFormats[0][4], $aFormats[0][5], $aFormats[0][6] )
						Next
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
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through array index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY13( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 1d array, sort rows through struct index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY14( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $aDisplay[100], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData1d.au3"
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
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY15( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort columns through array index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY16( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $aSort_Cols, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows and columns through array indexes, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY17( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $aSort_Rows, $bDef_Sort, $aSort_Cols, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$aSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray ) - 1
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc

; 2d array, sort rows through struct index and columns through array index, column text formatting
Func _ArrayDisplayEx_WM_NOTIFY18( $hWnd, $iMsg, $wParam, $lParam, $iIndex, $pData )
	If $iMsg <> 0x004E Then Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0] ; 0x004E = $WM_NOTIFY
	Local Static $tText = DllStructCreate( "wchar[4094]" ), $pText = DllStructGetPtr( $tText ), $iIdx = 0, $aArray, $iRows, $tSort_Rows, $bDef_Sort, $aSort_Cols, $aFormats, $iFmtPars, $iColCount, $aDisplay[1][1], $iFrom, $iTo

	If $iIdx <> $iIndex Then ; Get data from $aDataDisplay_Info
		$iIdx = $iIndex
		$aArray = $aDataDisplay_Info[$iIdx][0]
		$tSort_Rows = $aDataDisplay_Info[$iIdx][3]
		$bDef_Sort = 1 - $aDataDisplay_Info[$iIdx][9] ; 1 - $bSort_Reverse
		$aSort_Cols = $aDataDisplay_Info[$iIdx][4]
		$aFormats = $aDataDisplay_Info[$iIdx][5]
		$iFmtPars = UBound( $aFormats, 2 ) - 1
		$iColCount = UBound( $aFormats )
		ReDim $aDisplay[100][$iColCount]
		$iRows = UBound( $aArray )
	EndIf

	Switch DllStructGetData( DllStructCreate( "struct; hwnd hWndFrom;uint_ptr IDFrom;int Code; endstruct", $lParam ), "Code" )
		Case -177 ; $LVN_GETDISPINFOW
			#include "..\..\Common\WM_NOTIFY_DisplayData2d.au3"
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
			ReDim $aDisplay[1][1]
	EndSwitch

	Return DllCall( "comctl32.dll", "lresult", "DefSubclassProc", "hwnd", $hWnd, "uint", $iMsg, "wparam", $wParam, "lparam", $lParam )[0]
	#forceref $pData
EndFunc
