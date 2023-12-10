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