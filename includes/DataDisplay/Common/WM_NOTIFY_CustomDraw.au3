Local $tNMLVCUSTOMDRAW = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;dword dwDrawStage;handle hdc;long Left;long Top;long Right;long Bottom;dword_ptr dwItemSpec;uint uItemState;lparam lItemlParam;dword clrText;dword clrTextBk;int iSubItem;dword dwItemType;dword clrFace;int iIconEffect;int iIconPhase;int iPartId;int iStateId;long TextLeft;long TextTop;long TextRight;long TextBottom;uint uAlign", $lParam ) ; $tagNMLVCUSTOMDRAW
Switch DllStructGetData( $tNMLVCUSTOMDRAW, "dwDrawStage" )          ; Holds a value that specifies the drawing stage
	Case 0x00000001              ; $CDDS_PREPAINT                     ; Before the paint cycle begins
		Return 0x00000020          ; $CDRF_NOTIFYITEMDRAW               ; Notify the parent window of any item-related drawing operations
	Case 0x00010001              ; $CDDS_ITEMPREPAINT                 ; Before painting an item
		Return 0x00000020          ; $CDRF_NOTIFYSUBITEMDRAW            ; Notify the parent window of any subitem-related drawing operations
	Case 0x00010001 + 0x00020000 ; $CDDS_ITEMPREPAINT + $CDDS_SUBITEM ; Before painting a subitem
		DllStructSetData( $tNMLVCUSTOMDRAW, "ClrTextBk", $aColors[DllStructGetData($tNMLVCUSTOMDRAW,"iSubItem")] )
		Return 0x00000002          ; $CDRF_NEWFONT                      ; $CDRF_NEWFONT must be returned after changing font or colors
EndSwitch
Return
