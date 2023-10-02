#RequireAdmin
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <ScreenCapture.au3>

HotKeySet("{F1}","myExit")
HotKeySet("{F2}","test1")
HotKeySet("{F3}","test2")
HotKeySet("{F4}","test3")
HotKeySet("{F6}","test4")

;configs (TODO: read from config file)
$rustWindowName = ""
$DiscordWebhookUrl = ""
$TelegramToken = ""
$TelegramChatID = ""

#Region ### START Koda GUI section ### Form=c:\users\liamw\desktop\rust_fishing_bot\gui.kxf
$Form1 = GUICreate("Rust Fishing Bot", 383, 419, 249, 166)
$Tab1 = GUICtrlCreateTab(8, 8, 369, 401)
$TabSheet1 = GUICtrlCreateTabItem("TabSheet1")
$Group1 = GUICtrlCreateGroup("What should I gut always?", 168, 40, 201, 105)
$Checkbox1 = GUICtrlCreateCheckbox("Anchovy", 176, 56, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox2 = GUICtrlCreateCheckbox("Catfish", 176, 72, 97, 17)
$Checkbox3 = GUICtrlCreateCheckbox("Herring", 176, 88, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox4 = GUICtrlCreateCheckbox("Minnows", 176, 104, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox5 = GUICtrlCreateCheckbox("Orange Roughy", 176, 120, 97, 17)
$Checkbox6 = GUICtrlCreateCheckbox("Salmon", 280, 56, 97, 17)
$Checkbox7 = GUICtrlCreateCheckbox("Sardines", 280, 72, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox8 = GUICtrlCreateCheckbox("Small Sharks", 280, 88, 97, 17)
$Checkbox9 = GUICtrlCreateCheckbox("Small Trout", 280, 104, 97, 17)
$Checkbox10 = GUICtrlCreateCheckbox("Yellow Perch", 280, 120, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Where am i fishing?", 168, 256, 121, 57)
$Radio1 = GUICtrlCreateRadio("Fishing base", 176, 272, 113, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Radio2 = GUICtrlCreateRadio("Anyhwere else", 176, 288, 137, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("What should I drop?", 24, 197, 137, 153)
$Checkbox11 = GUICtrlCreateCheckbox("Broken fishing rod", 32, 213, 113, 17)
$Checkbox12 = GUICtrlCreateCheckbox("Bone Fragments", 32, 229, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox13 = GUICtrlCreateCheckbox("Animal Fat", 32, 245, 97, 17)
$Checkbox14 = GUICtrlCreateCheckbox("Scrap", 32, 261, 97, 17)
$Checkbox15 = GUICtrlCreateCheckbox("Blue Keycard", 32, 277, 97, 17)
$Checkbox16 = GUICtrlCreateCheckbox("Cloth", 32, 293, 97, 17)
$Checkbox17 = GUICtrlCreateCheckbox("Pistol Bullet", 32, 309, 97, 17)
$Checkbox18 = GUICtrlCreateCheckbox("Flare", 32, 325, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group4 = GUICtrlCreateGroup("Notifcations?", 24, 40, 137, 153)
$Label1 = GUICtrlCreateLabel("Discord webhook", 32, 64, 87, 17)
$Label2 = GUICtrlCreateLabel("Telegram token", 32, 104, 78, 17)
GUICtrlCreateInput("", 32, 80, 121, 21)
GUICtrlCreateInput("", 32, 120, 121, 21)
$Label3 = GUICtrlCreateLabel("Telegram chat ID", 32, 144, 86, 17)
GUICtrlCreateInput("", 32, 160, 121, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button1 = GUICtrlCreateButton("Run", 24, 357, 339, 41)
$Button2 = GUICtrlCreateButton("Tackle detection", 272, 320, 91, 25)
$Button4 = GUICtrlCreateButton("Autoit setup wizard", 168, 320, 99, 25)
$Group5 = GUICtrlCreateGroup("What should I gut when in need?", 166, 149, 201, 105)
$Checkbox19 = GUICtrlCreateCheckbox("Anchovy", 174, 165, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox20 = GUICtrlCreateCheckbox("Catfish", 174, 181, 97, 17)
$Checkbox21 = GUICtrlCreateCheckbox("Herring", 174, 197, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox22 = GUICtrlCreateCheckbox("Minnows", 174, 213, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox23 = GUICtrlCreateCheckbox("Orange Roughy", 174, 229, 97, 17)
$Checkbox24 = GUICtrlCreateCheckbox("Salmon", 278, 165, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox25 = GUICtrlCreateCheckbox("Sardines", 278, 181, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox26 = GUICtrlCreateCheckbox("Small Sharks", 278, 197, 97, 17)
$Checkbox27 = GUICtrlCreateCheckbox("Small Trout", 278, 213, 97, 17)
$Checkbox28 = GUICtrlCreateCheckbox("Yellow Perch", 278, 229, 97, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group6 = GUICtrlCreateGroup("Up-cycle", 296, 256, 70, 57)
$Checkbox29 = GUICtrlCreateCheckbox("Trout", 304, 272, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$Checkbox30 = GUICtrlCreateCheckbox("Salmon", 304, 288, 57, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$TabSheet2 = GUICtrlCreateTabItem("TabSheet2")
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region ### START SETUP
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
#EndRegion

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

func ocrRectWaitUntil($x, $y, $w, $h, $timeOut = 100)
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
		return "OCR_ERROR"
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
		return "OCR_ERROR"
	Else
		FileDelete(String("ocr"&$id&".jpg"))
		return $oDict.Item(String($id&"string"))
	EndIf
EndFunc

Func DiscordWebhook($Message)
    Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
    Local $Packet = '{"content": "' & $Message & '"}'
    $oHTTP.open('POST',$DiscordWebhookUrl)
    $oHTTP.setRequestHeader("Content-Type","application/json")
    $oHTTP.send($Packet)
EndFunc

Func TelegramWebhook($Message)
	Local $Url = "https://api.telegram.org/bot"&$TelegramToken&"/sendMessage"
    Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	Local $Packet = '{"chat_id:"'&$TelegramChatID&',"text": "' & $Message & '"}'
	$oHTTP.open('POST',$Url)
	$oHTTP.setRequestHeader("Content-Type","application/json")
    $oHTTP.send($Packet)
EndFunc

func myExit()
	ProcessClose("python.exe")
	ProcessClose("ipc_server.exe")
	Exit
EndFunc