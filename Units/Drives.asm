CountDrives:
push ax bx cx di dx

mov di,DrivesList+2

mov cl,[DrivesAmount]

push es
mov ax,150dh
mov bx,DrivesList+2
int 2fh
pop es

     mov bx,DrivesList+2
     CDCounter:
        cmp byte[bx],0
        je NoCDCount
    inc byte[bx]
    mov al,byte[bx]
    cmp al,[CurrentDrive]
    jne _NoCurrentCDDrive
      mov [CurrentDrivePos],cl

    _NoCurrentCDDrive:
    inc bx
    inc cx
    jmp CDCounter
    NoCDCount:


mov di,DrivesList
mov ch,0
add di,cx

mov ah,32h
mov dl,3

DirveCountLooper:
        mov bx,DrivesList
        SearchingCDDrive:
                cmp byte[bx],dl
                je _NoDrive
        inc bx
        cmp byte[bx],0
        jne SearchingCDDrive

        GetNoCDDrive:
        push ds
        int 21h
        pop ds

        cmp al,0
        jne _NoDrive
            mov al,dl
            stosb

            inc cl
            cmp dl,[CurrentDrive]
            jne _NoCurrentDrive
                mov [CurrentDrivePos],cl
                dec byte[CurrentDrivePos]
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
                mov al,0BFh
                mov cl,00h
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
        cmp byte[DrivesAmount],9
        ja NoAdd
           add di,160
        NoAdd:
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
                add byte[ds:si],'@'
                movsb

                inc di
                mov byte[es:di],']'
                add di,ax

          loop .Looper

          sub di,72
          add di,160
       cmp bl,0
       jne DrawLoop
       pop es
ret
Empty_INT_24H:
iret

Remove_INT_24H:
        push es
        mov ah,35h
        mov al,24h
        int 21h
        mov [sOLD_INT_24H],es
        mov [oOLD_INT_24H],bx
        pop es

        mov ah,25h
        mov al,24h
        mov dx,Empty_INT_24H
        int 21h
ret

Restore_INT_24H:
        push ds

        mov ah,25h
        mov al,24h
        mov dx,[oOLD_INT_24H]
        mov ds,[es:sOLD_INT_24H]
        int 21h
        pop ds
ret
