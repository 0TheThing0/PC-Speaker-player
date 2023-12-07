;Video params
VIDEO_MODE = 03h
NORMAL_COLOR = 1fh
CHOOSED_COLOR = 20h
WINDOW_START_LINE = 6
WINDOW_LEFT_ROW = 2
LINE_LENGTH = 80
pWINDOW_START_LINE_OFFSET = WINDOW_START_LINE * LINE_LENGTH + WINDOW_LEFT_ROW
NORMAL_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_0000b
RENEW_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_1111b
NORMAL_STRING_SIZE = 14;36
MAX_FILES_AMOUNT = 17
WINDOWS_AMOUNT = 2


;Drives
DRIVES_START_LINE = 1
DRIVES_START_ROW = 1
pDRIVES_START_LINE_OFFSET = DRIVES_START_LINE * LINE_LENGTH * 2 + DRIVES_START_ROW*2

;Struct Size
FileRecInfo_SIZE = 43
KEY_POINTS_AMOUNT = 32
KeyPoints_SIZE = KEY_POINTS_AMOUNT*FileRecInfo_SIZE


;MUSIC
BASE_HEAR_SOUND = 30000
BASE_SAMPLE_VALUE = 1234ddh
BASE_SAMPLE_SIZE = 65535
SIZE_OFFSET = 4
BASE_A_COEF = 0.1
BASE_NA_COEF = 1-BASE_A_COEF

BLOCK_SIZE_IN_BYTES = 64000
BLOCK_SIZE_IN_CHUNKS = BLOCK_SIZE_IN_BYTES/16
BLOCK_SIZE_IN_WORD = BLOCK_SIZE_IN_BYTES/2



org 100h
;Allocating memory for buffer
call Allocate_Memory

call SetVideoMode
call SetTemplate
call GetDTA

mov ah,19h
int 21h
inc al
mov [CurrentDrive],al

call Remove_INT_24H

call CountDrives

call OutputDrives
call DrawChooseDrive

call CreateBaseDirPath

call OpenDirectory

MainProcess:
        call ProcessKeyboard
cmp [EndProg],0
je MainProcess

call Restore_INT_24H
call RestoreVideoMode

;Asking for memory restoration
call Restore_memory
ret

include 'Units\Keyboard.c'
include 'Units\Drives.c'
include 'Units\VideoInclude.c'
include 'Units\FileManage.c'
include "Units\DataLoader.c"
include "Units\Interrupts.c"
include "Units\Math.c"
include 'Units\PlayPart.c'

include 'Units\Keyboard.di'
include 'Units\Drives.di'
include 'Units\VideoInclude.di'
include 'Units\FileManage.di'
include 'Units\PlayPart.di'


include "Units\Interrupts.di"
include "Units\DataLoader.di"




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
