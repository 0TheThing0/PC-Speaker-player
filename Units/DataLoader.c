Load_FilePart:
push dx bx ax cx ds

mov ah,3fh
shl cx,1
xor dx,dx

mov bx,[es:File_handler]
mov ds,[es:Current_datapos]
int 21h

sub word[es:WAVFile_Data+SIZE_OFFSET],ax
sbb word[es:WAVFile_Data+SIZE_OFFSET+2],0
pop ds cx ax bx dx
ret

Close_File:
;Close music file
mov ax,3eh
mov bx,[File_handler]
int 21h
ret

Open_File:
;Openning music file
mov ax,3d00h
mov dx,MusicFile
int 21h
mov [File_handler],ax
ret

Read_WAVHeader:
push ax bx cx dx
mov bx,[File_handler]
mov ah,3fh
mov cx,128
mov dx,WAVFile_Data
int 21h
pop dx cx bx ax

ret

Read_Header:
        push dx bx ax cx
        mov ah,3fh
        mov cx,44

        mov dx,WAVFile_Data
        mov bx,[File_handler]
        int 21h

        mov ax,word[WAVFile_Data+24]
        mov [Sampling_Rate],ax

pop cx ax bx dx
ret

Allocate_Memory:
push ax bx
        mov ah,4ah
        mov bx,1000h
        int 21h

        mov ah,48h
        mov bx,0500h
        int 21h
        mov [Current_datapos],ax
pop bx ax
ret

Restore_memory:
push ax bx es
        mov ah,49h
        mov es,[Current_datapos]
        int 21h
pop es bx ax
ret
