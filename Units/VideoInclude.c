SetVideoMode:
        mov ah,0fh
        int 10h
        mov [OldVideoMode],al

        mov ah,00h
        mov al,VIDEO_MODE
        int 10h

        mov ah, 01h
        mov ch, 20h
        int 10h
ret

RestoreVideoMode:
        ;Restore old video mode (without old page)
        mov ah,00h
        mov al,[OldVideoMode]
        int 10h
ret

SetTemplate:
        push es cx di si
        push 0xb800
        pop es
        mov di,0
        mov cx,1000
        mov si,BITMAP
        rep movsd
        pop si di cx es
ret

ClearWindow:
        mov cx,MAX_FILES_AMOUNT

        mov dh,[CurrentRow]
        mov dl,[CurrentColumn]
        dec dl
        mov ax,1300h
        mov bx,RENEW_STRING_VIDEO_ATTRIBUTE
        mov bp,EmptyString

        .Looper:
        push cx
        mov cx,38
        int 10h
        pop cx
        inc dh
        loop .Looper
ret
WriteString:
        push bx dx cx bp

        ;REDO!!!!!!!!!!!!!!!!!!!

        ;!!!!!!!!!!!!!!!!!!!!!1


        ;1300h int 10h
        mov ax,1300h
        mov bx,NORMAL_STRING_VIDEO_ATTRIBUTE
        mov cx,[StringLength]
        mov dh,[CurrentRow]
        mov dl,[CurrentColumn]
        mov bp,[oDTA]
        add bp,1eh

        int 10h
        inc dh
        mov [CurrentRow],dh
        pop bp cx dx bx
ret

DrawChooseLine:
       push ax es

       push 0xb800
       pop es

       mov ax,[CurrentFile]
       add ax,WINDOW_START_LINE
       mov bl,160
       mul bl
       add ax,WINDOW_LEFT_ROW
       mov bx,ax
       xor word[es:bx],0x7000
       inc bx
       inc bx
       mov cx,36
       .Looper:
             xor  word[es:bx],0x7F00
             inc bx
             inc bx
       loop .Looper
       xor word[es:bx],0x7000
       pop es ax
ret

DrawChooseDrive:
       push es

       mov al,[DrivesAmount]
       movzx cx,[CurrentDrivePos]
       mov di,pDRIVES_START_LINE_OFFSET

       cmp al,9
       ja _NoCorrector
           add di,160
           jmp _EndSub
        _NoCorrector:


       _Subber:
                cmp  cl,9
                jb _EndSub
       sub cl,9
       sub al,9
       add di,160
       jmp _Subber

       _EndSub:

       cmp al,9
       jbe _NoChange
          mov al,9
       _NoChange:
       call CountOffsets ;in al - amount of disks; return in al - between disks, ah - from left and right borders

          shl al,1
          shl ah,1
          movzx dx,ah
          mov ah,0

          add di,dx
          _PositionLooper:
                add di,ax
                add di,4
          loop _PositionLooper


          push 0xb800
          pop es

          mov cx,3
          _XOR_Looper:
          xor word[es:di],0x3000
          inc di
          inc di
          loop _XOR_Looper

        pop es
ret

