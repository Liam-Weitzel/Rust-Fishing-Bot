#include-once
#include <File.au3>

Global $giRuntime_Test ; It's possible to execute up to 4 Runtime test functions. $giRuntime_Test determines which of the 4 test functions to run.

Global $gsRuntime_Path ; The full or relative (relative to the Runtime script) path to the Runtime Includes folder.

; Runtime report file
Global $gsRuntime_File ; $gsRuntime_File = <@ScriptName without file extension>.txt
$gsRuntime_File = StringLeft( @ScriptName, StringInStr( @ScriptName, "." ) ) & "txt"
Global $gbRuntime_File_Del = 1   ; Delete the report file given by $gsRuntime_File.
; If 0 to NOT delete file, it must be deleted manually before the first script run.

Global $ghRuntime_Info ; Window handle to Runtimes and Speed Comparisons LogInfo GUI.

Global $gbRuntime_Main ; True to perform a complete test cycle through Runtime_Main().

Global $gbRuntime_3264 ; True to perform the test cycle as both 32 bit and 64 bit code.

; Apart from Runtime_Settings(), these 3 variables are only used in the Runtime script.
Global $giRuntime_Time_Tests, $gfRuntime_Max_Time, $gbRuntime_Display_Once

; Settings for the current Runtime and Speed Comparison script.
;
; Error code in @error                 Return value
;     1 -> Invalid parameter value         Success -> 1
;                                          Failure -> 0
Func Runtime_Settings( _
	$liRuntime_Time_Tests = 2, _   ; Number of time measurements in each Runtime function. Default 2.
	$lfRuntime_Max_Time = 0, _     ; Max time in milliseconds for a single time measurement. 0 to disable.
	$lbRuntime_Display_Once = 1, _ ; Visual validation of Runtime data for $aRuntime_Rows[0]. 0 to disable.
	$lbRuntime_File_Del = 1, _     ; 0 to NOT delete report file given by $gsRuntime_File. Only used when $lbRuntime_Main = 0.
	$liRuntime_Test = 1, _         ; Indicate the current of up to 4 Runtime test functions. Only used when $lbRuntime_Main = 0.
	$lbRuntime_Main = 0 )          ; 1 to perform a complete test cycle through Runtime_Main() function. 0 to test the function above.

	If Not ( 1 <= $liRuntime_Time_Tests ) Then Return SetError( 1, 0, 0 )                                 ; Integer
	If Not ( 0 <= $lfRuntime_Max_Time ) Then Return SetError( 1, 0, 0 )                                   ; Float
	If Not ( 0 = $lbRuntime_Display_Once Or $lbRuntime_Display_Once = 1 ) Then Return SetError( 1, 0, 0 ) ; Boolean
	If Not ( 0 = $lbRuntime_File_Del Or $lbRuntime_File_Del = 1 ) Then Return SetError( 1, 0, 0 )         ; Boolean
	If Not ( 1 <= $liRuntime_Test And $liRuntime_Test <= 4 ) Then Return SetError( 1, 0, 0 )              ; Integer
	If Not ( 0 = $lbRuntime_Main Or $lbRuntime_Main = 1 ) Then Return SetError( 1, 0, 0 )                 ; Boolean

	$giRuntime_Time_Tests = $liRuntime_Time_Tests ; Must be the same number in each function to ensure vertical column alignment.
	$gfRuntime_Max_Time = $lfRuntime_Max_Time     ; Set individual max times by updating $aTimes[$i][2] in the Runtime functions.
	$gbRuntime_Display_Once = $lbRuntime_Display_Once
	$gbRuntime_File_Del = $lbRuntime_File_Del     ; 0: Possible to run the same script on several PCs with output in same report.
	$giRuntime_Test = $liRuntime_Test
	$gbRuntime_Main = $lbRuntime_Main

	Return 1
EndFunc

; Command line parameters when Runtime_Main()
; is performing a complete test cycle.
Func Runtime_CmdLineParams()
	$giRuntime_Test = $CmdLine[1]+0
	$gbRuntime_Main = $CmdLine[2]+0
	$gbRuntime_3264 = $CmdLine[3]+0
	If $gbRuntime_Main Then $gbRuntime_File_Del = 1
	If $CmdLine[0] = 4 Then $ghRuntime_Info = HWnd( $CmdLine[4] )
	; To update Runtimes and Speed Comparisons LogInfo GUI
EndFunc

; Runtime_Main() performs a complete test cycle, where up to 4 Runtime test functions
; are executed.
;
; Error code in @error                 Return value
;     1 -> Invalid parameter value         Success -> 1
;                                          Failure -> 0
Func Runtime_Main( _
	$giRuntime_Test_Functions = 1, _ ; The number of Runtime test functions
	$giRuntime_Test_Bitness = 3, _   ; 1, 2 or 3 for 32/64 bit test or both
	$giRuntime_Test_LogInfo = 1 )    ; Runtime LogInfo is enabled as default

	; Maximum up to 4 Runtime test functions for EITHER 32 OR 64 bit tests
	If Not ( 1 <= $giRuntime_Test_Functions And $giRuntime_Test_Functions <= 4 ) Then Return SetError( 1, 0, 0 )
	If Not ( 1 <= $giRuntime_Test_Bitness And $giRuntime_Test_Bitness <= 3 ) Then Return SetError( 1, 0, 0 )
	If $giRuntime_Test_Functions > 2 And $giRuntime_Test_Bitness = 3 Then Return SetError( 1, 0, 0 )
	; Maximum up to 2 Runtime test functions for BOTH 32 AND 64 bit tests

	$gbRuntime_3264 = $giRuntime_Test_Bitness = 3 ? 1 : 0

	Local $sAutoItExePath = StringLeft( @AutoItExe, StringInStr( @AutoItExe, "\", 0, -1 ) )

	If $giRuntime_Test_LogInfo Then
		; Start Runtimes and Speed Comparisons LogInfo GUI
		Local $sScriptName = $gsRuntime_Path & "\LogInfoDisplay.au3"
		Run( $sAutoItExePath & "AutoIt3_x64.exe" & " /AutoIt3ExecuteScript " & """" & $sScriptName & """" & " " & """" & @ScriptName & """" )
		$ghRuntime_Info = WinWaitActive( "[TITLE:LogInfoDisplay;CLASS:AutoIt v3 GUI]" )
	EndIf

	FileDelete( $gsRuntime_File )

	; Runtime and Speed Comparison test 1 is always performed

	$giRuntime_Test = 1
	; Execute @ScriptName as 32 bit
	If BitAND( $giRuntime_Test_Bitness, 1 ) Then
		ConsoleWrite( @ScriptName & ": Runtime Test 1 - Performing 32-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
		RunWait( $sAutoItExePath & "AutoIt3.exe"     & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 32 bit code
	EndIf
	; Execute @ScriptName as 64 bit
	If BitAND( $giRuntime_Test_Bitness, 2 ) Then
		ConsoleWrite( @ScriptName & ": Runtime Test 1 - Performing 64-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
		RunWait( $sAutoItExePath & "AutoIt3_x64.exe" & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 64 bit code
	EndIf

	; Runtime and Speed Comparison test 2 is only performed if $giRuntime_Test_Functions >= 2

	If $giRuntime_Test_Functions >= 2 Then
		$giRuntime_Test = 2
		; Execute @ScriptName as 32 bit
		If BitAND( $giRuntime_Test_Bitness, 1 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 2 - Performing 32-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3.exe"     & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 32 bit code
		EndIf
		; Execute @ScriptName as 64 bit
		If BitAND( $giRuntime_Test_Bitness, 2 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 2 - Performing 64-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3_x64.exe" & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 64 bit code
		EndIf
	EndIf

	; Runtime and Speed Comparison test 3 is only performed if $giRuntime_Test_Functions >= 3
	; And if you only test with EITHER 32 OR 64 bit code

	If $giRuntime_Test_Functions >= 3 Then
		$giRuntime_Test = 3
		; Execute @ScriptName as 32 bit
		If BitAND( $giRuntime_Test_Bitness, 1 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 3 - Performing 32-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3.exe"     & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 32 bit code
		EndIf
		; Execute @ScriptName as 64 bit
		If BitAND( $giRuntime_Test_Bitness, 2 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 3 - Performing 64-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3_x64.exe" & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 64 bit code
		EndIf
	EndIf

	; Runtime and Speed Comparison test 4 is only performed if $giRuntime_Test_Functions = 4
	; And if you only test with EITHER 32 OR 64 bit code

	If $giRuntime_Test_Functions >= 4 Then
		$giRuntime_Test = 4
		; Execute @ScriptName as 32 bit
		If BitAND( $giRuntime_Test_Bitness, 1 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 4 - Performing 32-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3.exe"     & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 32 bit code
		EndIf
		; Execute @ScriptName as 64 bit
		If BitAND( $giRuntime_Test_Bitness, 2 ) Then
			ConsoleWrite( @ScriptName & ": Runtime Test 4 - Performing 64-bit Runtimes and Speed Comparison Tests ..." & @CRLF )
			RunWait( $sAutoItExePath & "AutoIt3_x64.exe" & " /AutoIt3ExecuteScript " & """" & @ScriptName & """" & " " & $giRuntime_Test & " 2 " & $gbRuntime_3264 & " " & $ghRuntime_Info ) ; 64 bit code
		EndIf
	EndIf

	Exit  ; Exit is needed to prevent code in the calling script that
EndFunc ; follows execution of Runtime_Main() from being executed.

Func Runtime_Times()
	; Storage for individual time measurements
	Local $aRuntime_Times[$giRuntime_Time_Tests][3]
	For $i = 0 To $giRuntime_Time_Tests - 1
		$aRuntime_Times[$i][0] = 1 ; $bTime
		$aRuntime_Times[$i][1] = 0 ; $fTime
		$aRuntime_Times[$i][2] = $gfRuntime_Max_Time
	Next
	Return $aRuntime_Times
EndFunc

Func Runtime_InitStorage( ByRef $aRuntime_Info )
	If Not $gbRuntime_Main Then
		If $gbRuntime_File_Del Then
			FileDelete( $gsRuntime_File )
		ElseIf FileExists( $gsRuntime_File ) Then
			_FileReadToArray( $gsRuntime_File, $aRuntime_Info, 0 ) ; 0 = $FRTA_NOCOUNT
			Local $aSplit = StringSplit( $aRuntime_Info[4], "=    =", 3 )
			If Not @error And UBound( $aSplit ) Then ; 3 = $STR_ENTIRESPLIT + $STR_NOCOUNT
				ConsoleWrite( """" & $gsRuntime_File & """: Column aligning mismatch for the $gbRuntime_File_Del = 0 option." & @CRLF )
				Exit 1
			EndIf
			If UBound( StringSplit( $aRuntime_Info[4], "        ", 3 ) ) = 4 Then ; 3 = $STR_ENTIRESPLIT + $STR_NOCOUNT
				ConsoleWrite( """" & $gsRuntime_File & """ contains 4 columns. No more Runtimes and Speed Comparison Tests possible." & @CRLF )
				Exit 1
			EndIf
		EndIf
	ElseIf FileExists( $gsRuntime_File ) Then
		_FileReadToArray( $gsRuntime_File, $aRuntime_Info, 0 ) ; 0 = $FRTA_NOCOUNT
	EndIf
EndFunc

Global $gasRuntime_Strs[2]
Func Runtime_HeaderInfo( $iBit, $sHeader1, $sHeader2, $l, ByRef $aRuntime_Info )
	If $gbRuntime_Main And Not $gbRuntime_3264 Then
		$gasRuntime_Strs[0] = $giRuntime_Test > 1 ? "        " : ""
		$gasRuntime_Strs[1] = ""
	Else
		If Not $gbRuntime_File_Del Then
			$gasRuntime_Strs[0] = StringLen( $aRuntime_Info[0] ) ? "        " : ""
			$gasRuntime_Strs[1] = ""
		Else
			$gasRuntime_Strs[0] = ( ( $gbRuntime_Main And $giRuntime_Test = 2 And $iBit = 32 ) ? "        " : "" )
			$gasRuntime_Strs[1] = ( $iBit = 32 ? "    " : "" )
		EndIf
	EndIf
	Local $s1 = $gasRuntime_Strs[0], $s3 = $gasRuntime_Strs[1]

	Local $iStrLen
	If Not $gbRuntime_File_Del Or ( $gbRuntime_Main And Not $gbRuntime_3264 ) Then
		$iStrLen = StringLen( $sHeader1 )
		$aRuntime_Info[0] &= $s1 & StringFormat( "%-"&$l&"s", $iStrLen > $l ? StringLeft( $sHeader1, $l ) : $sHeader1 )
		$iStrLen = StringLen( $sHeader2 )
		$aRuntime_Info[1] &= $s1 & StringFormat( "%-"&$l&"s", $iStrLen > $l ? StringLeft( $sHeader2, $l ) : $sHeader2 )
	ElseIf Not ( $gbRuntime_Main And $iBit = 64 ) Then
		$iStrLen = StringLen( $sHeader1 )
		$aRuntime_Info[0] &= $s1 & StringFormat( "%-"&2*$l+4&"s", $iStrLen > 2*$l+4 ? StringLeft( $sHeader1, 2*$l+4 ) : $sHeader1 )
		$iStrLen = StringLen( $sHeader2 )
		$aRuntime_Info[1] &= $s1 & StringFormat( "%-"&2*$l+4&"s", $iStrLen > 2*$l+4 ? StringLeft( $sHeader2, 2*$l+4 ) : $sHeader2 )
	EndIf

	ConsoleWrite( $aRuntime_Info[0] & @CRLF )
	ConsoleWrite( $aRuntime_Info[1] & @CRLF )
	If $ghRuntime_Info Then
		Runtime_SendCopyData( $ghRuntime_Info, "0|" & $aRuntime_Info[0] )
		Runtime_SendCopyData( $ghRuntime_Info, "1|" & $aRuntime_Info[1] )
	EndIf

	Local $s2 = "Code executed as " & $iBit & "-bit code"
	$aRuntime_Info[3] &= $s1 & StringFormat( "%-"&$l&"s", $s2 ) & $s3
	$aRuntime_Info[4] &= $s1 & StringLeft( "================================================================================", $l ) & $s3
	ConsoleWrite( @CRLF & $aRuntime_Info[3] & @CRLF )
	ConsoleWrite( $aRuntime_Info[4] & @CRLF )
	If $ghRuntime_Info Then
		Runtime_SendCopyData( $ghRuntime_Info, "3|" & $aRuntime_Info[3] )
		Runtime_SendCopyData( $ghRuntime_Info, "4|" & $aRuntime_Info[4] )
	EndIf
EndFunc

Func Runtime_RowsInfo( $i, $iRows, $sRows, $iCols, $iTests, $l, ByRef $aRuntime_Info )
	Local $s1 = $gasRuntime_Strs[0], $s3 = $gasRuntime_Strs[1]
	Local $s2 = StringRegExpReplace( $iRows, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1,") & " " & $sRows
	If $iCols Then $s2 &= "; " & $iCols & " cols; " & StringRegExpReplace( $iRows*$iCols, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1,") & " elems"
	If StringLen( $s2 ) > $l Then $s2 = StringRegExpReplace( $s2, " rows| cols| elems", "" )
	$aRuntime_Info[6+$i*($iTests+3)] &= $s1 & StringFormat( "%-"&$l&"s", $s2 ) & $s3
	$aRuntime_Info[7+$i*($iTests+3)] &= $s1 & StringLeft( "--------------------------------------------------------------------------------", $l ) & $s3
	ConsoleWrite( @CRLF & $aRuntime_Info[6+$i*($iTests+3)] & @CRLF )
	ConsoleWrite( $aRuntime_Info[7+$i*($iTests+3)] & @CRLF )
	If $ghRuntime_Info Then
		Runtime_SendCopyData( $ghRuntime_Info, 6+$i*($iTests+3) & "|" & $aRuntime_Info[6+$i*($iTests+3)] )
		Runtime_SendCopyData( $ghRuntime_Info, 7+$i*($iTests+3) & "|" & $aRuntime_Info[7+$i*($iTests+3)] )
	EndIf
EndFunc

; Create runtime information for each number of test rows
; And for each time measurement test in the Runtime function
Func Runtime_Info1( $n, $i, $iTests, $l, $fTime, ByRef $aRuntime_Info, $sText )
	$aRuntime_Info[$n+$i*($iTests+3)] &= $gasRuntime_Strs[0] & StringFormat( "%-"&$l-12&"s", $sText ) & StringFormat( "%12.4f", $fTime ) & $gasRuntime_Strs[1]
	ConsoleWrite( $aRuntime_Info[$n+$i*($iTests+3)] & @CRLF )
	If $ghRuntime_Info Then Runtime_SendCopyData( $ghRuntime_Info, $n+$i*($iTests+3) & "|" & $aRuntime_Info[$n+$i*($iTests+3)] )
EndFunc

; Create detail Runtime info line if $fTime > $fMaxTime
Func Runtime_Info2( $n, $i, $iTests, $l, $fMaxTime, ByRef $aRuntime_Info, $sText )
	$aRuntime_Info[$n+$i*($iTests+3)] &= $gasRuntime_Strs[0] & ( $sText ? StringFormat( "%-"&$l-12&"s", $sText ) & StringFormat( "%12s", ">" & StringFormat( "%9.4f", $fMaxTime ) ) _
	                                                                    : StringFormat( "%"&$l&"s", "" ) ) & $gasRuntime_Strs[1]
	ConsoleWrite( $aRuntime_Info[$n+$i*($iTests+3)] & @CRLF )
	If $ghRuntime_Info Then Runtime_SendCopyData( $ghRuntime_Info, $n+$i*($iTests+3) & "|" & $aRuntime_Info[$n+$i*($iTests+3)] )
EndFunc

; Send data to Runtime LogInfo GUI
Func Runtime_SendCopyData( $hWnd, $sData )
	Local Static $tCopyData = DllStructCreate( "ulong_ptr dwData;dword cbData;ptr lpData" ), $pCopyData = DllStructGetPtr( $tCopyData )
	Local $tData = DllStructCreate( "wchar[" & 2 * StringLen( $sData ) + 2 & "]" )
	DllStructSetData( $tData, 1, $sData )
	DllStructSetData( $tCopyData, 2, 2 * StringLen( $sData ) + 2 )
	DllStructSetData( $tCopyData, 3, DllStructGetPtr( $tData ) )
	DllCall( "user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", 0x004A, "wparam", 0, "lparam", $pCopyData ) ; 0x004A = $WM_COPYDATA
EndFunc
