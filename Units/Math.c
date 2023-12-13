Count_Sound_Coeff:
fild [SampleValue]
fmul [SamplingSize]
fdiv [SoundCoeff]
fstp [MainCoeff]
ret

Count_Time:
push bx ax dx
;in bx - data segment
        mov dx,word[TimeInSeconds+2]
        mov ax,word[TimeInSeconds]
        mov bx,3600
        div bx    ; AX - Hours ;DX - Seconds
        mov [TrackHours],al
        mov ax,dx
        mov bl,60
        div bl ;AL - Minutes AH - Seconds
        mov [TrackMinutes],al
        mov [TrackSeconds],ah
pop dx ax bx
ret

RandomInitialize:
push es
push 0040
pop es
mov ax,[es:006eh]
mov [RandSeed],ax
pop es
ret


RandomNumber:
;in cx - low value
        PUSH cx bx dx
        mov bx,cx
        mov ax, [RandSeed]
        ;xor     edx, edx
        ;mov     ecx, 69069
        ;mul     ecx
        ;adc     eax, 5
        ;rol      eax, 32
        ;adc      eax, 23
        mov     cx, 8085h                     ;or: imul    edx, seed, 8088405h
        xor     dx, dx
        mul     cx
        add     ax,1234h
        mov     [RandSeed],ax
        xor dx,dx
        div     bx
        mov     ax, dx
        pop dx bx cx
        ;Res - in ax
ret

InitializeArray:
mov dl,cl
mov cl,[CurrentPlaylistAmount]
mov bx,PlayOrder
.Looper:
        mov byte[bx],cl
        dec byte[bx]
        inc bx
loop .Looper

mov bx,PlayOrder
add bl,[CurrentPlaylistAmount]
adc bh,0
dec bx

mov cl,[CurrentPlaylistAmount]
dec cl
.Looper2:
        call RandomNumber
        mov di,PlayOrder
        add di,ax
        mov al,byte[bx]
        xchg byte[di],al
        xchg al,byte[bx]
        dec bx
loop .Looper2

mov cl,[CurrentPlaylistAmount]
mov bx,PlayOrder
.Looper3:
        cmp byte[bx],dl
        je InitializeArrayEnd
        inc bx
loop .Looper3

InitializeArrayEnd:
mov [OrderPos],bx
ret



