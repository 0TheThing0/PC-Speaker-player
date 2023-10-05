C:
mov bx,ax

;mov dx,12h
;mov ax,34ddh
;div bx

mov al,0b6h
out 43h,al
; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
;~100√ц (0x2e9b) ~22050√ц(0036h)
mov al,bl
out 42h,al
mov al,bh
out 42h,al
ret