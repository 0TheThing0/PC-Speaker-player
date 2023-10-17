IRQ_Player:
push ds ax dx
cmp [Enable_Sound],0
je Endd

in al,61h
and al, 1111_1100b
out 61h,al

mov ds,[Current_datapos]
lodsw

mov [es:Value],ax
cmp ax,-32760
jb EndBX
fld [es:MainCoeff]
fild [es:Value]
fiadd [es:Mid]
fdivp ST1,ST0
fistp [es:Value]

in al,61h
test al,3
jnz A99
or al, 0000_0011b
out 61h,al

mov al,0b6h
out 43h,al
; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
;~100√ц (0x2e9b) ~22050√ц(0036h)
A99:
mov bx,[es:Value]
mov al,bl
out 42h,al
mov al,bh
out 42h,al
jmp Endd

EndBX:
in al,61h
and al, 1111_1100b
out 61h,al

Endd:
pop dx ax ds

mov AL,20h
out 20h,AL
iret

IRQ_Restore:
CLI
push DS
mov DX,[IRQ0_Offset]
mov AX,[IRQ0_Segment]
mov DS,AX
mov AH,25h
mov AL,08h
int 21h           ;??????????????? ??????
pop DS
STI
ret

Install_new_interrupt:
mov ax,3508h
int 21h
mov [IRQ0_Offset],bx
mov [IRQ0_Segment],es

mov ax,2508h
mov dx,IRQ_Player
int 21h
ret

Programming_PIT:
;In: Sampling rate in [SamplingRate]
;Use: ax,dx
push ax dx
mov dx,12h
mov ax,34ddh
div [Sampling_Rate]
mov dx,ax

mov al,34h
;0011 0100 ?? разобратьс€, почему 34
;1011 0110
out 43h,al
; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
;~100√ц (0x2e9b) ~22050√ц(0036h)
mov al,dl
out 40h,al
mov al,dh
out 40h,al
pop dx ax
ret