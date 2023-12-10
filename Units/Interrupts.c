IRQ_Player:
       push ax dx cx si es ds

       push cs
       pop es
       push cs
       pop ds
       ;is music on???
       cmp [es:EnableSound],0
       je _OffSound
       cmp [es:EndSound],1
       je _OffSound


       inc word[IntAmount]
       mov ax,[IntAmount]
       cmp ax,word[SamplingRate]
       jb .Next
           mov word[IntAmount],0
           inc dword[TimeInSeconds]
           call Count_Time
           mov di,PLAYSCREEN_START+(2+160*6)
           call FillTimeScreen
           call RedrawTimeLine
       .Next:
       ;Getting current offset
       mov si,[es:oMusicBuffer]
       cmp si,BLOCK_SIZE_IN_BYTES
       jb ReadNote
                ;CMP avaible block with base size
                cmp dword[es:WAVFileData+SIZE_OFFSET],0
                jne _GetFullChunk
                ;Get low
                mov [es:EndSound],1
                mov [es:LoadData],0
                jmp _RNEnd

                _GetFullChunk:
                mov [es:oMusicBuffer],0
                mov [es:LoadData],1
                jmp _RNEnd

ReadNote:
        mov ds,[es:sMusicBuffer]
        ; I'm not sure in lodsw. SOMETHING STRANGE
        mov ax,[ds:si]
        add [es:oMusicBuffer],2

        ;Music counting
        ;TO DO: Redo + filter
        fild word[ds:si]
        fiadd [es:Mid]
        fdivr [es:MainCoeff]
        fmul [es:NACoeff]

        fild [es:Value]
        fmul [es:ACoeff]

        faddp ST1, ST0
        fistp word[es:Value]
        cmp [es:Value],0
        je _OffSound

        ;Test pc speaker
        in al,61h
        ;test al, 0000_0011b
        ;jnz _AlreadyInclude

        ;Include pc speaker
        or al, 0000_0011b
        out 61h,al

_AlreadyInclude:
        mov al,0b6h
        out 43h,al
        ; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
        ;~100√ц (0x2e9b) ~22050√ц(0036h)

        mov bx,[es:Value]
        mov al,bl
        out 42h,al

        mov al,bh
        out 42h,al
        jmp _RNEnd

_OffSound:
        in al,61h
        and al, 1111_1100b
        out 61h,al
_RNEnd:
        mov AL,20h
        out 20h,AL
pop ds es si cx dx ax
iret

IRQ_Restore:
        push dx ds
        mov DX,[IRQ0_Offset]
        mov DS,[IRQ0_Segment]
        mov AX,2508h
        int 21h
        ;mov [Sampling_Rate],65536
        ;call Programming_PIT
        pop ds dx
ret


Install_new_interrupt:
        push bx dx es
        ;Get interrupt number (00h to FFh)
        mov ax,3508h
        int 21h
        ;es:bx address of interrupt handler
        mov [IRQ0_Offset],bx
        mov [IRQ0_Segment],es

        ;Set new irq interrupt
        mov ax,2508h
        mov dx,IRQ_Player
        int 21h
        pop es dx bx
ret

Programming_PIT:
        ;In: Sampling rate in [SamplingRate]
        push dx
        mov dx,12h
        mov ax,34ddh
        div [SamplingRate]
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
        pop dx
ret

Restore_PIT:
        mov al,34h
        ;0011 0100 ?? разобратьс€, почему 34
        ;1011 0110
        out 43h,al
        ; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
        ;~100√ц (0x2e9b) ~22050√ц(0036h)
        mov al,0FFh
        out 40h,al
        out 40h,al
ret

