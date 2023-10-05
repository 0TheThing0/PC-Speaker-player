Load_FilePart:
push dx bx ax cx ds

mov ah,3fh
mov cx,64000
xor dx,dx

mov bx,[File_handler]
mov ds,[Current_datapos]
int 21h

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