Local $tNmLvDispInfo = DllStructCreate( "struct;hwnd hWndFrom;uint_ptr IDFrom;int Code;endstruct;int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns", $lParam ) ; $tagNMLVDISPINFO
If Not BitAND( DllStructGetData( $tNmLvDispInfo, "Mask" ), 1 ) Then Return ; 1 = $LVIF_TEXT
Local $iItem = DllStructGetData( $tNmLvDispInfo, "Item" ) - $iFrom, $iSubItem = DllStructGetData( $tNmLvDispInfo, "SubItem" )
If $iItem < 0 Or $iItem > $iTo - $iFrom Then Return
DllStructSetData( $tText, 1, $iSubItem ? $aDisplay[$iItem][$iSubItem-1] : "[" & StringRegExpReplace( ($iItem+$iFrom)*$i1dColumns, "(\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))", "\1," ) & "]" )
DllStructSetData( $tNmLvDispInfo, "Text", $pText )
Return
