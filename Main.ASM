org 100h

BASE_HEAR_SOUND equ 24000
BASE_SAMPLE_VALUE equ 1234ddh
BASE_SAMPLE_SIZE equ 65535
SIZE_OFFSET equ 4
jmp Main
include "Units\Sound.c"
include "Units\DataLoader.c"
include "Units\Interrupts.c"
include "Units\Math.c"
Main:

finit
call Open_File
call Read_Header
call Programming_PIT
call Install_new_interrupt


call Count_Sound_Coeff

push ds
pop es

Next_block:
cmp dword[WAVFile_Data+SIZE_OFFSET],64000
ja GetFull
;Get low
mov cx,word[WAVFile_Data+SIZE_OFFSET]
shr cx,1
jmp Next
GetFull:
mov cx,32000
Next:
xor si,si
call Load_FilePart
mov [Enable_Sound],1
or al, 0000_0011b
out 61h,al

Looper:
hlt
loop Looper

mov [Enable_Sound],0
cmp dword[WAVFile_Data+SIZE_OFFSET],100
jbe _End

jmp Next_block
_End:

in al,61h
and al, 1111_1100b
out 61h,al
call IRQ_Restore
ret
include "Units\Interrupts.di"
include "Units\DataLoader.di"
WAVFile_Data db 44 dup ?
Enable_Sound db 0

Value dw 0
Mid dd 32769
MainCoeff dd ?
SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND
