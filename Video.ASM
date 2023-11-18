org 100h
call SetVideoMode
call SetTemplate
call GetDfltDir
call CreateBaseDirPath


call GetDirectoryData
call OutputDirectory

mov ah,01h
int 21h

call RestoreVideoMode
ret

include 'Units\VideoInclude.c'
include 'Units\FileManage.c'

include 'Units\VideoInclude.di'
include 'Units\FileManage.di'



virtual at 0
  SourceFile::
    file 'BITMAP.BIN'
end virtual

BITMAP:
repeat 4000
  load x byte from SourceFile: % - 1
  db x
end repeat