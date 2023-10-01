#RequireAdmin
HotKeySet("{F1}","myExit")
HotKeySet("{F2}","test1")
HotKeySet("{F3}","test2")
HotKeySet("{F4}","test3")

;configs (TODO: read from config file)
$rustWindowName = "*Untitled - Notepad"

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <ScreenCapture.au3>
#Region ### START Koda GUI section ### Form=c:\users\liamw\desktop\rust_fishing_bot\gui.kxf
$Form1 = GUICreate("Rust Fishing Bot", 383, 396, 240, 123)
$Tab1 = GUICtrlCreateTab(8, 8, 369, 377)
$TabSheet1 = GUICtrlCreateTabItem("TabSheet1")
$Group1 = GUICtrlCreateGroup("What should I gut always?", 24, 40, 201, 105)
$Checkbox1 = GUICtrlCreateCheckbox("Anchovy", 32, 56, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox2 = GUICtrlCreateCheckbox("Catfish", 32, 72, 97, 17)
$Checkbox3 = GUICtrlCreateCheckbox("Herring", 32, 88, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox4 = GUICtrlCreateCheckbox("Minnows", 32, 104, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox5 = GUICtrlCreateCheckbox("Orange Roughy", 32, 120, 97, 17)
$Checkbox6 = GUICtrlCreateCheckbox("Salmon", 136, 56, 97, 17)
$Checkbox7 = GUICtrlCreateCheckbox("Sardines", 136, 72, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox8 = GUICtrlCreateCheckbox("Small Sharks", 136, 88, 97, 17)
$Checkbox9 = GUICtrlCreateCheckbox("Small Trout", 136, 104, 97, 17)
$Checkbox10 = GUICtrlCreateCheckbox("Yellow Perch", 136, 120, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Where am i fishing?", 232, 160, 129, 57)
$Radio1 = GUICtrlCreateRadio("Fishing village", 240, 176, 113, 17)
$Radio2 = GUICtrlCreateRadio("Lamo's fishing base", 240, 192, 137, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("What should I drop?", 232, 224, 121, 153)
$Checkbox11 = GUICtrlCreateCheckbox("Broken fishing rod", 240, 240, 113, 17)
$Checkbox12 = GUICtrlCreateCheckbox("Bone Fragments", 240, 256, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox13 = GUICtrlCreateCheckbox("Animal Fat", 240, 272, 97, 17)
$Checkbox14 = GUICtrlCreateCheckbox("Scrap", 240, 288, 97, 17)
$Checkbox15 = GUICtrlCreateCheckbox("Blue Keycard", 240, 304, 97, 17)
$Checkbox16 = GUICtrlCreateCheckbox("Cloth", 240, 320, 97, 17)
$Checkbox17 = GUICtrlCreateCheckbox("Pistol Bullet", 240, 336, 97, 17)
$Checkbox18 = GUICtrlCreateCheckbox("Flare", 240, 352, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Notifcations?", 232, 40, 137, 113)
$Label1 = GUICtrlCreateLabel("Discord webhook", 240, 64, 87, 17)
$Label2 = GUICtrlCreateLabel("Telegram webhook", 240, 104, 95, 17)
GUICtrlCreateInput("", 240, 80, 121, 21)
GUICtrlCreateInput("", 240, 120, 121, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button1 = GUICtrlCreateButton("Run", 24, 344, 67, 25)
$Button2 = GUICtrlCreateButton("Set up tackle detection", 24, 304, 123, 25)
$Button4 = GUICtrlCreateButton("Autoit setup wizard", 24, 264, 99, 25)
$Group5 = GUICtrlCreateGroup("What should I gut when in need?", 22, 149, 201, 105)
$Checkbox19 = GUICtrlCreateCheckbox("Anchovy", 30, 165, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox20 = GUICtrlCreateCheckbox("Catfish", 30, 181, 97, 17)
$Checkbox21 = GUICtrlCreateCheckbox("Herring", 30, 197, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox22 = GUICtrlCreateCheckbox("Minnows", 30, 213, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox23 = GUICtrlCreateCheckbox("Orange Roughy", 30, 229, 97, 17)
$Checkbox24 = GUICtrlCreateCheckbox("Salmon", 134, 165, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox25 = GUICtrlCreateCheckbox("Sardines", 134, 181, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox26 = GUICtrlCreateCheckbox("Small Sharks", 134, 197, 97, 17)
$Checkbox27 = GUICtrlCreateCheckbox("Small Trout", 134, 213, 97, 17)
$Checkbox28 = GUICtrlCreateCheckbox("Yellow Perch", 134, 229, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group6 = GUICtrlCreateGroup("Up-cycle", 152, 256, 73, 57)
$Checkbox29 = GUICtrlCreateCheckbox("Trout", 160, 272, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox30 = GUICtrlCreateCheckbox("Salmon", 160, 288, 57, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$TabSheet2 = GUICtrlCreateTabItem("TabSheet2")
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;Run the IPC Server
ShellExecute("ipc_server.exe", "", "", "", @SW_HIDE)
;Run( @AutoItExe & " /AutoIt3ExecuteScript " & "ipc_server.au3" )
If ProcessWait ("ipc_server.exe", 5) == 0 Then ;wait for IPC Server to start
	MsgBox(1, "Failed to IPC server", "Failed to start IPC Server. Script stopped")
	Exit
EndIf

; Get default ROT-object (Dictionary object) from IPC Server
$oDict = ObjGet( "DataTransferObject" )
$oDict.Item("tackleUI") = False

;Run the  python pic analysis server
ShellExecute("C:\python310\python.exe", "pic_analysis_server.py", "", "", @SW_HIDE)
If ProcessWait ("python.exe", 5) == 0 Then ;wait for server.py to start
	MsgBox(1, "Failed to start pic analysis server", "Failed to start python pic analysis server. Script stopped")
	ProcessClose("ipc_server.exe")
	Exit
EndIf


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $Button2
			; Get default ROT-object (Dictionary object)
			$oDict.Item("tackleUI") = True
		Case $GUI_EVENT_CLOSE
			ProcessClose("python.exe")
			ProcessClose("ipc_server.exe")
			Exit
	EndSwitch
WEnd

func ocrRectWaitUntil($x, $y, $w, $h, $timeOut)
	local $currOcrID = $oDict.Item("ocrID")+1
	_ScreenCapture_CaptureWnd(@WorkingDir & "\ocr"&$currOcrID&".jpg", $rustWindowName, $x, $y, $w, $h, False)
	$oDict.Item("ocrID") = $currOcrID
	$error = True
	For $i = 0 To $timeOut Step +1
		sleep(100)
		if($oDict.Item("ocrIDComplete") >= $currOcrID) Then
			$i = $timeOut
			$error = False
		EndIf
	Next
	if($error) then
		FileDelete(String("ocr"&$currOcrID&".jpg"))
		return "ERROR192939"
	Else
		FileDelete(String("ocr"&$currOcrID&".jpg"))
		return $oDict.Item(String($currOcrID&"string"))
	EndIf
EndFunc

func ocrRectAsync($x, $y, $w, $h)
	local $currOcrID = $oDict.Item("ocrID")+1
	_ScreenCapture_CaptureWnd(@WorkingDir & "\ocr"&$currOcrID&".jpg", $rustWindowName, $x, $y, $w, $h, False)
	$oDict.Item("ocrID") = $currOcrID
	Return $currOcrID
EndFunc

func ocrRectAwait($id, $timeOut)
	$error = True
	For $i = 0 To $timeOut Step +1
		if($oDict.Item("ocrIDComplete") >= $id) Then
			$i = $timeOut
			$error = False
		EndIf
		sleep(100)
	Next
	if($error) then
		FileDelete(String("ocr"&$id&".jpg"))
		return "ERROR192939"
	Else
		FileDelete(String("ocr"&$id&".jpg"))
		return $oDict.Item(String($id&"string"))
	EndIf
EndFunc

func test3()
	MsgBox(1, "OCR", ocrRectAwait(1, 100))
EndFunc

func test2()
	$ocrID = ocrRectAsync(0, 0, -1, -1)
	MsgBox(1, "OCR", ocrRectAwait($ocrID, 100))
EndFunc

func test1()
	$ocrText = ocrRectWaitUntil(0, 0, -1, -1, 100)
	if($ocrText == "ERROR192939") Then
		MsgBox(1, "ERROR", "OCR ERROR")
	Else
		MsgBox(1, "OCR", $ocrText)
	EndIf
EndFunc

func myExit()
	ProcessClose("python.exe")
	ProcessClose("ipc_server.exe")
	Exit
EndFunc