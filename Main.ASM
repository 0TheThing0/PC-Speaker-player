org 100h
FileStart = $
BASE_HEAR_SOUND equ 24000
BASE_SAMPLE_VALUE equ 1234ddh
BASE_SAMPLE_SIZE equ 65535
SIZE_OFFSET equ 4

EXTRA_SIZE      = 64*1024     ; Allocate 64KiB above stack
PARA_SIZE       = 16           ; A paragraph = 16 bytes
EXTRA_SIZE_PARA = (EXTRA_SIZE+PARA_SIZE-1)/PARA_SIZE

Main:
finit
call Allocate_Memory
call Open_File
call Read_Header
call Programming_PIT
call Install_new_interrupt


call Count_Sound_Coeff

push ds
pop es
mov [Code_Segment],ds

Next_block:
cmp dword[WAVFile_Data+SIZE_OFFSET],64000
jae GetFull
;Get low
mov cx,word[WAVFile_Data+SIZE_OFFSET]
shr cx,1
jmp Next
GetFull:
mov cx,32000

Next:
xor si,si

call Load_FilePart

or al, 0000_0011b
out 61h,al

mov ah,09h
mov dx,Alright
int 21h

mov [Enable_Sound],1
Looper:
hlt
loop Looper
mov [Enable_Sound],0

cmp dword[WAVFile_Data+SIZE_OFFSET],100
jbe _End

jmp Next_block
_End:

mov ah,09h
mov dx,Done
int 21h

in al,61h
and al, 1111_1100b
out 61h,al
call IRQ_Restore
call Close_File
call Restore_memory
ret

include "Units\Sound.c"
include "Units\DataLoader.c"
include "Units\Interrupts.c"
include "Units\Math.c"

include "Units\Interrupts.di"
include "Units\DataLoader.di"
WAVFile_Data db 44 dup ?
Enable_Sound db 0

Code_Segment dw ?
Value dw 0
Mid dd 32769
MainCoeff dd ?
SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND
Alright db 'alright',13,10,'$'
Done db 'done$'

FileSize = 1000h
