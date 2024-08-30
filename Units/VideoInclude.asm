DrawRectangle:
       ;bp+2 - start row, bp+4 - start line, bp+6 - end row, bp+8 - end line bp+10 - color;
       mov bp,sp
       push es ax bx cx dx
       push 0xb800
       pop es


       mov ax,[bp+2]
       mov bx,160
       mul bx

       add ax,[bp+4]
       add ax,[bp+4]
       mov di,ax
       mov si,ax

       mov cx,[bp+8]
       sub cx,[bp+4]
       dec cx
       dec cx
       mov bx,cx

       mov ax,[bp+10]

       mov al,0xdb
       mov cx,bx
       add cx,2
       rep stosw

       mov cx,[bp+6]
       sub cx,[bp+2]
       dec cx
       dec cx
       add si,160

       .MainLoop:
       push cx
            mov di,si
            mov al,0xdd
            stosw

            mov al,20h
            mov cx,bx
            rep stosw

            mov al,0xde
            stosw

            add si,160

       pop cx
       loop .MainLoop

       mov di,si
       mov al,0xdb
       mov cx,bx
       add cx,2
       rep stosw
       pop dx cx bx ax es
ret 10

DrawLinedRectangle:
       ;bp+2 - start row, bp+4 - start line, bp+6 - end row, bp+8 - end line
       mov bp,sp
       push es ax bx cx dx
       push 0xb800
       pop es


       mov ax,[bp+2]
       mov bx,160
       mul bx

       add ax,[bp+4]
       add ax,[bp+4]
       mov di,ax
       mov si,ax

       mov cx,[bp+8]
       sub cx,[bp+4]
       dec cx
       dec cx
       mov bx,cx

       mov ah,0x7F

       mov al,0xc9
       stosw

       mov al,0xcd
       mov cx,bx
       rep stosw

       mov al,0xbb
       stosw

       mov cx,[bp+6]
       sub cx,[bp+2]
       dec cx
       dec cx
       add si,160

       .MainLoop:
       push cx
            mov di,si
            mov al,0xba
            stosw

            mov al,20h
            mov cx,bx
            rep stosw

            mov al,0xba
            stosw

            add si,160

       pop cx
       loop .MainLoop

       mov di,si
        mov al,0xc8
       stosw

       mov al,0xcd
       mov cx,bx
       rep stosw

       mov al,0xbc
       stosw

       pop dx cx bx ax es
ret 8


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
       push 37 5 0 0
       call DrawLinedRectangle

       push 40 25 0 4
       call DrawLinedRectangle

       push 3f00h 39 24 1 5
       call DrawRectangle

       push 80 25 39 4
       call DrawLinedRectangle

       push 3f00h 79 24 40 5
       call DrawRectangle

       push es
       push 0xb800
       pop es
           mov si,ASSIST

           mov di,640
           mov ax,0x7FCC
           stosw

           mov di,3840
           mov cx,40
           rep movsd

           mov si,LOGO
           mov di,72
           mov cx,5
           .Looper:
                push cx
                mov cx,22
                rep movsd
                add di,72
                pop cx
            loop .Looper


       pop es
ret

ClearWindow:
        mov cx,MAX_FILES_AMOUNT

        mov dh,[CurrentRow]
        mov dl,[CurrentColumn]
        mov ax,1300h
        mov bx,RENEW_STRING_VIDEO_ATTRIBUTE
        mov bp,EmptyString

        .Looper:
        push cx
        mov cx,36
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


WriteAddString:
        push bx dx cx bp es

        ;REDO!!!!!!!!!!!!!!!!!!!

        ;!!!!!!!!!!!!!!!!!!!!!1


        ;1300h int 10h
        mov ax,1300h
        movzx cx,bl
        mov bp,0
        .Looper:
                add bp,256
        loop .Looper

        mov dh,WINDOW_START_LINE
        add dh,bl
        sub dh,[FirstShowPlaylistFile]
        mov dl,41
        mov es,[PlaylistBuffer]
        call CountOffset
        mov bx,NORMAL_STRING_VIDEO_ATTRIBUTE
        int 10h
        pop es bp cx dx bx
ret

CountOffset:

        push dx ax bx ds si
        mov si,bp
        mov dx,0
        mov ds,[PlaylistBuffer]

        mov cx,256

        CountOffsetLooper:

        lodsb
        cmp al,0
        je _CountOffsetEnd
        cmp al,'\'
        jne NoSlash
            mov dx,si
        NoSlash:

        loop CountOffsetLooper

        _CountOffsetEnd:
        sub si,dx
        mov cx,si
        mov bp,dx
        pop si ds bx ax dx

ret
DrawChooseLine:
       push ax es

       push 0xb800
       pop es

       mov ax,[CurrentFile]
       add ax,WINDOW_START_LINE
       mov bl,160
       mul bl
       add ax,WINDOW_LEFT_COLUMN
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

DrawPlaylistLine:
       push ax es

       push 0xb800
       pop es

       movzx ax,[CurrentPlaylistFile]
       add ax,WINDOW_START_LINE
       mov bl,160
       mul bl
       add ax,80
       mov bx,ax
       xor word[es:bx],0x7000
       inc bx
       inc bx
       mov cx,37
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

CopyPlayScreen:
       push ds
       push 0xb800
       pop ds
       mov si,PLAYSCREEN_START
       mov di,PLAYSCREEN

       mov cx,PLAYSCREEN_HEIGHT
       .DrawPlayScreenLoop:
          push cx
          mov cx,PLAYSCREEN_WIDTH
          rep movsw
          add si,82
          pop cx
       loop  .DrawPlayScreenLoop
       pop ds
ret
DrawPlayScreen:
       call CopyPlayScreen
       push 1f00h PLAYSCREEN_LINE+PLAYSCREEN_WIDTH PLAYSCREEN_ROW+PLAYSCREEN_HEIGHT PLAYSCREEN_LINE PLAYSCREEN_ROW
       call DrawRectangle


        mov bp,ArtistString
        mov ax,1300h
        mov bx,INFO_STRING_VIDEO_ATTRIBUTE
        mov cx,37
        mov dh,PLAYSCREEN_ROW+1
        mov dl,PLAYSCREEN_LINE+1
        int 10h

        mov bp,TrackString
        mov ax,1300h
        mov bx,INFO_STRING_VIDEO_ATTRIBUTE
        mov cx,37
        mov dh,PLAYSCREEN_ROW+3
        mov dl,PLAYSCREEN_LINE+1
        int 10h
ret

RestorePlayScreen:
       push es
       push 0xb800
       pop es
       mov di,PLAYSCREEN_START
       mov si,PLAYSCREEN

       mov cx,PLAYSCREEN_HEIGHT
       .DrawPlayScreenLoop:
          push cx
          mov cx,PLAYSCREEN_WIDTH
          rep movsw
          add di,82
          pop cx
       loop  .DrawPlayScreenLoop
       pop es
ret

FillTimeScreen:
       push es

       push 0xb800
       pop es

       movzx ax,[TrackHours]
       mov dl,10
       div dl
       add ax,'00'
       stosb
       inc di
       mov al,ah
       stosb
       inc di

       mov al,':'
       stosb
       inc di

       movzx ax,[TrackMinutes]
       mov dl,10
       div dl
       add ax,'00'
       stosb
       inc di
       mov al,ah
       stosb
       inc di

       mov al,':'
       stosb
       inc di

       movzx ax,[TrackSeconds]
       mov dl,10
       div dl
       add ax,'00'
       stosb
       inc di
       mov al,ah
       stosb
       pop es
ret

RedrawTimeLine:
       push es

       push 0xb800
       pop es

       fild dword[TimeInSeconds]
       fild dword[FullTime]
       fdivp ST1,ST0
       fdiv dword[TimeCoeff]
       fistp word[DrawPos]

       mov di,PLAYSCREEN_START+(8+160*5)
       mov cx,[DrawPos]
       mov ax,1fb1h
       rep stosw
       mov ax,1fb2h
       stosw

       pop es
ret

ClearTimeLine:
       push es

       push 0xb800
       pop es


       mov di,PLAYSCREEN_START+(4+160*5)
       mov ax,1f11h
       stosw
       stosw
       mov cx,32
       mov ax,1fb0h
       rep stosw
       mov ax,1f10h
       stosw
       stosw
       pop es
ret

ShowError:
        ;bp+2 - Error String
        push ax bx cx dx


        call CopyPlayScreen
        push 4F00h PLAYSCREEN_LINE+PLAYSCREEN_WIDTH PLAYSCREEN_ROW+PLAYSCREEN_HEIGHT PLAYSCREEN_LINE PLAYSCREEN_ROW
        call DrawRectangle

        mov bp,sp
        mov bp,[bp+10]
        mov ax,1300h
        mov bx,ERROR_STRING_VIDEO_ATTRIBUTE
        mov cx,37
        mov dh,PLAYSCREEN_ROW+3
        mov dl,PLAYSCREEN_LINE+1
        int 10h

        mov bp,EscPrint
        mov ax,1300h
        mov bx,ERROR_STRING_VIDEO_ATTRIBUTE
        mov cx,7
        mov dh,PLAYSCREEN_ROW+5
        mov dl,PLAYSCREEN_LINE+16
        int 10h

         Error_Key_Looper:
         mov ah,01h
         int 16h
         jz Error_Key_Looper
            mov ah,00h
            int 16h

            cmp ah,1h
            je Esc_Key_Error

         jmp Error_Key_Looper
         Esc_Key_Error:
         call RestorePlayScreen
         pop  dx cx bx ax
ret 2
