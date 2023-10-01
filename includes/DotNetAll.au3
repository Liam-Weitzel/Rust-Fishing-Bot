#include-once

; ####################################################################################################
; ###                                                                                              ###
; ###                                         Variant.au3                                          ###
; ###                                                                                              ###
; ####################################################################################################

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; Copied from AutoItObject.au3 by the AutoItObject-Team: monoceres, trancexx, Kip, ProgAndy
; https://www.autoitscript.com/forum/index.php?showtopic=110379

Global Const $tagVARIANT = "word vt;word r1;word r2;word r3;ptr data; ptr"
; The structure takes up 16/24 bytes when running 32/64 bit
; Space for the data element at the end represents 2 pointers
; This is 8 bytes running 32 bit and 16 bytes running 64 bit

Global Const $VT_EMPTY            = 0  ; 0x0000
Global Const $VT_NULL             = 1  ; 0x0001
Global Const $VT_I2               = 2  ; 0x0002
Global Const $VT_I4               = 3  ; 0x0003
Global Const $VT_R4               = 4  ; 0x0004
Global Const $VT_R8               = 5  ; 0x0005
Global Const $VT_CY               = 6  ; 0x0006
Global Const $VT_DATE             = 7  ; 0x0007
Global Const $VT_BSTR             = 8  ; 0x0008
Global Const $VT_DISPATCH         = 9  ; 0x0009
Global Const $VT_ERROR            = 10 ; 0x000A
Global Const $VT_BOOL             = 11 ; 0x000B
Global Const $VT_VARIANT          = 12 ; 0x000C
Global Const $VT_UNKNOWN          = 13 ; 0x000D
Global Const $VT_DECIMAL          = 14 ; 0x000E
Global Const $VT_I1               = 16 ; 0x0010
Global Const $VT_UI1              = 17 ; 0x0011
Global Const $VT_UI2              = 18 ; 0x0012
Global Const $VT_UI4              = 19 ; 0x0013
Global Const $VT_I8               = 20 ; 0x0014
Global Const $VT_UI8              = 21 ; 0x0015
Global Const $VT_INT              = 22 ; 0x0016
Global Const $VT_UINT             = 23 ; 0x0017
Global Const $VT_VOID             = 24 ; 0x0018
Global Const $VT_HRESULT          = 25 ; 0x0019
Global Const $VT_PTR              = 26 ; 0x001A
Global Const $VT_SAFEARRAY        = 27 ; 0x001B
Global Const $VT_CARRAY           = 28 ; 0x001C
Global Const $VT_USERDEFINED      = 29 ; 0x001D
Global Const $VT_LPSTR            = 30 ; 0x001E
Global Const $VT_LPWSTR           = 31 ; 0x001F
Global Const $VT_RECORD           = 36 ; 0x0024
Global Const $VT_INT_PTR          = 37 ; 0x0025
Global Const $VT_UINT_PTR         = 38 ; 0x0026
Global Const $VT_FILETIME         = 64 ; 0x0040
Global Const $VT_BLOB             = 65 ; 0x0041
Global Const $VT_STREAM           = 66 ; 0x0042
Global Const $VT_STORAGE          = 67 ; 0x0043
Global Const $VT_STREAMED_OBJECT  = 68 ; 0x0044
Global Const $VT_STORED_OBJECT    = 69 ; 0x0045
Global Const $VT_BLOB_OBJECT      = 70 ; 0x0046
Global Const $VT_CF               = 71 ; 0x0047
Global Const $VT_CLSID            = 72 ; 0x0048
Global Const $VT_VERSIONED_STREAM = 73 ; 0x0049
Global Const $VT_BSTR_BLOB        = 0xFFF
Global Const $VT_VECTOR           = 0x1000
Global Const $VT_ARRAY            = 0x2000
Global Const $VT_BYREF            = 0x4000
Global Const $VT_RESERVED         = 0x8000
Global Const $VT_ILLEGAL          = 0xFFFF
Global Const $VT_ILLEGALMASKED    = 0xFFF
Global Const $VT_TYPEMASK         = 0xFFF

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;Global Const $tagVARIANT = "word vt;word r1;word r2;word r3;ptr data; ptr"
; The structure takes up 16/24 bytes when running 32/64 bit
; Space for the data element at the end represents 2 pointers
; This is 8 bytes running 32 bit and 16 bytes running 64 bit

#cs
DECIMAL structure
https://msdn.microsoft.com/en-us/library/windows/desktop/ms221061(v=vs.85).aspx

From oledb.h:
typedef struct tagDEC {
    USHORT wReserved;			; vt,     2 bytes
    union {								; r1,     2 bytes
        struct {
            BYTE scale;
            BYTE sign;
        };
        USHORT signscale;
    };
    ULONG Hi32;						; r2, r3, 4 bytes
    union {								; data,   8 bytes
        struct {
#ifdef _MAC
            ULONG Mid32;
            ULONG Lo32;
#else
            ULONG Lo32;
            ULONG Mid32;
#endif
        };
        ULONGLONG Lo64;
    };
} DECIMAL;
#ce

Global Const $tagDEC = "word wReserved;byte scale;byte sign;uint Hi32;uint Lo32;uint Mid32"


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; Variant functions
; Copied from AutoItObject.au3 by the AutoItObject-Team: monoceres, trancexx, Kip, ProgAndy
; https://www.autoitscript.com/forum/index.php?showtopic=110379

; #FUNCTION# ====================================================================================================================
; Name...........: VariantClear
; Description ...: Clears the value of a variant
; Syntax.........: VariantClear($pvarg)
; Parameters ....: $pvarg       - the VARIANT to clear
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: VariantFree
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221165.aspx
; Example .......:
; ===============================================================================================================================
Func VariantClear($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "long", "VariantClear", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: VariantCopy
; Description ...: Copies a VARIANT to another
; Syntax.........: VariantCopy($pvargDest, $pvargSrc)
; Parameters ....: $pvargDest   - Destionation variant
;                  $pvargSrc    - Source variant
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: VariantRead
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221697.aspx
; Example .......:
; ===============================================================================================================================
Func VariantCopy($pvargDest, $pvargSrc)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "long", "VariantCopy", "ptr", $pvargDest, 'ptr', $pvargSrc)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: VariantInit
; Description ...: Initializes a variant.
; Syntax.........: VariantInit($pvarg)
; Parameters ....: $pvarg       - the VARIANT to initialize
; Return values .: Success      - 0
;                  Failure      - nonzero
; Author ........: Prog@ndy
; Modified.......:
; Remarks .......:
; Related .......: VariantClear
; Link ..........: http://msdn.microsoft.com/en-us/library/ms221402.aspx
; Example .......:
; ===============================================================================================================================
Func VariantInit($pvarg)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "long", "VariantInit", "ptr", $pvarg)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


Func VariantChangeType( $pVarDest, $pVarSrc, $wFlags, $vt )
	Local $aRet = DllCall( "OleAut32.dll", "long", "VariantChangeType", "ptr", $pVarDest, "ptr", $pVarSrc, "word", $wFlags, "word", $vt )
	If @error Then Return SetError(1,0,1)
	Return $aRet[0]
EndFunc

Func VariantChangeTypeEx( $pVarDest, $pVarSrc, $lcid, $wFlags, $vt )
	Local $aRet = DllCall( "OleAut32.dll", "long", "VariantChangeTypeEx", "ptr", $pVarDest, "ptr", $pVarSrc, "word", $lcid, "word", $wFlags, "word", $vt )
	If @error Then Return SetError(1,0,1)
	Return $aRet[0]
EndFunc

Func VarAdd( $pVarLeft, $pVarRight, $pVarResult )
	Local $aRet = DllCall( "OleAut32.dll", "long", "VarAdd", "ptr", $pVarLeft, "ptr", $pVarRight, "ptr", $pVarResult )
	If @error Then Return SetError(1,0,1)
	Return $aRet[0]
EndFunc

Func VarSub( $pVarLeft, $pVarRight, $pVarResult )
	Local $aRet = DllCall( "OleAut32.dll", "long", "VarSub", "ptr", $pVarLeft, "ptr", $pVarRight, "ptr", $pVarResult )
	If @error Then Return SetError(1,0,1)
	Return $aRet[0]
EndFunc


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; BSTR (basic string) functions
; Copied from AutoItObject.au3 by the AutoItObject-Team: monoceres, trancexx, Kip, ProgAndy
; https://www.autoitscript.com/forum/index.php?showtopic=110379

Func SysAllocString( $str )
	Local $aRet = DllCall( "OleAut32.dll", "ptr", "SysAllocString", "wstr", $str )
	If @error Then Return SetError(1, 0, 0)
	Return $aRet[0]
EndFunc

Func SysFreeString( $pBSTR )
	If Not $pBSTR Then Return SetError(1, 0, 0)
	DllCall( "OleAut32.dll", "none", "SysFreeString", "ptr", $pBSTR )
	If @error Then Return SetError(2, 0, 0)
EndFunc

Func SysReadString( $pBSTR, $iLen = -1 )
	If Not $pBSTR Then Return SetError(1, 0, "")
	If $iLen < 1 Then $iLen = SysStringLen( $pBSTR )
	If $iLen < 1 Then Return SetError(2, 0, "")
	Return DllStructGetData( DllStructCreate( "wchar[" & $iLen & "]", $pBSTR ), 1 )
EndFunc

Func SysStringLen( $pBSTR )
	If Not $pBSTR Then Return SetError(1, 0, 0)
	Local $aRet = DllCall( "OleAut32.dll", "uint", "SysStringLen", "ptr", $pBSTR )
	If @error Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                        SafeArray.au3                                         ###
; ###                                                                                              ###
; ####################################################################################################

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Global Const $tagSAFEARRAYBOUND = _
	"ulong  cElements;"  & _ ; The number of elements in the dimension.
	"long   lLbound;"        ; The lower bound of the dimension.

Global Const $tagSAFEARRAY = _
	"ushort cDims;"      & _ ; The number of dimensions.
	"ushort fFeatures;"  & _ ; Flags, see below.
	"ulong  cbElements;" & _ ; The size of an array element.
	"ulong  cLocks;"     & _ ; The number of times the array has been locked without a corresponding unlock.
	"ptr    pvData;"     & _ ; The data.
	$tagSAFEARRAYBOUND       ; One $tagSAFEARRAYBOUND for each dimension.

; fFeatures flags
Global Const $FADF_AUTO        = 0x0001 ; An array that is allocated on the stack.
Global Const $FADF_STATIC      = 0x0002 ; An array that is statically allocated.
Global Const $FADF_EMBEDDED    = 0x0004 ; An array that is embedded in a structure.
Global Const $FADF_FIXEDSIZE   = 0x0010 ; An array that may not be resized or reallocated.
Global Const $FADF_RECORD      = 0x0020 ; An array that contains records. When set, there will be a pointer to the IRecordInfo interface at negative offset 4 in the array descriptor.
Global Const $FADF_HAVEIID     = 0x0040 ; An array that has an IID identifying interface. When set, there will be a GUID at negative offset 16 in the safearray descriptor. Flag is set only when FADF_DISPATCH or FADF_UNKNOWN is also set.
Global Const $FADF_HAVEVARTYPE = 0x0080 ; An array that has a variant type. The variant type can be retrieved with SafeArrayGetVartype.
Global Const $FADF_BSTR        = 0x0100 ; An array of BSTRs.
Global Const $FADF_UNKNOWN     = 0x0200 ; An array of IUnknown*.
Global Const $FADF_DISPATCH    = 0x0400 ; An array of IDispatch*.
Global Const $FADF_VARIANT     = 0x0800 ; An array of VARIANTs.
Global Const $FADF_RESERVED    = 0xF008 ; Bits reserved for future use.



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

; Safearray functions
; Copied from AutoItObject.au3 by the AutoItObject-Team: monoceres, trancexx, Kip, ProgAndy
; https://www.autoitscript.com/forum/index.php?showtopic=110379

Func SafeArrayCreate($vType, $cDims, $rgsabound)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "ptr", "SafeArrayCreate", "dword", $vType, "uint", $cDims, 'struct*', $rgsabound)
	If @error Then Return SetError(1, 0, 0)
	Return $aCall[0]
EndFunc

Func SafeArrayDestroy($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "int", "SafeArrayDestroy", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc

Func SafeArrayAccessData($pSafeArray, ByRef $pArrayData)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "int", "SafeArrayAccessData", "ptr", $pSafeArray, 'ptr*', 0)
	If @error Then Return SetError(1, 0, 1)
	$pArrayData = $aCall[2]
	Return $aCall[0]
EndFunc

Func SafeArrayUnaccessData($pSafeArray)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "int", "SafeArrayUnaccessData", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 1)
	Return $aCall[0]
EndFunc

Func SafeArrayGetUBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "int", "SafeArrayGetUBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc

Func SafeArrayGetLBound($pSafeArray, $iDim, ByRef $iBound)
	; Author: Prog@ndy
	Local $aCall = DllCall("OleAut32.dll", "int", "SafeArrayGetLBound", "ptr", $pSafeArray, 'uint', $iDim, 'long*', 0)
	If @error Then Return SetError(1, 0, 1)
	$iBound = $aCall[3]
	Return $aCall[0]
EndFunc

Func SafeArrayGetDim($pSafeArray)
	Local $aResult = DllCall("OleAut32.dll", "uint", "SafeArrayGetDim", "ptr", $pSafeArray)
	If @error Then Return SetError(1, 0, 0)
	Return $aResult[0]
EndFunc

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



Func SafeArrayCopy( $pSafeArrayIn, ByRef $pSafeArrayOut )
	Local $aRet = DllCall( "OleAut32.dll", "int", "SafeArrayCopy", "ptr", $pSafeArrayIn, "ptr*", 0 )
	If @error Then Return SetError(1,0,1)
	$pSafeArrayOut = $aRet[2]
	Return $aRet[0]
EndFunc

Func SafeArrayCreateEmpty( $vType )
	Local $tsaBound = DllStructCreate( $tagSAFEARRAYBOUND )
	DllStructSetData( $tsaBound, "cElements", 0 )
	DllStructSetData( $tsaBound, "lLbound", 0 )
	Return SafeArrayCreate( $vType, 0, $tsaBound )
EndFunc

Func SafeArrayDestroyData( $pSafeArray )
	Local $aRet = DllCall( "OleAut32.dll", "int", "SafeArrayDestroyData", "ptr", $pSafeArray )
	If @error Then Return SetError(1,0,1)
	Return $aRet[0]
EndFunc

Func SafeArrayGetVartype( $pSafeArray, ByRef $vt )
	Local $aRet = DllCall( "OleAut32.dll", "int", "SafeArrayGetVartype", "ptr", $pSafeArray, "ptr*", 0 )
	If @error Then Return SetError(1,0,1)
	$vt = $aRet[2]
	Return $aRet[0]
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                         COMUtils.au3                                         ###
; ###                                                                                              ###
; ####################################################################################################

Func CoCreateInstance( $rclsid, $pUnkOuter, $ClsContext, $riid, ByRef $ppv )
	Local $aRet = DllCall( "ole32.dll", "long", "CoCreateInstance", "struct*", $rclsid, "ptr", $pUnkOuter, "dword", $ClsContext, "struct*", $riid, "ptr*", 0 )
	If @error Then Return SetError(1,0,1)
	$ppv = $aRet[5]
	Return $aRet[0]
EndFunc

; Add these lines to a script to activate the error handler:
;Local $oComErrFunc = ObjEvent( "AutoIt.Error", "ComErrFunc" )
;#forceref $oComErrFunc
Func ComErrFunc( $oError )
ConsoleWrite( @ScriptName & "(" & $oError.scriptline & "): ==> COM Error intercepted!" & @CRLF & _
	@TAB & "Err.number is: " & @TAB & @TAB & "0x" & Hex( $oError.number ) & @CRLF & _
	@TAB & "Err.windescription:" & @TAB & $oError.windescription & _
	@TAB & "Err.description is: " & @TAB & $oError.description & @CRLF & _
	@TAB & "Err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
	@TAB & "Err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
	@TAB & "Err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
	@TAB & "Err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
	@TAB & "Err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
	@TAB & "Err.retcode is: " & @TAB & "0x" & Hex( $oError.retcode ) & @CRLF )
EndFunc

; Copied from "Hooking into the IDispatch interface" by monoceres
; https://www.autoitscript.com/forum/index.php?showtopic=107678
Func ReplaceVTableFuncPtr( $pVTable, $iOffset, $pNewFunc )
	Local $pPointer = DllStructGetData( DllStructCreate( "ptr", $pVTable ), 1 ) + $iOffset, $PAGE_EXECUTE_READWRITE = 0x40
	Local $pOldFunc = DllStructGetData( DllStructCreate( "ptr", $pPointer ), 1 ) ; Get the original function pointer in VTable
	Local $aRet = DllCall( "Kernel32.dll", "int", "VirtualProtect", "ptr", $pPointer, "long", @AutoItX64 ? 8 : 4, "dword", $PAGE_EXECUTE_READWRITE, "dword*", 0 ) ; Unprotect memory
	DllStructSetData( DllStructCreate( "ptr", $pPointer ), 1, $pNewFunc ) ; Replace function pointer in VTable with $pNewFunc function pointer
	DllCall( "Kernel32.dll", "int", "VirtualProtect", "ptr", $pPointer, "long", @AutoItX64 ? 8 : 4, "dword", $aRet[4], "dword*", 0 ) ; Protect memory
	Return $pOldFunc ; Return original function pointer
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                    AccessingVariables.au3                                    ###
; ###                                                                                              ###
; ####################################################################################################

Global $oAccVars_Object = AccVars_Init(), $hAccVars_MethodFunc


; --- The first part of the UDF creates $oAccVars_Object and implements method functions ---

Func AccVars_Init()
	; Three locals copied from "IUIAutomation MS framework automate chrome, FF, IE, ...." by junkew
	; https://www.autoitscript.com/forum/index.php?showtopic=153520
	Local $sCLSID_CUIAutomation = "{FF48DBA4-60EF-4201-AA87-54103EEF594E}"
	Local $sIID_IUIAutomation = "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}"
	Local $stag_IUIAutomation = _
		"AccVars_VariableToVariant01 hresult(variant*);" & _
		"AccVars_VariableToVariant02 hresult(variant*;variant*);"

	; Create AccVars object (Automation object)
  Local $oAccVars_Object = ObjCreateInterface( $sCLSID_CUIAutomation, $sIID_IUIAutomation, $stag_IUIAutomation )
  If Not IsObj( $oAccVars_Object ) Then Return SetError(1,0,1)

	; Replace original methods with AccVars_VariableToVariantXY methods
	Local $pVariableToVariant, $pAccessVariable = Ptr( $oAccVars_Object() ), $sFuncName, $sFuncParams = "ptr", $iOffset, $iPtrSize = @AutoItX64 ? 8 : 4
	For $i = 1 To 2
		$sFuncName = "AccVars_VariableToVariant" & StringFormat( "%02i", $i )
		$sFuncParams &= ";ptr*"
		$iOffset = ( 3 + $i - 1 ) * $iPtrSize
		$pVariableToVariant = DllCallbackGetPtr( DllCallbackRegister( $sFuncName, "long", $sFuncParams ) )
		ReplaceVTableFuncPtr( $pAccessVariable, $iOffset, $pVariableToVariant )
	Next

	Return $oAccVars_Object
EndFunc

Func AccVars_VariableToVariant01( $pSelf, $pVariant01 )
	$hAccVars_MethodFunc( $pVariant01 )
	Return 0 ; $S_OK (COM constant)
	#forceref $pSelf
EndFunc

Func AccVars_VariableToVariant02( $pSelf, $pVariant01, $pVariant02 )
	$hAccVars_MethodFunc( $pVariant01, $pVariant02 )
	Return 0 ; $S_OK (COM constant)
	#forceref $pSelf
EndFunc


; --- The last part of the UDF creates a set of easy to use functions to call the object methods ---

Func AccessVariables01( $hAccVars_Method, ByRef $vVariable01 )
	$hAccVars_MethodFunc = $hAccVars_Method
	$oAccVars_Object.AccVars_VariableToVariant01( $vVariable01 )
EndFunc

Func AccessVariables02( $hAccVars_Method, ByRef $vVariable01, ByRef $vVariable02 )
	$hAccVars_MethodFunc = $hAccVars_Method
	$oAccVars_Object.AccVars_VariableToVariant02( $vVariable01, $vVariable02 )
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                     AccVarsUtilities.au3                                     ###
; ###                                                                                              ###
; ####################################################################################################

; --- AccVars_ArrayToSafeArray ---

; The AutoIt array and the safearray are arrays of variants
Func AccVars_ArrayToSafeArray( ByRef $aArray, ByRef $pSafeArray )
	AccessVariables01( AccVars_ArrayToSafeArrayConvert, $aArray )
	AccVars_ArrayToSafeArrayData( $pSafeArray )
EndFunc

Func AccVars_ArrayToSafeArrayConvert( $pArray )
	; <<<< On function entry the native AutoIt array is converted to a safearray contained in a variant >>>>

	; Get safearray pointer
	Local $pSafeArrayFromArray = DllStructGetData( DllStructCreate( "ptr", $pArray + 8 ), 1 )

	Local $pSafeArray
	SafeArrayCopy( $pSafeArrayFromArray, $pSafeArray )
	If @error Then Return SetError(1,0,0)

	AccVars_ArrayToSafeArrayData( $pSafeArray, 1 )
EndFunc

Func AccVars_ArrayToSafeArrayData( ByRef $pSafeArray, $bSet = 0 )
	Static $pStaticSafeArray
	If $bSet Then
		$pStaticSafeArray = $pSafeArray
	Else
		$pSafeArray = $pStaticSafeArray
	EndIf
EndFunc


; --- AccVars_SafeArrayToArray ---

; The safearray and the AutoIt array are arrays of variants
Func AccVars_SafeArrayToArray( ByRef $pSafeArray, ByRef $aArray )
	AccessVariables02( AccVars_SafeArrayToArrayConvert, $pSafeArray, $aArray )
EndFunc

Func AccVars_SafeArrayToArrayConvert( $pvSafeArray, $pArray )

	; --- Get safearray information ---

	; $pvSafeArray is a variant that contains a pointer
	Local $pSafeArray = DllStructGetData( DllStructCreate( "ptr", $pvSafeArray + 8 ), 1 )

	; Array type
	Local $iVarType
	SafeArrayGetVartype( $pSafeArray, $iVarType )
	Switch $iVarType
		Case $VT_I2, $VT_I4   ; Signed integers
		Case $VT_R4, $VT_R8   ; 4/8 bytes floats
		Case $VT_BSTR         ; Basic string
		Case $VT_BOOL         ; Boolean type
		Case $VT_UI4, $VT_UI8 ; 4/8 bytes unsigned integers
		Case $VT_VARIANT      ; Variant data type
		Case $VT_UNKNOWN      ; IUnknown pointer
			; $pSafeArray is not compatible with a native AutoIt array
			; Convert $pSafeArray to a compatible safearray in $pSafeArray2
			Local $tSafeArray = DllStructCreate( $tagSAFEARRAY, $pSafeArray )
			Local $tSafeArrayBound = DllStructCreate( $tagSAFEARRAYBOUND )
			Local $iElements = DllStructGetData( $tSafeArray, "cElements" )
			DllStructSetData( $tSafeArrayBound, "cElements", $iElements )
			DllStructSetData( $tSafeArrayBound, "lLbound", DllStructGetData( $tSafeArray, "lLbound" ) )
			Local $pSafeArray2 = SafeArrayCreate( $VT_VARIANT, 1, $tSafeArrayBound ), $pArrayData, $pArrayData2
			SafeArrayAccessData( $pSafeArray2, $pArrayData2 )
			SafeArrayAccessData( $pSafeArray, $pArrayData )
			$iVarType = @AutoItX64 ? $VT_UI8 : $VT_UI4
			Local $iVarSize = @AutoItX64 ? 24 : 16
			Local $iPtrSize = @AutoItX64 ? 8 : 4
			For $i = 0 To $iElements - 1 ; Set variant type and data
				DllStructSetData( DllStructCreate( "word", $pArrayData2 + $i * $iVarSize ), 1, $iVarType )
				DllStructSetData( DllStructCreate( "uint_ptr", 8 + $pArrayData2 + $i * $iVarSize ), 1, DllStructGetData( DllStructCreate( "ptr", $pArrayData + $i * $iPtrSize ), 1 ) )
			Next
			SafeArrayUnaccessData( $pSafeArray )
			SafeArrayUnaccessData( $pSafeArray2 )
			SafeArrayCopy( $pSafeArray2, $pSafeArray )
			SafeArrayDestroy( $pSafeArray2 )
		Case Else
			Return SetError(1,0,0)
	EndSwitch

	; --- Set $pArray to match an array ---

	; Set vt element to $VT_ARRAY + $iVarType
	DllStructSetData( DllStructCreate( "word", $pArray ), 1, $VT_ARRAY + $iVarType )

	; Set data element to safearray pointer
	DllStructSetData( DllStructCreate( "ptr", $pArray + 8 ), 1, $pSafeArray )

	; <<<< On function exit the safearray contained in a variant is converted to a native AutoIt array >>>>
EndFunc


; --- AccVars_ArrayToSafeArrayOfVartype ---

; The returned safearray is an array of the specified variant type
Func AccVars_ArrayToSafeArrayOfVartype( ByRef $aArray, $iVartype )
	Local $tsaBound = DllStructCreate( $tagSAFEARRAYBOUND ), $pSafeArray, $pSafeArrayData, $iArray = UBound( $aArray ), $iPtrSize = @AutoItX64 ? 8 : 4
	DllStructSetData( $tsaBound, "cElements", $iArray )
	DllStructSetData( $tsaBound, "lLbound", 0 )
	$pSafeArray = SafeArrayCreate( $iVartype, 1, $tsaBound )
	SafeArrayAccessData( $pSafeArray, $pSafeArrayData )
	For $i = 0 To $iArray - 1
		DllStructSetData( DllStructCreate( "ptr", $pSafeArrayData + $iPtrSize * $i ), 1, SysAllocString( $aArray[$i] ) )
	Next
	SafeArrayUnaccessData( $pSafeArray )
	Return $pSafeArray
EndFunc


; --- AccVars_SafeArrayToSafeArrayOfVariant ---

; Returns a safearray with one variant element
; The variant element contains the input safearray
Func AccVars_SafeArrayToSafeArrayOfVariant( ByRef $pSafeArrayIn )
	Local $iVartype, $tsaBound = DllStructCreate( $tagSAFEARRAYBOUND ), $pSafeArrayOut, $pSafeArrayOutData
	SafeArrayGetVartype( $pSafeArrayIn, $iVartype )
	DllStructSetData( $tsaBound, "cElements", 1 )
	DllStructSetData( $tsaBound, "lLbound", 0 )
	$pSafeArrayOut = SafeArrayCreate( $VT_VARIANT, 1, $tsaBound )
	SafeArrayAccessData( $pSafeArrayOut, $pSafeArrayOutData )
	DllStructSetData( DllStructCreate( "word", $pSafeArrayOutData ), 1, $iVartype + $VT_ARRAY )
	DllStructSetData( DllStructCreate( "ptr", $pSafeArrayOutData + 8 ), 1, $pSafeArrayIn )
	SafeArrayUnaccessData( $pSafeArrayOut )
	Return $pSafeArrayOut
EndFunc


; --- AccVars_VariantToVariable ---

Func AccVars_VariantToVariable( ByRef $pVariant )
	Switch DllStructGetData( DllStructCreate( "word", $pVariant ), 1 )
		Case $VT_I4, $VT_I8 ; 4/8 bytes signed integer
			Return DllStructGetData( DllStructCreate( "int", $pVariant + 8 ), 1 )
		Case $VT_R8 ; 8 bytes double
			Return DllStructGetData( DllStructCreate( "double", $pVariant + 8 ), 1 )
		Case $VT_BSTR ; Basic string
			Return SysReadString( DllStructGetData( DllStructCreate( "ptr", $pVariant + 8 ), 1 ) )
		Case $VT_BOOL ; 2 bytes boolean
			Return DllStructGetData( DllStructCreate( "short", $pVariant + 8 ), 1 )
		Case $VT_UI4, $VT_UI8 ; 4/8 bytes unsigned integer
			Return DllStructGetData( DllStructCreate( "ptr", $pVariant + 8 ), 1 )
		Case Else
			Return SetError(1,0,0)
	EndSwitch
EndFunc


; --- AccVars_VariableToVariant ---

Func AccVars_VariableToVariant( $vVariable, ByRef $pVariant )
	Switch VarGetType( $vVariable )
		Case "Bool"
			DllStructSetData( DllStructCreate( "word", $pVariant ), 1, $VT_BOOL )
			DllStructSetData( DllStructCreate( "short", $pVariant + 8 ), 1, $vVariable )
		Case "Double"
			DllStructSetData( DllStructCreate( "word", $pVariant ), 1, $VT_R8 )
			DllStructSetData( DllStructCreate( "double", $pVariant + 8 ), 1, $vVariable )
		Case "Int32"
			DllStructSetData( DllStructCreate( "word", $pVariant ), 1, $VT_I4 )
			DllStructSetData( DllStructCreate( "int", $pVariant + 8 ), 1, $vVariable )
		Case "Ptr"
			DllStructSetData( DllStructCreate( "word", $pVariant ), 1, @AutoItX64 ? $VT_UI8 : $VT_UI4 )
			DllStructSetData( DllStructCreate( "ptr", $pVariant + 8 ), 1, $vVariable )
		Case "String"
			DllStructSetData( DllStructCreate( "word", $pVariant ), 1, $VT_BSTR )
			DllStructSetData( DllStructCreate( "ptr", $pVariant + 8 ), 1, SysAllocString( $vVariable ) )
		Case Else
			Return SetError(1,0,0)
	EndSwitch
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                        Interfaces.au3                                        ###
; ###                                                                                              ###
; ####################################################################################################

Global Const $sCLSID_CorRuntimeHost = "{CB2F6723-AB3A-11D2-9C40-00C04FA30A3E}"
Global Const $tCLSID_CorRuntimeHost = CLSIDFromString( $sCLSID_CorRuntimeHost )
Global Const $sIID_ICorRuntimeHost = "{CB2F6722-AB3A-11D2-9C40-00C04FA30A3E}"
Global Const $tIID_ICorRuntimeHost = CLSIDFromString( $sIID_ICorRuntimeHost )
Global Const $sTag_ICorRuntimeHost = _
	"CreateLogicalThreadState hresult();" & _
	"DeleteLogicalThreadState hresult();" & _
	"SwitchInLogicalThreadState hresult();" & _
	"SwitchOutLogicalThreadState hresult();" & _
	"LocksHeldByLogicalThread hresult();" & _
	"MapFile hresult();" & _
	"GetConfiguration hresult();" & _
	"Start hresult();" & _
	"Stop hresult();" & _
	"CreateDomain hresult();" & _
	"GetDefaultDomain hresult(ptr*);" & _
	"EnumDomains hresult(ptr*);" & _
	"NextDomain hresult(ptr;ptr*);" & _
	"CloseEnum hresult();" & _
	"CreateDomainEx hresult();" & _
	"CreateDomainSetup hresult();" & _
	"CreateEvidence hresult();" & _
	"UnloadDomain hresult(ptr);" & _
	"CurrentDomain hresult();"

Global Const $sIID_IDispatch = "{00020400-0000-0000-C000-000000000046}"
Global Const $sTag_IDispatch = _
	"GetTypeInfoCount hresult(dword*);" & _
	"GetTypeInfo hresult(dword;dword;ptr*);" & _
	"GetIDsOfNames hresult(ptr;ptr;dword;dword;ptr);" & _
	"Invoke hresult(dword;ptr;dword;word;ptr;ptr;ptr;ptr);"

; The interfaces _AppDomain, _Type and _Assembly below that starts with
; an underscore are the interfaces that can be used from unmanaged code.

Global Const $sIID__AppDomain = "{05F696DC-2B29-3663-AD8B-C4389CF2A713}"
Global Const $sTag__AppDomain = _
	$sTag_IDispatch & _
	"get_ToString hresult();" & _
	"Equals hresult();" & _
	"GetHashCode hresult();" & _
	"GetType hresult(ptr*);" & _
	"InitializeLifetimeService hresult();" & _
	"GetLifetimeService hresult();" & _
	"get_Evidence hresult();" & _
	"add_DomainUnload hresult();" & _
	"remove_DomainUnload hresult();" & _
	"add_AssemblyLoad hresult();" & _
	"remove_AssemblyLoad hresult();" & _
	"add_ProcessExit hresult();" & _
	"remove_ProcessExit hresult();" & _
	"add_TypeResolve hresult();" & _
	"remove_TypeResolve hresult();" & _
	"add_ResourceResolve hresult();" & _
	"remove_ResourceResolve hresult();" & _
	"add_AssemblyResolve hresult();" & _
	"remove_AssemblyResolve hresult();" & _
	"add_UnhandledException hresult();" & _
	"remove_UnhandledException hresult();" & _
	"DefineDynamicAssembly hresult();" & _
	"DefineDynamicAssembly_2 hresult();" & _
	"DefineDynamicAssembly_3 hresult();" & _
	"DefineDynamicAssembly_4 hresult();" & _
	"DefineDynamicAssembly_5 hresult();" & _
	"DefineDynamicAssembly_6 hresult();" & _
	"DefineDynamicAssembly_7 hresult();" & _
	"DefineDynamicAssembly_8 hresult();" & _
	"DefineDynamicAssembly_9 hresult();" & _
	"CreateInstance hresult(bstr;bstr;object*);" & _
	"CreateInstanceFrom hresult();" & _
	"CreateInstance_2 hresult();" & _
	"CreateInstanceFrom_2 hresult();" & _
	"CreateInstance_3 hresult(bstr;bstr;bool;int;ptr;ptr;ptr;ptr;ptr;ptr*);" & _
	"CreateInstanceFrom_3 hresult();" & _
	"Load hresult();" & _
	"Load_2 hresult();" & _
	"Load_3 hresult();" & _
	"Load_4 hresult();" & _
	"Load_5 hresult();" & _
	"Load_6 hresult();" & _
	"Load_7 hresult();" & _
	"ExecuteAssembly hresult();" & _
	"ExecuteAssembly_2 hresult();" & _
	"ExecuteAssembly_3 hresult();" & _
	"get_FriendlyName hresult(bstr*);" & _
	"get_BaseDirectory hresult(bstr*);" & _
	"get_RelativeSearchPath hresult();" & _
	"get_ShadowCopyFiles hresult();" & _
	"GetAssemblies hresult(ptr*);" & _
	"AppendPrivatePath hresult();" & _
	"ClearPrivatePath ) = 0; hresult();" & _
	"SetShadowCopyPath hresult();" & _
	"ClearShadowCopyPath ) = 0; hresult();" & _
	"SetCachePath hresult();" & _
	"SetData hresult();" & _
	"GetData hresult();" & _
	"SetAppDomainPolicy hresult();" & _
	"SetThreadPrincipal hresult();" & _
	"SetPrincipalPolicy hresult();" & _
	"DoCallBack hresult();" & _
	"get_DynamicDirectory hresult();"

Global Const $sIID__Type = "{BCA8B44D-AAD6-3A86-8AB7-03349F4F2DA2}"
Global Const $sTag__Type = _
	$sTag_IDispatch & _
	"get_ToString hresult(bstr*);" & _
	"Equals hresult(variant;short*);" & _
	"GetHashCode hresult(int*);" & _
	"GetType hresult(ptr);" & _
	"get_MemberType hresult(ptr);" & _
	"get_name hresult(bstr*);" & _
	"get_DeclaringType hresult(ptr);" & _
	"get_ReflectedType hresult(ptr);" & _
	"GetCustomAttributes hresult(ptr;short;ptr);" & _
	"GetCustomAttributes_2 hresult(short;ptr);" & _
	"IsDefined hresult(ptr;short;short*);" & _
	"get_Guid hresult(ptr);" & _
	"get_Module hresult(ptr);" & _
	"get_Assembly hresult(ptr*);" & _
	"get_TypeHandle hresult(ptr);" & _
	"get_FullName hresult(bstr*);" & _
	"get_Namespace hresult(bstr*);" & _
	"get_AssemblyQualifiedName hresult(bstr*);" & _
	"GetArrayRank hresult(int*);" & _
	"get_BaseType hresult(ptr);" & _
	"GetConstructors hresult(ptr;ptr);" & _
	"GetInterface hresult(bstr;short;ptr);" & _
	"GetInterfaces hresult(ptr);" & _
	"FindInterfaces hresult(ptr;variant;ptr);" & _
	"GetEvent hresult(bstr;ptr;ptr);" & _
	"GetEvents hresult(ptr);" & _
	"GetEvents_2 hresult(int;ptr);" & _
	"GetNestedTypes hresult(int;ptr);" & _
	"GetNestedType hresult(bstr;ptr;ptr);" & _
	"GetMember hresult(bstr;ptr;ptr;ptr);" & _
	"GetDefaultMembers hresult(ptr);" & _
	"FindMembers hresult(ptr;ptr;ptr;variant;ptr);" & _
	"GetElementType hresult(ptr);" & _
	"IsSubclassOf hresult(ptr;short*);" & _
	"IsInstanceOfType hresult(variant;short*);" & _
	"IsAssignableFrom hresult(ptr;short*);" & _
	"GetInterfaceMap hresult(ptr;ptr);" & _
	"GetMethod hresult(bstr;ptr;ptr;ptr;ptr;ptr);" & _
	"GetMethod_2 hresult(bstr;ptr;ptr);" & _
	"GetMethods hresult(int;ptr);" & _
	"GetField hresult(bstr;ptr;ptr);" & _
	"GetFields hresult(int;ptr);" & _
	"GetProperty hresult(bstr;ptr;ptr);" & _
	"GetProperty_2 hresult(bstr;ptr;ptr;ptr;ptr;ptr;ptr);" & _
	"GetProperties hresult(ptr;ptr);" & _
	"GetMember_2 hresult(bstr;ptr;ptr);" & _
	"GetMembers hresult(int;ptr*);" & _
	"InvokeMember hresult(bstr;ptr;ptr;variant;ptr;ptr;ptr;ptr;variant*);" & _
	"get_UnderlyingSystemType hresult(ptr);" & _
	"InvokeMember_2 hresult(bstr;int;ptr;variant;ptr;ptr;variant*);" & _
	"InvokeMember_3 hresult(bstr;int;ptr;variant;ptr;variant*);" & _
	"GetConstructor hresult(ptr;ptr;ptr;ptr;ptr;ptr);" & _
	"GetConstructor_2 hresult(ptr;ptr;ptr;ptr;ptr);" & _
	"GetConstructor_3 hresult(ptr;ptr);" & _
	"GetConstructors_2 hresult(ptr);" & _
	"get_TypeInitializer hresult(ptr);" & _
	"GetMethod_3 hresult(bstr;ptr;ptr;ptr;ptr;ptr;ptr);" & _
	"GetMethod_4 hresult(bstr;ptr;ptr;ptr);" & _
	"GetMethod_5 hresult(bstr;ptr;ptr);" & _
	"GetMethod_6 hresult(bstr;ptr);" & _
	"GetMethods_2 hresult(ptr);" & _
	"GetField_2 hresult(bstr;ptr);" & _
	"GetFields_2 hresult(ptr);" & _
	"GetInterface_2 hresult(bstr;ptr);" & _
	"GetEvent_2 hresult(bstr;ptr);" & _
	"GetProperty_3 hresult(bstr;ptr;ptr;ptr;ptr);" & _
	"GetProperty_4 hresult(bstr;ptr;ptr;ptr);" & _
	"GetProperty_5 hresult(bstr;ptr;ptr);" & _
	"GetProperty_6 hresult(bstr;ptr;ptr);" & _
	"GetProperty_7 hresult(bstr;ptr);" & _
	"GetProperties_2 hresult(ptr);" & _
	"GetNestedTypes_2 hresult(ptr);" & _
	"GetNestedType_2 hresult(bstr;ptr);" & _
	"GetMember_3 hresult(bstr;ptr);" & _
	"GetMembers_2 hresult(ptr);" & _
	"get_Attributes hresult(ptr);" & _
	"get_IsNotPublic hresult(short*);" & _
	"get_IsPublic hresult(short*);" & _
	"get_IsNestedPublic hresult(short*);" & _
	"get_IsNestedPrivate hresult(short*);" & _
	"get_IsNestedFamily hresult(short*);" & _
	"get_IsNestedAssembly hresult(short*);" & _
	"get_IsNestedFamANDAssem hresult(short*);" & _
	"get_IsNestedFamORAssem hresult(short*);" & _
	"get_IsAutoLayout hresult(short*);" & _
	"get_IsLayoutSequential hresult(short*);" & _
	"get_IsExplicitLayout hresult(short*);" & _
	"get_IsClass hresult(short*);" & _
	"get_IsInterface hresult(short*);" & _
	"get_IsValueType hresult(short*);" & _
	"get_IsAbstract hresult(short*);" & _
	"get_IsSealed hresult(short*);" & _
	"get_IsEnum hresult(short*);" & _
	"get_IsSpecialName hresult(short*);" & _
	"get_IsImport hresult(short*);" & _
	"get_IsSerializable hresult(short*);" & _
	"get_IsAnsiClass hresult(short*);" & _
	"get_IsUnicodeClass hresult(short*);" & _
	"get_IsAutoClass hresult(short*);" & _
	"get_IsArray hresult(short*);" & _
	"get_IsByRef hresult(short*);" & _
	"get_IsPointer hresult(short*);" & _
	"get_IsPrimitive hresult(short*);" & _
	"get_IsCOMObject hresult(short*);" & _
	"get_HasElementType hresult(short*);" & _
	"get_IsContextful hresult(short*);" & _
	"get_IsMarshalByRef hresult(short*);" & _
	"Equals_2 hresult(ptr;short*);"

; Binding flags for InvokeMember, InvokeMember_2
; and InvokeMember_3 methods of _Type interface.
Global Const $BindingFlags_Default = 0x0000
Global Const $BindingFlags_IgnoreCase = 0x0001
Global Const $BindingFlags_DeclaredOnly = 0x0002
Global Const $BindingFlags_Instance = 0x0004
Global Const $BindingFlags_Static = 0x0008
Global Const $BindingFlags_Public = 0x0010
Global Const $BindingFlags_NonPublic = 0x0020
Global Const $BindingFlags_FlattenHierarchy = 0x0040
Global Const $BindingFlags_InvokeMethod = 0x0100
Global Const $BindingFlags_CreateInstance = 0x0200
Global Const $BindingFlags_GetField = 0x0400
Global Const $BindingFlags_SetField = 0x0800
Global Const $BindingFlags_GetProperty = 0x1000
Global Const $BindingFlags_SetProperty = 0x2000
Global Const $BindingFlags_PutDispProperty = 0x4000
Global Const $BindingFlags_PutRefDispProperty = 0x8000
Global Const $BindingFlags_ExactBinding = 0x00010000
Global Const $BindingFlags_SuppressChangeType = 0x00020000
Global Const $BindingFlags_OptionalParamBinding = 0x00040000
Global Const $BindingFlags_IgnoreReturn = 0x01000000
Global Const $BindingFlags_DefaultValue = $BindingFlags_Static + $BindingFlags_Public + $BindingFlags_FlattenHierarchy + $BindingFlags_InvokeMethod

Global Const $sIID__Assembly = "{17156360-2F1A-384A-BC52-FDE93C215C5B}"
Global Const $sTag__Assembly = _
	$sTag_IDispatch & _
	"get_ToString hresult(bstr*);" & _
	"Equals hresult();" & _
	"GetHashCode hresult();" & _
	"GetType hresult(ptr*);" & _
	"get_CodeBase hresult();" & _
	"get_EscapedCodeBase hresult();" & _
	"GetName hresult();" & _
	"GetName_2 hresult();" & _
	"get_FullName hresult(bstr*);" & _
	"get_EntryPoint hresult();" & _
	"GetType_2 hresult(bstr;ptr*);" & _
	"GetType_3 hresult();" & _
	"GetExportedTypes hresult();" & _
	"GetTypes hresult(ptr*);" & _
	"GetManifestResourceStream hresult();" & _
	"GetManifestResourceStream_2 hresult();" & _
	"GetFile hresult();" & _
	"GetFiles hresult();" & _
	"GetFiles_2 hresult();" & _
	"GetManifestResourceNames hresult();" & _
	"GetManifestResourceInfo hresult();" & _
	"get_Location hresult(bstr*);" & _
	"get_Evidence hresult();" & _
	"GetCustomAttributes hresult();" & _
	"GetCustomAttributes_2 hresult();" & _
	"IsDefined hresult();" & _
	"GetObjectData hresult();" & _
	"add_ModuleResolve hresult();" & _
	"remove_ModuleResolve hresult();" & _
	"GetType_4 hresult();" & _
	"GetSatelliteAssembly hresult();" & _
	"GetSatelliteAssembly_2 hresult();" & _
	"LoadModule hresult();" & _
	"LoadModule_2 hresult();" & _
	"CreateInstance hresult(bstr;variant*);" & _
	"CreateInstance_2 hresult(bstr;bool;variant*);" & _
	"CreateInstance_3 hresult(bstr;bool;int;ptr;ptr;ptr;ptr;variant*);" & _
	"GetLoadedModules hresult();" & _
	"GetLoadedModules_2 hresult();" & _
	"GetModules hresult();" & _
	"GetModules_2 hresult();" & _
	"GetModule hresult();" & _
	"GetReferencedAssemblies hresult();" & _
	"get_GlobalAssemblyCache hresult(bool*);"

Func CLSIDFromString( $sGUID )
	Static $hOle32Dll = "ole32.dll", $tGUID = DllStructCreate( "ulong Data1;ushort Data2;ushort Data3;byte Data4[8]" ), $pGUID = DllStructGetPtr( $tGUID )
	DllCall( $hOle32Dll, "uint", "CLSIDFromString", "wstr", $sGUID, "ptr", $pGUID )
	Return $tGUID
EndFunc

Func GUIDFromStringEx( $sGUID, $tGUID )
	Static $hOle32Dll = "ole32.dll"
	DllCall( $hOle32Dll, "long", "CLSIDFromString", "wstr", $sGUID, "struct*", $tGUID )
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                          DotNet.au3                                          ###
; ###                                                                                              ###
; ####################################################################################################

Func DotNet_Start( $sVersion = "" )
	Static $pRuntimeHost = 0, $oRuntimeHost
	If $pRuntimeHost Then Return $oRuntimeHost

	If $sVersion = "" Then
		Local $sPath = @WindowsDir & "\Microsoft.NET\Framework" & ( @AutoItX64 ? "64" : "" ) & "\"
		Local $hSearch = FileFindFirstFile( $sPath & "v?.*" ), $sFolder
		If $hSearch <> -1 Then
			While 1
				$sFolder = FileFindNextFile( $hSearch )
				Local $iError = @error, $iExtended = @extended
				If $iExtended = 1 And FileExists( $sPath & $sFolder & "\mscorlib.dll" ) And $sVersion < $sFolder Then $sVersion = $sFolder
				If $iError Then ExitLoop
			WEnd
		EndIf
	ElseIf Not FileExists( @WindowsDir & "\Microsoft.NET\Framework" & ( @AutoItX64 ? "64" : "" ) & "\" & $sVersion ) Then
		Return SetError( 1,0,0 )
	EndIf

	Local Const $tagGUID = "struct; ulong Data1;ushort Data2;ushort Data3;byte Data4[8]; endstruct"

	Local $tCLSID_CorRuntimeHost = DllStructCreate( $tagGUID )
	GUIDFromStringEx( $sCLSID_CorRuntimeHost, $tCLSID_CorRuntimeHost )

	Local $tIID_ICorRuntimeHost = DllStructCreate( $tagGUID )
	GUIDFromStringEx( $sIID_ICorRuntimeHost, $tIID_ICorRuntimeHost )

	Local $aRet = DllCall( "MSCorEE.dll", "long", "CorBindToRuntimeEx", "wstr", $sVersion, "ptr", NULL, "dword", 0, _
	                       "struct*", $tCLSID_CorRuntimeHost, "struct*", $tIID_ICorRuntimeHost, "ptr*", 0 )
	If Not ( @error = 0 And $aRet[0] = 0 And $aRet[6] ) Then Return SetError( 1,0,0 )

	$pRuntimeHost = $aRet[6]
	$oRuntimeHost = ObjCreateInterface( $pRuntimeHost, $sIID_ICorRuntimeHost, $sTag_ICorRuntimeHost )
	Return $oRuntimeHost
EndFunc

Func DotNet_StartDomain( ByRef $oAppDomain, $sFriendlyName = "", $sBaseDirectory = "" )
	Local $oDefDomain = DotNet_GetDefaultDomain()

	Local $pType, $oType
	$oDefDomain.GetType( $pType )
	$oType = ObjCreateInterface( $pType, $sIID__Type, $sTag__Type )

	Local $psaEmpty = SafeArrayCreateEmpty( $VT_VARIANT )
	Local $aArguments[5], $pSafeArray
	$aArguments[0] = $sFriendlyName
	$aArguments[2] = $sBaseDirectory
	$aArguments[4] = False
	AccVars_ArrayToSafeArray( $aArguments, $pSafeArray )

	$oType.InvokeMember_3( "CreateDomain", $BindingFlags_DefaultValue, $psaEmpty, $psaEmpty, $pSafeArray, $oAppDomain )
EndFunc

Func DotNet_StopDomain( ByRef $oAppDomain )
	Local $oRuntimeHost = DotNet_Start()
	$oRuntimeHost.UnloadDomain( Ptr( $oAppDomain ) )
	$oAppDomain = 0
EndFunc

; Internal function
Func DotNet_GetDefaultDomain()
	Static $pDefDomain = 0, $oDefDomain
	If $pDefDomain Then Return $oDefDomain

	Local $oRuntimeHost = DotNet_Start()
	$oRuntimeHost.Start()

	$oRuntimeHost.GetDefaultDomain( $pDefDomain )
	$oDefDomain = ObjCreateInterface( $pDefDomain, $sIID__AppDomain, $sTag__AppDomain )
	Return $oDefDomain
EndFunc

Func DotNet_LoadAssembly( $sAssemblyName, $oAppDomain = 0 )
	If Not $oAppDomain Then $oAppDomain = DotNet_GetDefaultDomain()

	Local $pType, $oType
	$oAppDomain.GetType( $pType )
	$oType = ObjCreateInterface( $pType, $sIID__Type, $sTag__Type )

	Local $pAssembly, $oAssembly
	$oType.get_Assembly( $pAssembly )
	$oAssembly = ObjCreateInterface( $pAssembly, $sIID__Assembly, $sTag__Assembly )

	Local $pAssemblyType, $oAssemblyType
	$oAssembly.GetType( $pAssemblyType )
	$oAssemblyType = ObjCreateInterface( $pAssemblyType, $sIID__Type, $sTag__Type )

	Local $aAssemblyName = [ $sAssemblyName ], $pSafeArray
	AccVars_ArrayToSafeArray( $aAssemblyName, $pSafeArray )

	Local $pNetCode
	$oAssemblyType.InvokeMember_3( "LoadFrom", $BindingFlags_DefaultValue, 0, 0, $pSafeArray, $pNetCode )
	; We first try to load the .NET assembly with the LoadFrom method

	; If LoadFrom method fails, we try to load the .NET assembly using the LoadWithPartialName method
	If Not Ptr( $pNetCode ) Then
		Local $iPos = StringInStr( $sAssemblyName, ".", Default, -1 )
		If StringRight( $sAssemblyName, StringLen( $sAssemblyName ) - $iPos ) = "dll" Then _ ; Use name of .NET assembly without DLL-
			$sAssemblyName = StringLeft( $sAssemblyName, $iPos - 1 )                           ; extension in LoadWithPartialName method.
		$aAssemblyName[0] = $sAssemblyName
		AccVars_ArrayToSafeArray( $aAssemblyName, $pSafeArray )
		$oAssemblyType.InvokeMember_3( "LoadWithPartialName", $BindingFlags_DefaultValue, 0, 0, $pSafeArray, $pNetCode )
		; LoadWithPartialName searches for the .NET assembly in the path given by $sBaseDirectory in DotNet_StartDomain
	EndIf

	If Not Ptr( $pNetCode ) Then Return SetError( 2,0,0 )
	Return ObjCreateInterface( $pNetCode, $sIID__Assembly, $sTag__Assembly )
EndFunc

Func DotNet_LoadCScode( $sCode, $sReferences = "", $oAppDomain = 0, $sFileName = "", $sCompilerOptions = "" )
	Local $oNetCode = DotNet_LoadCode( $sCode, $sReferences, "System", "Microsoft.CSharp.CSharpCodeProvider", $oAppDomain, $sFileName, $sCompilerOptions )
	If @error Then Return SetError( @error,0,0 )
	Return $oNetCode
EndFunc

Func DotNet_LoadVBcode( $sCode, $sReferences = "", $oAppDomain = 0, $sFileName = "", $sCompilerOptions = "" )
	Local $oNetCode = DotNet_LoadCode( $sCode, $sReferences, "System", "Microsoft.VisualBasic.VBCodeProvider", $oAppDomain, $sFileName, $sCompilerOptions )
	If @error Then Return SetError( @error,0,0 )
	Return $oNetCode
EndFunc

; Internal function
Func DotNet_LoadCode( $sCode, $sReferences, $sProviderAssembly, $sProviderType, $oAppDomain = 0, $sFileName = "", $sCompilerOptions = "" )
	If Not $oAppDomain Then $oAppDomain = DotNet_GetDefaultDomain()

	Local $oAsmProvider, $oCodeProvider, $oCodeCompiler, $oAsmSystem, $oPrms
	If IsObj( $oAppDomain ) Then $oAsmProvider = DotNet_LoadAssembly( $sProviderAssembly, $oAppDomain )
	If IsObj( $oAsmProvider ) Then $oAsmProvider.CreateInstance( $sProviderType, $oCodeProvider )
	If IsObj( $oCodeProvider ) Then $oCodeCompiler = $oCodeProvider.CreateCompiler()
	If IsObj( $oCodeCompiler ) Then $oAsmSystem = $sProviderAssembly = "System" ? $oAsmProvider : DotNet_LoadAssembly( "System", $oAppDomain )
	If Not IsObj( $oAsmSystem ) Then Return SetError( 3,0,0 )

	Local $aReferences = StringSplit( StringStripWS( StringRegExpReplace( $sReferences, "\s*\|\s*", "|" ), 3 ), "|", 2 ) ; 3 = $STR_STRIPLEADING + $STR_STRIPTRAILING, 2 = $STR_NOCOUNT
	Local $pSafeArray = AccVars_ArrayToSafeArrayOfVartype( $aReferences, $VT_BSTR )
	Local $psaVariant = AccVars_SafeArrayToSafeArrayOfVariant( $pSafeArray )
	Local $psaEmpty = SafeArrayCreateEmpty( $VT_VARIANT )

	; Create $oPrms object
	$oAsmSystem.CreateInstance_3( "System.CodeDom.Compiler.CompilerParameters", True, 0, 0, $psaVariant, 0, $psaEmpty, $oPrms )
	If Not IsObj( $oPrms ) Then Return SetError( 4,0,0 )

	; Set parameters for compiler
	$oPrms.OutputAssembly = $sFileName
	$oPrms.GenerateInMemory = ( $sFileName = "" )
	$oPrms.GenerateExecutable = ( StringRight( $sFileName, 4 ) = ".exe" )
	$oPrms.CompilerOptions = $sCompilerOptions
	$oPrms.IncludeDebugInformation = True

	; Compile code
	Local $oCompilerRes = $oCodeCompiler.CompileAssemblyFromSource( $oPrms, $sCode )

	; Compiler errors?
	If $oCompilerRes.Errors.Count() Then
		Local $b = False
		For $err In $oCompilerRes.Errors
			If $b Then ConsoleWrite( @CRLF )
			ConsoleWrite( "Line: " & $err.Line & @CRLF & "Column: " & $err.Column & @CRLF & $err.ErrorNumber & ": " & $err.ErrorText & @CRLF )
			$b = True
		Next
		Return SetError( 5,0,0 )
	EndIf

	If $sFileName Then
		Return $oCompilerRes.PathToAssembly()
	Else
		Local $pNetCode = $oCompilerRes.CompiledAssembly()
		Return ObjCreateInterface( $pNetCode, $sIID__Assembly, $sTag__Assembly )
	EndIf
EndFunc

Func DotNet_CreateObject( ByRef $oNetCode, $sClassName, $v3 = Default, $v4 = Default, $v5 = Default, $v6 = Default, $v7 = Default, $v8 = Default, $v9 = Default )
	Local $aParams = [ $v3, $v4, $v5, $v6, $v7, $v8, $v9 ], $oObject = 0

	If @NumParams = 2 Then
		$oNetCode.CreateInstance_2( $sClassName, True, $oObject )
		Return $oObject
	EndIf

	Local $iArgs = @NumParams - 2, $aArgs[$iArgs], $pSafeArray
	For $i = 0 To $iArgs - 1
		$aArgs[$i] = $aParams[$i]
	Next
	AccVars_ArrayToSafeArray( $aArgs, $pSafeArray )

	Local $psaEmpty = SafeArrayCreateEmpty( $VT_VARIANT )

	$oNetCode.CreateInstance_3( $sClassName, True, 0, 0, $pSafeArray, 0, $psaEmpty, $oObject )
	Return $oObject
EndFunc


; ####################################################################################################
; ###                                                                                              ###
; ###                                       DotNetUtils.au3                                        ###
; ###                                                                                              ###
; ####################################################################################################

#include <Array.au3>

Func DotNet_ListDomains()
	Local $pEnum, $pDomain, $oDomain
	Local $aDomains[100][2], $iDomains = 0
	Local $oRuntimeHost = DotNet_Start()
	$oRuntimeHost.EnumDomains( $pEnum )
	While Not $oRuntimeHost.NextDomain( $pEnum, $pDomain )
		$oDomain = ObjCreateInterface( $pDomain, $sIID__AppDomain, $sTag__AppDomain )
		$oDomain.get_FriendlyName( $aDomains[$iDomains][0] )
		$oDomain.get_BaseDirectory( $aDomains[$iDomains][1] )
		$iDomains += 1
	WEnd
	ReDim $aDomains[$iDomains][2]
	Return $aDomains
EndFunc

Func DotNet_ListDomainsEx()
	Local $aDomains = DotNet_ListDomains()
	_ArrayDisplay( $aDomains, ".NET Framework Domains", "", 0, Default, "Friendly Name|Base Directory to load assemblies" )
EndFunc

Func DotNet_ListAssemblies( $oAppDomain = 0 )
	Local $pAssemblies, $aAssemblies
	If Not $oAppDomain Then _
		$oAppDomain = DotNet_GetDefaultDomain()
	$oAppDomain.getAssemblies( $pAssemblies )
	AccVars_SafeArrayToArray( $pAssemblies, $aAssemblies )
	Local $nAsms = UBound( $aAssemblies ), $aAsmInfo[$nAsms][3], $oAssembly
	For $i = 0 To $nAsms - 1
		$oAssembly = ObjCreateInterface( $aAssemblies[$i], $sIID__Assembly, $sTag__Assembly )
		$oAssembly.get_GlobalAssemblyCache( $aAsmInfo[$i][0] )
		$oAssembly.get_FullName( $aAsmInfo[$i][1] )
		$oAssembly.get_Location( $aAsmInfo[$i][2] )
	Next
	Return $aAsmInfo
EndFunc

Func DotNet_ListAssembliesEx( $oAppDomain = 0 )
	Local $aAssemblies = DotNet_ListAssemblies( $oAppDomain )
	_ArrayDisplay( $aAssemblies, "Loaded Assemblies in Domain", "", 0, Default, "GAC|Assembly Full Name|Assembly Location" )
EndFunc
