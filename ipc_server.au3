Opt( "MustDeclareVars", 1 )

#include <GUIConstantsEx.au3>
#include "includes/IRunningObjectTable.au3"
Server()

Func Server()
	; Create a default ROT-object (Dictionary object)
	; The script that creates the ROT object is the server
	; The ROT object is available while the server is running
	Local $sDataTransferObject = "DataTransferObject"
	ROT_CreateDefaultObject( $sDataTransferObject, 0 ) ; 0 -> Non-unique

	Local $oDict = ObjGet("DataTransferObject")

	; Loop
	While 1
		if $oDict.Item("exit") = True Then
			Exit
		EndIf
	WEnd
EndFunc