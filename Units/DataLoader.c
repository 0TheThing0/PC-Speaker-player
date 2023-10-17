Load_FilePart:
push dx bx ax cx ds

mov ah,3fh
shl cx,1
xor dx,dx

mov bx,[File_handler]
mov ds,[Current_datapos]
int 21h

sub word[WAVFile_Data+SIZE_OFFSET],ax
sbb word[WAVFile_Data+SIZE_OFFSET+2],0
pop ds cx ax bx dx
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
        push dx bx ax cx ds
        mov ah,3fh
        mov cx,44

        mov dx,WAVFile_Data
        mov bx,[File_handler]
        int 21h

        mov ax,word[WAVFile_Data+24]
        mov [Sampling_Rate],ax

pop ds cx ax bx dx
ret