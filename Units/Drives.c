CountDrives:
push ax bx cx di dx
mov ah,32h
mov cl,0
mov di,DrivesList
mov dl,1

DirveCountLooper:
        push ds
        int 21h
        pop ds

        cmp al,0
        jne _NoDrive
            mov al,dl
            add al,'@'
            stosb

            inc cl
            cmp dl,[CurrentDrive]
            jne _NoCurrentDrive
                mov [CurrentDrivPos],cl
            _NoCurrentDrive:
        _NoDrive:
inc dl
cmp dl,27
jne DirveCountLooper
mov [DrivesAmount],cl

pop dx di cx bx ax
ret

CountOffsets:
        push bx cx
        cmp al,1
        je _OneElem
        mov ch,al
        dec ch

        mov bl,3
        mul bl
        mov bx,35
        sub bx,ax
        mov cl,0
        .Looper:
            mov ax,bx
            div ch
            cmp ah,0
            je _EndCount
            sub bx,2
            inc cl
        jmp .Looper

        _OneElem:
                mov ax,0C0h
        _EndCount:
        inc al
        mov ah,cl
        pop cx bx
ret

OutputDrives:
        push es

        push 0xb800
        pop es

        mov di,pDRIVES_START_LINE_OFFSET
        mov si,DrivesList
        mov bl,[DrivesAmount]
        DrawLoop:
          mov al,9
          cmp bl,9
          ja GetALL
          mov al,bl
          GetALL:
          sub bl,al

          movzx cx,al
          call CountOffsets ;in al - amount of disks; return in al - between disks, ah - from left and right borders
          shl al,1
          shl ah,1
          movzx dx,ah
          mov ah,0

          add di,dx
          .Looper:
                mov byte[es:di],'['
                inc di

                inc di
                movsb

                inc di
                mov byte[es:di],']'
                add di,ax

          loop .Looper

          sub di,ax
          add di,dx
          sub di,35
          add di,160
       cmp bl,0
       jne DrawLoop
       pop es
ret
