GetDfltDir:
        push bx es
        mov ah,2fh
        int 21h

        mov [sDTA],es
        mov [oDTA],bx
        pop es bx
ret

CreateBaseDirPath:
        push di si
        mov ah,19h
        int 21h
        mov [DefDrive],al
        ;Redo!!!!!
        add al,'A'
        mov di,CurrentDir
        stosb
        mov al,':'
        stosb
        mov al,'\'
        stosb
        ;!!!!!
        ;Reading current default directory
        mov ah,47h
        mov dl,0
        mov si,[CurrentDirStart]
        int 21h

        ;Finding string end
        mov di,[CurrentDirStart]
        mov al,0

        mov cx,256
        repne scasb
        dec di

        mov [CurrentDirStart],di
        pop si di
ret

GetDirectoryData:
        push di si cx dx bx

        mov bx,0
        ;Adding SearchName to address
        mov di,[CurrentDirStart]
        mov si,SearchName
        mov cx,5
        rep movsb

        ;Getting first file
        mov cx,10h
        mov ah,4eh
        mov dx,CurrentDir
        int 21h
        jc _EndCount

        _CountLoop:
                inc bx
                mov ah,4fh
                mov dx,[oDTA]
                int 21h
        jnc _CountLoop
        _EndCount:
        dec bx
        mov [FilesAmount],bx
        mov [CurrentFile],0
        mov [FirstShowFile],0

        pop bx dx cx si di
ret

OutputDirectory:
        ;Getting first file
        mov bx,0
        mov cx,10h
        mov ah,4eh
        mov dx,CurrentDir
        int 21h
        jc _End
        _Looper:
                inc bx
                push bx
                sub bx,[FirstShowFile]
                cmp bx,MAX_FILES_AMOUNT
                ja _NoString

                mov es,[sDTA]
                mov di,[oDTA]
                add di,1eh

                ;REDO!!!!
                mov cx,0
                dec di
                CountSimbols:
                    inc di
                    inc cx
                    cmp byte[es:di],0
                jne CountSimbols
                mov [StringLength],cx
                ;!!!!
                call WriteString

                _NoString:
                pop bx
                mov ah,4fh
                mov dx,[oDTA]
                int 21h
        jnc _Looper
        _End:
ret
