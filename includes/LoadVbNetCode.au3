#include-once
#include "DotNetAll.au3"

; Create $oVbNetClass object to execute procedures as compiled VB.NET code
;
; Error code in @error                     Return value
;     1 -> Failed to locate source file        Success -> 1 or $oVbNetClass
;     2 -> Failed to create $oVbNetClass        Failure -> 0
;
Func CreateVbNetClassObject( _
	$sVbNetCode  = "", _ ; Relative path to VB.NET source file
	$sVbNetClass = "", _ ; The VB.NET class as defined in source
	$sVbNetRefs  = "" )  ; VB.NET assembly Dll-file references

	Local Static $bVbNetClass = 0, $oVbNetCode, $oVbNetClass
	If Not $sVbNetCode And $bVbNetClass Then Return $oVbNetClass

	; Locate VB.NET source file
	If Not FileExists( $sVbNetCode ) Then Return SetError( 1, 0, 0 )

	; Create $oVbNetClass object
	$oVbNetCode = DotNet_LoadVBcode( FileRead( $sVbNetCode ), $sVbNetRefs )
	$oVbNetClass = DotNet_CreateObject( $oVbNetCode, $sVbNetClass )
	If Not IsObj( $oVbNetClass ) Then Return SetError( 2, 0, 0 )
	$bVbNetClass = 1
	Return 1
EndFunc
