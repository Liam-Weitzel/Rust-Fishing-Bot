
; _ArrayDisplayEx - Displays a 1d or 2d array in a virtual ListView

#include-once
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <StructureConstants.au3>
#include <ListViewConstants.au3>
#include <HeaderConstants.au3>
#include <StaticConstants.au3>

; Project includes
#include "..\..\Common\0)GlobalArray.au3"  ; Global array definition
#include "..\..\Common\a)FeatureCheck.au3" ; Features utility functions
#include "..\..\Common\b)FeatureFuncs.au3"
#include "ArrayDisplayEx_BasicFuncs.au3"   ; Basic display functionality
#include "Internal\z)CleanupCode.au3"      ; Cleanup and release memory

; #FUNCTION# ====================================================================================================================
; Author ........: randallc, Ultima
; Modified.......: Gary Frost (gafrost), Ultima, Zedna, jpm, Melba23, AZJIO, UEZ
; ===============================================================================================================================
; Displays a 1d or 2d array in a virtual ListView
Func _ArrayDisplayEx( _
	$aArray, _          ; 1d/2d array eg. StringSplit("Mo,Tu,We,Th,Fr,Sa,Su", ",")
	$sTitle = "", _     ; GUI title bar text, default title is set to "ArrayDisplayEx"
	$sHeader = "", _    ; ListView header column names, default is "Col0|Col1|Col2|...|ColN"
	$iFlags = 0x0000, _ ; Set additional options through flag values
	$aFeatures = "" )   ; 2d array of feature type/info pairs

	; $iFlags values
	; Add required values together
	; 0x0000 => Left aligned text
	; 0x0002 => Right aligned text
	; 0x0004 => Centered text
	; 0x0008 => Verbose mode
	; 0x0010 => Half-height ListView
	; 0x0020 => No grid lines in ListView

	; $aFeatures parameter
	; Features available in _ArrayDisplayEx:
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
	;
	;   Debugging features:                                        ; Include file:
	;     "DataTypes"   => Data types info                         ; <Display function>_DataTypesInfo.au3
	;
	; See DisplayFeatures.txt for docu of features

	; Error codes in @error
	; 1 => No array variable passed to function
	; 2 => Larger than 2d array passed to function
	; 3 => Missing include file
	; 4 => Unsupported feature
	; 6 => Too many GUIs

	; Default values
	If $sTitle    = "" Then $sTitle = "ArrayDisplayEx"
	If $sTitle    = Default Then $sTitle = "ArrayDisplayEx"
	If $sHeader   = Default Then $sHeader = ""
	If $iFlags    = Default Then $iFlags = 0x0000
	If $aFeatures = Default Then $aFeatures = ""

	; Default features
	Local $aAlignment = "", $aMin_ColWidth = 55, $iMax_ColWidth = 350
	Local $aColumn_Formats = "", $aColumn_Colors = "", $iLvBackColor = 0xFFFFFF
	Local $aSort_Rows = "", $aSort_Cols = "", $aSort_ByCols = "", $i1dColumns = 0
	Local $aHdr_Colors = "", $aHdr_Info = "", $hUser_Function = 0

	; Check functionality required through flags
	Local $iColAlign    = BitAND( $iFlags, 0x0006 ) ; 0x0000 = Left ( default ); 0x0002 = Right; 0x0004 = Center
	Local $bVerbose     = BitAND( $iFlags, 0x0008 ) ; Verbose mode, shows a MsgBox with buttons to exit or continue on errors
	Local $bHalfHeight  = BitAND( $iFlags, 0x0010 ) ; Provides better performance for comprehensive WM_NOTIFY message handler code
	Local $bNoGridLines = BitAND( $iFlags, 0x0020 ) ; No grid lines in the ListView, default is to show grid lines
	If $iColAlign = 6 Then $iColAlign = 0

	Local $sMbTitle = $sTitle = "ArrayDisplayEx" ? "ArrayDisplayEx Error" : "ArrayDisplayEx Error: " & $sTitle

	; $aFeatures 2d array with 2 columns
	If IsArray( $aFeatures ) Then $aFeatures = DataDisplay_CheckArray( $aFeatures, 2 )

	; Check data source
	#include "Internal\0)CheckDataSource.au3"

	; Check $aFeatures array and include files
	Local $sDataDisplay_Func = "ArrayDisplayEx"
	#include "..\..\Common\1)CheckFeatures.au3"

	; Create label data
	Local $sLabelData = "[" & StringRegExpReplace( $iRowCount, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]"
	If $iDimension = 2 Then	$sLabelData &= " [" & $iColCount & "]"

	; ListView header
	#include "..\..\Common\2)ListViewHeader.au3"

	; Set coord mode 1
	Local $iCoordMode = Opt("GUICoordMode", 1)

	; Create AutoIt GUI
	; $iIdx is calculated at bottom of this code
	#include "..\..\Common\4)CreateAutoItGUI.au3"

	; Align columns if required
	; Mark header items for sort by mult columns
	#include "..\..\Common\5)ListViewAlignColumns.au3"

	; Header background color
	#include "..\..\Common\6)ListViewHeaderColor.au3"

	; Store variables for includes
	$aDataDisplay_Info[$iIdx][ 0] = $aArray
	$aDataDisplay_Info[$iIdx][ 3] = $aSort_Rows
	$aDataDisplay_Info[$iIdx][ 4] = $aSort_Cols
	$aDataDisplay_Info[$iIdx][ 5] = $aColumn_Formats
	$aDataDisplay_Info[$iIdx][ 6] = $aColumn_Colors
	$aDataDisplay_Info[$iIdx][ 9] = 0 ; $bSort_Reverse
	$aDataDisplay_Info[$iIdx][12] = $i1dColumns
	;$aDataDisplay_Info[$iIdx][13] = $aHdr_Info
	$aArray = 0

	; Register WM_NOTIFY message handler through subclassing
	Local $pNotifyFunc = DllCallbackGetPtr( DllCallbackRegister( FuncName( $hNotifyFunc ), "lresult", "hwnd;uint;wparam;lparam;uint_ptr;dword_ptr" ) )
	DllCall( "comctl32.dll", "bool", "SetWindowSubclass", "hwnd", $hGUI, "ptr", $pNotifyFunc, "uint_ptr", $iIdx, "dword_ptr", 0 ) ; $iSubclassId = $iIdx, $pData = 0
	$aDataDisplay_Info[$iIdx][1] = $hNotifyFunc
	$aDataDisplay_Info[$iIdx][2] = $pNotifyFunc

	; Initialize local static ListView memory
	$hNotifyFunc( 0, 0x004E, 0, 0, $iIdx, 0 ) ; 0x004E = $WM_NOTIFY

	; Initialize virtual ListView by setting number of rows
	Local $i1dRows = $i1dColumns ? ( Mod( $iRowCount, $i1dColumns ) > 0 ) + ( $iRowCount - Mod( $iRowCount, $i1dColumns ) ) / $i1dColumns : 0
	GUICtrlSendMsg( $idListView, $LVM_SETITEMCOUNT, $i1dRows ? $i1dRows : $iRowCount, 0 )

	; ListView column widths and GUI width
	#include "..\..\Common\7)ListViewGuiWidth.au3"

	; ListView height and GUI height
	#include "..\..\Common\8)ListViewGuiHeight.au3"

	; Display and resize dialog
	GUISetState(@SW_HIDE, $hGUI)
	WinMove($hGUI, "", (@DesktopWidth - $iWidth) / 2, (@DesktopHeight - $iHeight) / 2, $iWidth, $iHeight-4) ; -$WS_EX_CLIENTEDGE => -4
	GUISetState(@SW_SHOW, $hGUI)

	; Switch to GetMessage mode
	Local $iOnEventMode = Opt("GUIOnEventMode", 0)

	; Loop and message handler
	$aDataDisplay_Info[$iIdx][17] = ArrayDisplay_Cleanup
	#include "..\..\Common\9)MessageLoop.au3"

	; Reset GUI options
	Opt("GUICoordMode", $iCoordMode) ; Reset original Coord mode
	Opt("GUIOnEventMode", $iOnEventMode) ; Reset original GUI mode
	Opt("GUIDataSeparatorChar", $sCurr_Separator) ; Reset original separator

	Return 1
EndFunc
