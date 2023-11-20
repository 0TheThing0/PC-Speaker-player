;Video params
VIDEO_MODE = 03h
NORMAL_COLOR = 1fh
CHOOSED_COLOR = 20h
WINDOW_START_LINE = 6
WINDOW_LEFT_OFFSET = 2
LINE_LENGTH = 80
pWINDOW_START_LINE_OFFSET = WINDOW_START_LINE * LINE_LENGTH + WINDOW_LEFT_OFFSET
NORMAL_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_0000b
RENEW_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_1111b
NORMAL_STRING_SIZE = 14;36
MAX_FILES_AMOUNT = 17

;Struct Size
FileRecInfo_SIZE = 43
KEY_POINTS_AMOUNT = 32
KeyPoints_SIZE = KEY_POINTS_AMOUNT*FileRecInfo_SIZE

org 100h
call SetVideoMode
call SetTemplate
call GetDTA
call CreateBaseDirPath


call OpenDirectory

MainProcess:
        call ProcessKeyboard

cmp [EndProg],0
je MainProcess

call RestoreVideoMode
ret

include 'Units\Keyboard.c'
include 'Units\VideoInclude.c'
include 'Units\FileManage.c'

include 'Units\VideoInclude.di'
include 'Units\FileManage.di'

virtual at 0
  SourceFile::
    file 'Units\BITMAP.BIN'
end virtual

KeyPointsSpace dw 0
KeyPoints db (KeyPoints_SIZE) dup ?
EndProg db 0
EmptyString db 221,36 dup ' ',222
BITMAP:
repeat 4000
  load x byte from SourceFile: % - 1
  db x
end repeat
