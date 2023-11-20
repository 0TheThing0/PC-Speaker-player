GetDTA:
        push bx es
        mov ah,2fh
        int 21h

        mov [sDTA],es
        mov [oDTA],bx
        pop es bx
ret

OpenDirectory:
        call CountDirectoryFiles

        ;Counting space between key files
        mov dx,0
        mov ax,[FilesAmount]
        mov bx,KEY_POINTS_AMOUNT
        div bx
        cmp ax,32
        jae .JustAdd
        mov ax,32
        .JustAdd:
        mov [KeyPointsSpace],ax
        ;

        mov [CurrentFile], 0
        mov [FirstShowFile], 0
        mov [CurrentRow], WINDOW_START_LINE

        mov cx,10h
        mov ah,4eh
        mov dx,CurrentDir
        int 21h

        mov ax,0
        call AddToPointKeys


        call OutputDirectory
        call DrawChooseLine
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

        cmp [CurrentDirStart],di
        jne DirExist
            dec di

        DirExist:
        mov [CurrentDirStart],di
        pop si di
ret

OpenNextDir:
        mov di,[CurrentDirStart]
        ;BackSlashSearch:
        ;cmp byte[di],'\'
        ;je LoopEnd
        ;mov byte[di],0
        ;dec si
        ;jmp BackSlashSearch
        ;LoopEnd:

        mov al,'\'
        stosb

        mov si,NameString
        mov cx,14
        .Looper:
        cmp byte[si],' '
        je EndLooper
        movsb
        loop .Looper
        EndLooper:
        dec di
        mov [CurrentDirStart],di
        mov ax,[CurrentFile]
        mov [PrevDirPos],ax
        mov ax,[FirstShowFile]
        mov [PrevHeadDirPos],ax
        call OpenDirectory
ret

OpenPrevDir:
        mov di,[CurrentDirStart]
        dec di
        BackSlashSearch:
        cmp byte[di],'\'
        je LoopEnd
        mov byte[di],0
        dec di
        jmp BackSlashSearch
        LoopEnd:
        mov [CurrentDirStart],di

        call OpenDirectory

        mov ax,[PrevDirPos]
        mov [CurrentFile],ax
        mov ax,[PrevHeadDirPos]
        mov [FirstShowFile],ax
        mov [CurrentRow], WINDOW_START_LINE

        mov [PrevDirPos],0
        mov [PrevHeadDirPos],0

        call OutputDirectory
        call DrawChooseLine
ret

CountDirectoryFiles:
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
        jc .EndCount

        .CountLoop:
                inc bx
                mov ah,4fh
                mov dx,[oDTA]
                int 21h
        jnc .CountLoop
        .EndCount:

        mov [FilesAmount],bx
        pop bx dx cx si di
        ret

OutputDirectory:
        push bx cx dx
        call ClearWindow
        ;Getting first file
        mov bx,[FirstShowFile]
        mov ax,bx
        mov dx,0
        div [KeyPointsSpace]

        mov cx,dx
        mov dx,KeyPoints
        mov bl,FileRecInfo_SIZE
        mul bl

        mov bx,[FirstShowFile]
        sub bx,cx
        ;
        add dx,ax

        push es
        mov si,dx
        mov di,[oDTA]
        mov es,[sDTA]

        mov cx,43
        rep movsb
        pop es

        ;
        _Looper:
                ;Check on point key
                mov ax,bx
                mov dx,0
                div word[KeyPointsSpace]
                cmp dx,0
                jne .SkipElem
                   call AddToPointKeys
                .SkipElem:
                ;

                push bx
                cmp bx,[FirstShowFile]
                jb _NoOutput
                sub bx,[FirstShowFile]
                cmp bx,MAX_FILES_AMOUNT
                jae _End

                ;Output String
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

                _NoOutput:
                pop bx
                inc bx
                mov ah,4fh
                mov dx,[oDTA]
                int 21h
        jnc _Looper
        jmp _EndProc
        ;REDO!!!!
        _End:
                pop bx
        _EndProc:
        pop dx cx bx
ret

AddToPointKeys:
        push ds di si bx cx
        mov di,KeyPoints

        mov bl,FileRecInfo_SIZE
        mul bl

        add di,ax
        mov si,[oDTA]
        mov ds,[es:sDTA]

        mov cx,43
        rep movsb
        pop cx bx si di ds
ret

ProcessFile:
       ;REDO!!!
       push ds

       push 0xb800
       pop ds

       mov ax,[es:CurrentFile]
       add ax,WINDOW_START_LINE
       mov bl,160
       mul bl
       add ax,WINDOW_LEFT_OFFSET
       add ax,WINDOW_LEFT_OFFSET

       mov si,ax
       mov di,NameString
       mov cx,14
       .Looper:
       movsb
       inc si
       loop .Looper

       pop ds

       cmp word[NameString],2e2eh
       je IS_BACK_DIR

       mov cx,14
       mov di,NameString
       mov ax,'.'
       repne scasb
       jz NO_DIR


       jmp IS_DIR

       IS_DIR:
          call OpenNextDir
          jmp EndProcessFile
       IS_BACK_DIR:
          call OpenPrevDir
          jmp EndProcessFile
       NO_DIR:
       EndProcessFile:
ret