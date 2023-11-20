ProcessKeyboard:
   mov ah,01h
   int 16h
   jz _NoKey
      mov ah,00h
      int 16h

      cmp ah,48h; Up
      je Up_Key

      cmp ah,50h
      je Down_Key

      cmp ah,1h
      je Esc_Key

      cmp ah,1ch
      je Enter_Key
      jmp _NoKey

    Up_Key:
        mov ax,-1
        cmp [CurrentFile],0
        jne ProcessInside
        call StepUp
        jmp _NoKey

    Down_Key:
        mov ax,[FirstShowFile]
        add ax,[CurrentFile]
        inc ax
        cmp ax,[FilesAmount]
        jae _NoKey
        mov ax,1
        cmp [CurrentFile],MAX_FILES_AMOUNT-1
        jne ProcessInside
        call StepDown
        jmp _NoKey

    Esc_Key:
        mov [EndProg],1
        jmp _NoKey

    Enter_Key:
        call ProcessFile
        jmp _NoKey

    ProcessInside:
        call DrawChooseLine
        add word[CurrentFile],ax
        call DrawChooseLine
   _NoKey:
ret

StepUp:
    cmp [FirstShowFile],0
    je .End
    dec word[FirstShowFile]
    mov [CurrentRow], WINDOW_START_LINE
    call OutputDirectory
    call DrawChooseLine
    .End:
ret

StepDown:
    mov ax,[FilesAmount]
    sub ax,MAX_FILES_AMOUNT
    cmp [FirstShowFile],ax
    jg .End
    inc word[FirstShowFile]
    mov [CurrentRow], WINDOW_START_LINE

    call OutputDirectory
    call DrawChooseLine
    .End:
ret