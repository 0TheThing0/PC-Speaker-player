VIDEO_MODE = 03h
NORMAL_COLOR = 1fh
CHOOSED_COLOR = 20h
WINDOW_START_LINE = 6
WINDOW_LEFT_OFFSET = 2
LINE_LENGTH = 80
pWINDOW_START_LINE_OFFSET = WINDOW_START_LINE * LINE_LENGTH + WINDOW_LEFT_OFFSET
NORMAL_STRING_VIDEO_ATTRIBUTE = 0000_0000_0011_0000b
NORMAL_STRING_SIZE = 14;36
MAX_FILES_AMOUNT = 17

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

WriteString:
        push bx dx cx bp
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

