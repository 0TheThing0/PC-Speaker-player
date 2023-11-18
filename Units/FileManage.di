sDTA dw ?
oDTA dw ?

SearchName db '\*.*',0
String db 14 dup ?
CurrentDir db 256 dup 0
CurrentDirStart dw CurrentDir+3
DefDrive db ?
FilesAmount dw 0
CurrentFile dw 0
FirstShowFile dw 0