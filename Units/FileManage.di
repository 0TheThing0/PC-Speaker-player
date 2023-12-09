sDTA dw ?
oDTA dw ?

SearchName db '\*.*',0
NameString  db 14 dup 0
CurrentDir db 256 dup 0
CurrentDirStart dw CurrentDir+3
FilesAmount dw 0
CurrentFile dw 0
FirstShowFile dw 0

PrevHeadDirPos dw 0
PrevDirPos dw 0

PlaylistBuffer dw ?
CurrentPlaylistFile db 0
FirstShowPlaylistFile db 0