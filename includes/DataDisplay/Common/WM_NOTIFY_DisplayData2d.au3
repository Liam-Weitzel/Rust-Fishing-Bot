Local $tNMLVDISPINFO = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
If Not BitAND( DllStructGetData( $tNMLVDISPINFO, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
Local $iItem = DllStructGetData( $tNMLVDISPINFO, "Item" ) - $iFrom
If $iItem < 0 Or $iItem > $iTo - $iFrom Then Return
Local $iSubItem = DllStructGetData($tNMLVDISPINFO,"SubItem")
DllStructSetData( $tText, 1, $iSubItem ? $aDisplay[$iItem][$iSubItem-1] : "[" & StringRegExpReplace( $iItem + $iFrom, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
DllStructSetData( $tNMLVDISPINFO, "Text", $pText )
Return
