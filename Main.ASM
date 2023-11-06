org 100h
BASE_HEAR_SOUND = 30000
BASE_SAMPLE_VALUE = 1234ddh
BASE_SAMPLE_SIZE = 65535
SIZE_OFFSET = 4
BASE_A_COEF = 0.2
BASE_NA_COEF = 1-BASE_A_COEF

BLOCK_SIZE_IN_BYTES = 64000
BLOCK_SIZE_IN_CHUNKS = BLOCK_SIZE_IN_BYTES/16
BLOCK_SIZE_IN_WORD = BLOCK_SIZE_IN_BYTES/2

Main:
finit
;Allocating memory for buffer
call Allocate_Memory


;Reading file address
mov ah,0ah
mov dx,MusicFile
int 21h

mov bx,MusicFile
add bl,byte[MusicFile+1]
adc bh,0
add bx,2
mov byte[bx],0
;Openning file
call Open_File

;Reading header data
call Read_Header

;Counting sound coeff
call Count_Sound_Coeff

;Reprogramming PIT for correct rate
call Programming_PIT

;Set new interrupt
call Install_new_interrupt

;First load
mov cx,16000
call Load_FilePart

;Music cycle
mov [EnableSound],1

Next_block:
cmp [EndSound],0
je Next_block

;OFFSound
mov [EnableSound],0
mov ah,09h
mov dx,Done
int 21h

;OFF pc speaker
in al,61h
and al, 1111_1100b
out 61h,al

;Restore IRQ
call IRQ_Restore
;Close file
call Close_File
;Asking for memory restoration
call Restore_memory
ret

;include "Units\Sound.c"
include "Units\DataLoader.c"
include "Units\Interrupts.c"
include "Units\Math.c"

include "Units\Interrupts.di"
include "Units\DataLoader.di"

WAVFileData db 44 dup ?
EnableSound db 0

Value dw 0
Mid dd 32769
MainCoeff dd ?

SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND
ACoeff dd 0.3
NACoeff dd 0.7
SamplingRate dw ?
EndSound db 0
Done db 'done',13,10,'$'