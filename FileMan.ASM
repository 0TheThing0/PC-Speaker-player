org 100h

        mov ah,2fh
        int 21h

        mov [sDTA],es
        mov [oDTA],bx

        mov ah,4eh
        mov cx,3
        mov dx,FilePath
        int 21h

        Looper:
        mov ah,4fh
        mov dx,[oDTA]
        int 21h
        jnc Looper
ret
sDTA dw ?
oDTA dw ?
FilePath db 'c:\*.com',0