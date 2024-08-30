;Video params
VIDEO_MODE = 03h
NORMAL_COLOR = 1fh
CHOOSED_COLOR = 20h
WINDOW_START_LINE = 6
WINDOW_LEFT_COLUMN = 2
WINDOW_START_LINE = 6
WINDOW_RIGHT_COLUMN = 41
LINE_LENGTH = 80
pWINDOW_START_LINE_OFFSET = WINDOW_START_LINE * LINE_LENGTH + WINDOW_LEFT_COLUMN
NORMAL_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_0000b
ERROR_STRING_VIDEO_ATTRIBUTE = 0000_0000_0100_0000b
RENEW_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_1111b
INFO_STRING_VIDEO_ATTRIBUTE =  0000_0000_0001_1111b
NORMAL_STRING_SIZE = 14;36
MAX_FILES_AMOUNT = 17
WINDOWS_AMOUNT = 3
RANDOW_POS = 3992


;Drives
DRIVES_START_LINE = 1
DRIVES_START_ROW = 1
pDRIVES_START_LINE_OFFSET = DRIVES_START_LINE * LINE_LENGTH * 2 + DRIVES_START_ROW*2

;Struct Size
FileRecInfo_SIZE = 43
KEY_POINTS_AMOUNT = 32
KeyPoints_SIZE = KEY_POINTS_AMOUNT*FileRecInfo_SIZE


;MUSIC
BASE_HEAR_SOUND = 30000  ;This value is "magical". Depending on rate of audiofile this value should be changed
                         ; For 44100 Hz it's around 50000.
BASE_SAMPLE_VALUE = 1234ddh ;Rate of PIT
BASE_SAMPLE_SIZE = 65535 ;Amount of levels of sample
SIZE_OFFSET = 4

;There values are used for filter, but this is not required
BASE_A_COEF = 0.1
BASE_NA_COEF = 1-BASE_A_COEF

BLOCK_SIZE_IN_BYTES = 64000 ; Size of block to load
BLOCK_SIZE_IN_CHUNKS = BLOCK_SIZE_IN_BYTES/16
BLOCK_SIZE_IN_WORD = BLOCK_SIZE_IN_BYTES/2

TIME_COEFF = 0.0322580645

;Playlist
TRACK_AMOUNT = 50
FILEPATH_LENGTH = 256
ALLOCATE_PLAYLIST_MEMORY = TRACK_AMOUNT * FILEPATH_LENGTH /16
ACCEPTABLE_RATE = 22050

;PlayScreen
PLAYSCREEN_ROW = 8
PLAYSCREEN_LINE = 20
PLAYSCREEN_WIDTH = 39
PLAYSCREEN_HEIGHT = 9
PLAYSCREEN_START = (PLAYSCREEN_ROW*80 + PLAYSCREEN_LINE) * 2
PLAYSCREEN_STAGES = 31

org 100h
finit
fstcw [old_state]
or [old_state], 0000_0010_0000_0000b
and [old_state], 1111_1110_1111_1111b
fldcw [old_state]

;Allocating memory for buffer
call Set_VideoMode
call Set_Template

call Allocate_Memory
call Allocate_PlaylistMemory

call Get_DTA

mov ah,19h
int 21h
inc al
mov [CurrentDrive],al

call Remove_INT_24H

call CountDrives

call OutputDrives

call Create_BaseDirPath


call Open_Directory

MainProcess:
        call Process_Keyboard
cmp [EndProg],0
je MainProcess

call Restore_INT_24H
call Restore_VideoMode

;Asking for memory restoration
call Restore_Memory
ret

include "Units\Metadata.asm"
include 'Units\Keyboard.asm'
include 'Units\Drives.asm'
include 'Units\VideoInclude.asm'
include 'Units\FileManage.asm'
include "Units\DataLoader.asm"
include "Units\Interrupts.asm"
include "Units\Math.asm"
include 'Units\PlayPart.asm'

include 'Units\Keyboard.di'
include 'Units\Drives.di'
include 'Units\VideoInclude.di'
include 'Units\FileManage.di'
include 'Units\PlayPart.di'
include "Units\Interrupts.di"
include "Units\DataLoader.di"


virtual at 0
  LogoFile::
    file 'Units\LOGO.BIN'
end virtual

virtual at 0
  AssistFile::
    file 'Units\ASSIST.BIN'
end virtual

MaxPlaylistAmount db TRACK_AMOUNT
CurrentPlaylistAmount db 0
KeyPointsSpace dw 0
KeyPoints db (KeyPoints_SIZE) dup ?
EndProg db 0
EmptyString db 36 dup ' '

ASSIST:
repeat 160
  load x byte from AssistFile: % - 1
  db x
end repeat

LOGO:
repeat 440
  load x byte from LogoFile: % - 1
  db x
end repeat


OpenFileError:  db      '     This file cannot be played!     '
OpenDriveError:  db     '    This drive cannot be opened!     '     ;Need to redo drives counting
OpenDirError:  db       '  This directory cannot be opened!   '     ;Done????
AllocateMemoryError: db '   Fatal error: Not enough memory!   '     ;Done
FilesOverflowError:  db '     To many files in playlist!      '     ;Done
BaseName db 'Unknown'
ArtistString:  db       'Artist:                              '
TrackString:   db       'Track:                               '
EscPrint db '[ ESC ]'

include "Units\Metadata.di"
PLAYSCREEN: db 702 dup ?
PlayOrder db 50 dup ?
OrderPos dw ?
RandSeed dw ?
old_state dw ?
EndPlaylist db ?
