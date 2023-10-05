org 100h
jmp Main
include "Units\Sound.c"
include "Units\DataLoader.c"
include "Units\Interrupts.c"
Main:

finit
call Open_File
call Programming_PIT
call Install_new_interrupt

push ds
pop es

mov cx,32000
mov dx,10Eh

Next_block:
xor bx,bx
call Load_FilePart
mov [Enable_Sound],1
or al, 0000_0011b
out 61h,al
Looper:
hlt
loop Looper

mov [Enable_Sound],0
dec dx
cmp dx,0
je _End
mov cx,32000


jmp Next_block
_End:

in al,61h
and al, 1111_1100b
out 61h,al
call IRQ_Restore
ret
include "Units\Interrupts.di"
include "Units\DataLoader.di"
WAVFile_Data db 128 dup ?
WAVFile_Size dd ?
Enable_Sound db 0
Coeff dd 0.0055 ;??????    ;0.0008
Value dw ?
Sum dd 32800