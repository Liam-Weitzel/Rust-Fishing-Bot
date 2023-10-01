#include-once

Global $aDataDisplay_Info0[100] ; 100 elements for general info

Global $aDataDisplay_Info[11][50] ; 10 rows for data display GUIs, row 0 not used
$aDataDisplay_Info0[20] =  0 ; Current number of data display GUIs
$aDataDisplay_Info0[21] = 10 ; Max number of data display GUIs

; Remove all subclasses on exit
OnAutoItExitRegister( "DataDisplay_Exit" )

; Remove subclasses on exit
Func DataDisplay_Exit()
	For $i = 1 To $aDataDisplay_Info0[21]
		If $aDataDisplay_Info[$i][20] Then                   ; Remove WM_NOTIFY message handler used to fill the virtual listview
			DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$i][21], "ptr", $aDataDisplay_Info[$i][2], "uint_ptr", $i ) ; WM_NOTIFY
			If Not Mod( $aDataDisplay_Info[$i][15], 3 ) Then _ ; Remove WM_COMMAND, WM_SYSCOMMAND message handler (DataDisplayMult_MsgHandler) used to handle events from multiple concurrent and responsive GUIs
				DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$i][21], "ptr", $aDataDisplay_Info[$i][40], "uint_ptr", $i ) ; WM_COMMAND, WM_SYSCOMMAND
			If Mod( $aDataDisplay_Info[$i][15], 3 ) = 2 Then _ ; Remove WM_COMMAND message handler (DataDisplayCtrl_WM_COMMAND) used to handle events from embedded GUI controls
				DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aDataDisplay_Info[$i][21], "ptr", $aDataDisplay_Info[$i][18], "uint_ptr", $i ) ; WM_COMMAND
			If IsArray( $aDataDisplay_Info[$i][16] ) Then      ; Remove WM_NOTIFY message handler (DataDisplay_HeaderColor) used to draw colors in listview header items
				Local $aTmp = $aDataDisplay_Info[$i][16] ; [ $hListView, $pHeaderColor, $oHdr_Colors_Dict ]
				DllCall( "comctl32.dll", "bool", "RemoveWindowSubclass", "hwnd", $aTmp[0], "ptr", $aTmp[1], "uint_ptr", 9999 ) ; ListView WM_NOTIFY
			EndIf
		EndIf
	Next
EndFunc


; --- General info stored in row index 0 ---

; $aDataDisplay_Info0[01] = ArrayDisplayEx_BasicFuncs         ; WM_NOTIFY message handlers
; $aDataDisplay_Info0[02] = ArrayDisplayEx_SortFuncs          ; Column offset = 00
; $aDataDisplay_Info0[03] = ArrayDisplayEx_ColumnFormats
; $aDataDisplay_Info0[04] = ArrayDisplayEx_ColumnColors
; $aDataDisplay_Info0[05] = ArrayDisplayEx_FormatsColors
; $aDataDisplay_Info0[06] = ArrayDisplayEx_DataTypesInfo
; $aDataDisplay_Info0[07] = _ArrayDisplayMult

; $aDataDisplay_Info0[11] = CSVfileDisplay_BasicFuncs         ; Column offset = 10
; $aDataDisplay_Info0[12] = CSVfileDisplay_SortFuncs
; $aDataDisplay_Info0[13] = CSVfileDisplay_ColumnFormats
; $aDataDisplay_Info0[14] = CSVfileDisplay_ColumnColors
; $aDataDisplay_Info0[15] = CSVfileDisplay_FormatsColors

; $aDataDisplay_Info0[31] = SafeArrayDisplay_BasicFuncs       ; Column offset = 30
; $aDataDisplay_Info0[32] = SafeArrayDisplay_SortFuncs
; $aDataDisplay_Info0[33] = SafeArrayDisplay_ColumnFormats
; $aDataDisplay_Info0[34] = SafeArrayDisplay_ColumnColors
; $aDataDisplay_Info0[35] = SafeArrayDisplay_FormatsColors
; $aDataDisplay_Info0[36] = SafeArrayDisplay_DataTypesInfo
; $aDataDisplay_Info0[37] = SafeArrayDisplayMult

; $aDataDisplay_Info0[41] = SQLiteDisplay_BasicFuncs          ; Column offset = 40
; $aDataDisplay_Info0[42] = SQLiteDisplay_SortFuncs
; $aDataDisplay_Info0[43] = SQLiteDisplay_ColumnFormats
; $aDataDisplay_Info0[44] = SQLiteDisplay_ColumnColors
; $aDataDisplay_Info0[45] = SQLiteDisplay_FormatsColors

; $aDataDisplay_Info0[22] = $iIdx ; $idTabKey event           ; Events from multiple concurrent and responsive GUIs
; $aDataDisplay_Info0[23] = $iIdx ; $idShiftTab event
; $aDataDisplay_Info0[24] = $iIdx ; $idGoto focus event
; $aDataDisplay_Info0[25] = $iIdx ; $idGoto click event
; $aDataDisplay_Info0[26] = $iIdx ; $idFunc click event
; $aDataDisplay_Info0[27] = $iIdx ; $idExit click event
; $aDataDisplay_Info0[28] = $iIdx ; GUI close event

; $aDataDisplay_Info0[29] = $iIdx ; $idListView column header click event
; $aDataDisplay_Info0[30] = $iIdx ; $idListView item/subitem click event


; --- Allocating a row in $aDataDisplay_Info ---

; $iIdx > 0
; $aDataDisplay_Info0[20] += 1
; $aDataDisplay_Info[$iIdx][20] = $iIdx


; --- Information related to data source/display ---

; Information stored in $aDataDisplay_Info[$iIdx][Col]

; _ArrayDisplayEx            ; CSVfileDisplay             ; SafeArrayDisplay           ; _SQLite_Display         ; Display function
; _ArrayDisplayExCtrl        ; CSVfileDisplayCtrl         ; SafeArrayDisplayCtrl       ; _SQLite_DisplayCtrl     ; As embedded control
; $aArrayDisplayEx_Info      ; $aCSVfileDisplay_Info      ; $aSafeArrayDisplay_Info    ; $aSQLiteDisplay_Info    ; Previous global arrays

; Col  Variable              ; Col  Variable              ; Col  Variable              ; Col  Variable              
; ---  ----------------      ; ---  ----------------      ; ---  ----------------      ; ---  ----------------      
;  0   $aArray               ;  0   $aCSVfile             ;  0   $pSafeArray           ;  0   $pTable               
;  1   $hNotifyFunc          ;  1   $hNotifyFunc          ;  1   $hNotifyFunc          ;  1   $hNotifyFunc 
;  2   $pNotifyFunc          ;  2   $pNotifyFunc          ;  2   $pNotifyFunc          ;  2   $pNotifyFunc          
;  3   $aSort_Rows           ;  3   $aSort_Rows           ;  3   $aSort_Rows           ;  3   $aSort_Rows           
;  4   $aSort_Cols           ;  4   $aSort_Cols           ;  4   $aSort_Cols           ;  4   $aSort_Cols           
;  5   $aColumn_Formats      ;  5   $aColumn_Formats      ;  5   $aColumn_Formats      ;  5   $aColumn_Formats      
;  6   $aColumn_Colors       ;  6   $aColumn_Colors       ;  6   $aColumn_Colors       ;  6   $aColumn_Colors       
;  7   Not used              ;  7   $cSeparator           ;  7   Not used              ;  7   $iColCount            
;  8   Not used              ;  8   $iColCount            ;  8   Not used              ;  8   $iRowCount            
;  9   $bSort_Reverse        ;  9   $bSort_Reverse        ;  9   $bSort_Reverse        ;  9   $bSort_Reverse        
; 10   $aMsgData             ; 10   $aMsgData             ; 10   $aMsgData             ; 10   $aMsgData             
; 11   Not used              ; 11   Not used              ; 11   Not used              ; 11   $iColCount            
; 12   $i1dColumns           ; 12   Not used              ; 12   Not used              ; 12   Not used              

; Information stored in $aDataDisplay_Info[$iIdx][Col]

; Col  Description
; ---  --------------------------------------------------------------------------
; 15   Data display function id:  1/ 2/ 3 = _ArrayDisplay/Ex/Ctrl/Mult
;                                 4/ 5/ 6 = CSVfileDisplay/Ctrl/Mult
;                                 7/ 8/ 9 = SafeArrayDisplay/Ctrl/Mult
;                                10/11/12 = _SQLite_Display/Ctrl/Mult
; 16   "HdrColors" cleanup info: [ $hListView, $pHeaderColor, $oHdr_Colors_Dict ]
; 17   <DataDisplay>_Cleanup
; 18   $pCtrlMsgHandler


; --- Information related to multiple concurrent and responsive GUIs ---

; Information stored in $aDataDisplay_Info[$iIdx][Col]

; $aDataDisplay_Info[$iIdx][21] = $hGUI
; $aDataDisplay_Info[$iIdx][22] = $idTabKey            ; Events from these controls must be detected by DataDisplayMult_MsgHandler()
; $aDataDisplay_Info[$iIdx][23] = $idShiftTab
; $aDataDisplay_Info[$iIdx][24] = $idEnterKey
; $aDataDisplay_Info[$iIdx][25] = $idGoto
; $aDataDisplay_Info[$iIdx][26] = $idFunc
; $aDataDisplay_Info[$iIdx][27] = $idExit
; $aDataDisplay_Info[$iIdx][28] = $idListView          ; These controls/variables are used in main message loop
; $aDataDisplay_Info[$iIdx][29] = $aAccelKeys
; $aDataDisplay_Info[$iIdx][30] = $bAccelKeys
; $aDataDisplay_Info[$iIdx][31] = $idGotoSuccessor
; $aDataDisplay_Info[$iIdx][32] = $fGotoFirst
; $aDataDisplay_Info[$iIdx][33] = $hUser_Function
; $aDataDisplay_Info[$iIdx][34] = $iRowCount
; $aDataDisplay_Info[$iIdx][35] = -1 ; $iItemIdx
; $aDataDisplay_Info[$iIdx][36] = $aArrayContents      ; $idListView item/subitem click event
; $aDataDisplay_Info[$iIdx][40] = $pMultMsgHandler     ; Pointer to DataDisplayMult_MsgHandler()
; $aDataDisplay_Info[$iIdx][44] = $aFeaturesInfo[0]    ; "SortByCols" variables used in main message loop
; $aDataDisplay_Info[$iIdx][45] = $aSort_ByCols
; $aDataDisplay_Info[$iIdx][46] = $iSortColPrev
; $aDataDisplay_Info[$iIdx][47] = $hHeader
; $aDataDisplay_Info[$iIdx][48] = $aHdr_Info           ; Not used
