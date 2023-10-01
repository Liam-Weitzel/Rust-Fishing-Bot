#include-once

Global $gpMoniker

; --- Interface definitions ---

Global Const $sIID_IRunningObjectTable = "{00000010-0000-0000-C000-000000000046}"
Global Const $dtag_IRunningObjectTable = _
	"Register hresult(dword;ptr;ptr;dword*);" & _
	"Revoke hresult(dword);" & _
	"IsRunning hresult(ptr);" & _
	"GetObject hresult(ptr;ptr*);" & _
	"NoteChangeTime hresult(dword;struct*);" & _
	"GetTimeOfLastChange hresult(ptr;ptr*);" & _
	"EnumRunning hresult(ptr*);"

Global Const $ROTFLAGS_REGISTRATIONKEEPSALIVE = 0x1
Global Const $ROTFLAGS_ALLOWANYCLIENT = 0x2


Global Const $sIID_IEnumMoniker = "{00000102-0000-0000-C000-000000000046}"
Global Const $dtag_IEnumMoniker = _
	"Next hresult(ulong;ptr*;ulong*);" & _
	"Skip hresult(ulong);" & _
	"Reset hresult();" & _
	"Clone hresult(ptr*);"


Global Const $sIID_IPersist = "{0000010C-0000-0000-C000-000000000046}"
Global Const $dtag_IPersist = _
	"GetClassID hresult(ptr*);"

Global Const $sIID_IPersistStream = "{00000109-0000-0000-C000-000000000046}"
Global Const $dtag_IPersistStream = $dtag_IPersist & _
	"IsDirty hresult();" & _
	"Load hresult(ptr);" & _
	"Save hresult(ptr;bool);" & _
	"GetSizeMax hresult(uint*);"

Global Const $sIID_IMoniker = "{0000000F-0000-0000-C000-000000000046}"
Global Const $dtag_IMoniker = $dtag_IPersistStream & _
	"BindToObject hresult();" & _
	"BindToStorage hresult();" & _
	"Reduce hresult();" & _
	"ComposeWith hresult();" & _
	"Enum hresult();" & _
	"IsEqual hresult();" & _
	"Hash hresult();" & _
	"IsRunning hresult(ptr;ptr;ptr);" & _
	"GetTimeOfLastChange hresult(ptr;ptr;ptr);" & _
	"Inverse hresult();" & _
	"CommonPrefixWith hresult();" & _
	"RelativePathTo hresult();" & _
	"GetDisplayName hresult(ptr;ptr;wstr*);" & _
	"ParseDisplayName hresult();" & _
	"IsSystemMoniker hresult(ptr*);"


; --- Windows API functions ---

Func ROT_GetRunningObjectTable()
	Return DllCall( "Ole32.dll", "long", "GetRunningObjectTable", "dword", 0, "ptr*", 0 )[2]
EndFunc

Func ROT_CreateFileMoniker( $sNameId )
	Return DllCall( "Ole32.dll", "long", "CreateFileMoniker", "wstr", $sNameId, "ptr*", 0 )[2]
EndFunc

Func ROT_CreateBindCtx()
	Return DllCall( "Ole32.dll", "long", "CreateBindCtx", "dword", 0, "ptr*", 0 )[2]
EndFunc


; --- UDF functions ---

; Failure: Returns 0
; Success: Returns ROT-object
; Create a default ROT-object
Func ROT_CreateDefaultObject( ByRef $sNameId, $bUnique = 1 )
	If $bUnique Then $sNameId &= ROT_CreateGUID() ; Make $sNameId unique
	Local $iHandle = ROT_RegisterObject( Default, $sNameId )
	; Default => Object = Dictionary object
	If $iHandle = 0 Then Return 0
	Local $oObject = ObjGet( $sNameId ) ; Dictionary object
	Return IsObj( $oObject ) ? $oObject : 0
EndFunc

; Failure: Returns 0
; Success: Returns $iHandle
; Registers an object and its identifying moniker in the ROT
Func ROT_RegisterObject( $pObject, $sNameId, $iFlags = $ROTFLAGS_REGISTRATIONKEEPSALIVE )
	If $pObject = Default Then
		Local $oDict = ObjCreate( "Scripting.Dictionary" )
		$pObject = Ptr( $oDict )
	EndIf

  If Not $pObject Or Not $sNameId Then Return 0

	Local $oRunningObjectTable = ObjCreateInterface( ROT_GetRunningObjectTable(), $sIID_IRunningObjectTable, $dtag_IRunningObjectTable )
  If Not IsObj( $oRunningObjectTable ) Then Return 0

	Local $pMoniker = ROT_CreateFileMoniker( $sNameId )
  If Not $pMoniker Then Return 0
	$gpMoniker = $pMoniker

	Local $iHandle
	$oRunningObjectTable.Register( $iFlags, $pObject, $pMoniker, $iHandle )
	Return $iHandle ? $iHandle : 0
EndFunc

; Returns unique GUID as string
; Copied from _WinAPI_CreateGUID
Func ROT_CreateGUID()
	Local Static $tGUID = DllStructCreate( "struct;ulong Data1;ushort Data2;ushort Data3;byte Data4[8];endstruct" )
	DllCall( "Ole32.dll", "long", "CoCreateGuid", "struct*", $tGUID )
	Return "-" & DllCall( "Ole32.dll", "int", "StringFromGUID2", "struct*", $tGUID, "wstr", "", "int", 65536 )[2]
EndFunc

; Failure: Returns 0
; Success: Returns $aROT_List
; Enumerates objects and identifying monikers in the ROT
Func ROT_Enumerate()
	Local $oRunningObjectTable = ObjCreateInterface( ROT_GetRunningObjectTable(), $sIID_IRunningObjectTable, $dtag_IRunningObjectTable )
	If Not IsObj( $oRunningObjectTable ) Then Return 0

	Local $pEnumMoniker
	$oRunningObjectTable.EnumRunning( $pEnumMoniker )
	Local $oEnumMoniker = ObjCreateInterface( $pEnumMoniker, $sIID_IEnumMoniker, $dtag_IEnumMoniker )
	If Not IsObj( $oEnumMoniker ) Then Return 0

	Local $pMoniker, $oMoniker, $pBindCtx, $sMonikerName, $i = 0
	Local $oDict = ObjCreate( "Scripting.Dictionary" )

	While( $oEnumMoniker.Next( 1, $pMoniker, NULL ) = 0 )
		$pBindCtx = ROT_CreateBindCtx()
		$oMoniker = ObjCreateInterface( $pMoniker, $sIID_IMoniker, $dtag_IMoniker )
		$oMoniker.GetDisplayName( $pBindCtx, NULL, $sMonikerName )
		$oDict.Add( "Key" & $i, $sMonikerName )
		$i += 1
	WEnd

	Local $aROT_List = $oDict.Items()
	Return $aROT_List
EndFunc

; Failure: Returns 0
; Success: Returns 1
; Removes an object and its identifying moniker from the ROT
Func ROT_Revoke( $iHandle )
  If Not $iHandle Then Return 0

	Local $oRunningObjectTable = ObjCreateInterface( ROT_GetRunningObjectTable(), $sIID_IRunningObjectTable, $dtag_IRunningObjectTable )
	If Not IsObj( $oRunningObjectTable ) Then Return 0

	Return Not $oRunningObjectTable.Revoke( $iHandle ) * 1
EndFunc
