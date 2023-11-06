org 100h

        mov ah,2fh
        int 21h

        mov [sDTA],es
        mov [oDTA],bx

        mov ah,0ah
        mov dx,FilePath
        int 21h

        mov bx,FilePath
        add bl,byte[FilePath+1]
        adc bh,0
        add bx,2
        mov byte[bx],0

        mov ah,4eh
        mov cx,3
        mov dx,FilePath
        add dx,2
        int 21h

        Looper:
                mov ds,[sDTA]
                mov si,[oDTA]
                add si,1eh

                mov di,String
                Looper2:
                        movsb
                        cmp byte[ds:si],0
                jne Looper2
                mov byte[es:di],'$'
                mov ah,09h
                mov dx,String
                int 21h

                mov ah,09h
                mov dx,EnterPrn
                int 21h

                mov ah,4fh
                mov dx,[oDTA]
                int 21h
        jnc Looper
ret
;+1eh
sDTA dw ?
oDTA dw ?
FilePath db 254,0,254 dup ?
String db 14 dup ?
EnterPrn  db 13,10,'$'