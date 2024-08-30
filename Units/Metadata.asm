;https://www.mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html

; RIFF part
; 0-3  "RIFF"
; 4-7  File size
; 8-11 File Type Header P.S always "WAVE"
;TOTAL: 12 bytes


;fmt chunk
; 0-3    fmt  Format chunk marker. Includes trailing null
;cksize 4       Chunk size: 16, 18 or 40
;wFormatTag      2       Format code
;nChannels       2       Number of interleaved channels
;nSamplesPerSec  4       Sampling rate (blocks per second)
;nAvgBytesPerSec 4       Data rate
;nBlockAlign     2       Data block size (bytes)
;wBitsPerSample  2       Bits per sample
;cbSize  2       Size of the extension (0 or 22)
;wValidBitsPerSample     2       Number of valid bits
;dwChannelMask   4       Speaker position mask
;SubFormat       16      GUID, including the data format code

;LIST chunk
; 0 - 3 "LIST"
; 4 - 7 size of chunck
     ;'INFO' !!!!!
     ; Each info chunk if
            ; 0-3 name
            ; 4-7 size in bytes
     ;INAM       Track title.
     ;IPRD    The album title.
     ;IART    The artist who created this.
     ;ICRD    The creation date in YYYY-MM-DD format, however you should expect to see just YYYY in this field.
     ;ITRK    Track number.
     ;ICMT    A text comment.
     ;IKEY    The keywords for the project or file.
     ;ISFT    The software used to create the file.
     ;IENG    The engineer.
     ;ITCH    The technician.
     ;IGNR    Genre of content.
     ;ICOP    The copyright information.
     ;ISBJ    The subject.
     ;IENG    The name(s) of the engineer. Multiple names separated by a semicolon and a blank.
     ;ISRC    Source: the name of the person or organization that supplied the original subject of the file.

;data chunck
; 0 - 3 'data'
; 4 - 7 Size

Read_ChunckInfo:
        add dword[CurrentOffset],8
        mov ax,3f00h
        mov dx,ChunckInfo
        mov bx,[File_handler]
        mov cx,8
        int 21h
ret

Read_ChunckPart:
        add word[CurrentOffset],cx
        adc word[CurrentOffset+2],dx
        mov ax,3f00h
        mov dx,TempInfoBuffer
        mov bx,[File_handler]
        int 21h
ret

Check_WavStructure:
        test dword[CurrentOffset],1
        jz .Next
           inc dword[CurrentOffset]
        .Next:
        mov ax,4200h
        mov bx,[File_handler]
        mov cx,word[CurrentOffset+2]
        mov dx,word[CurrentOffset]
        int 21h

        call Read_ChunckInfo
        cmp ax,0
        je CheckWavStructureEnd
        cmp dword[ChunckInfo],'RIFF'
        je RIFF_Process

        cmp dword[ChunckInfo],'fmt '
        je fmt_Process

        cmp dword[ChunckInfo],'LIST'
        je LIST_Process

        cmp dword[ChunckInfo],'IART'
        je IART_Process

        cmp dword[ChunckInfo],'INAM'
        je INAM_Process

        cmp dword[ChunckInfo],'data'
        je data_Process

        jmp Unknown_Process

        RIFF_Process:
                mov cx,4
                mov dx,0
                call Read_ChunckPart
                cmp dword[TempInfoBuffer],'WAVE'
                je .Next
                ;!!!!ERROR
                        mov [CorrectFile],1
                .Next:
                mov [CorrectFile],0
        jmp ProcessNext

        fmt_Process:
                mov dx,word[ChunckInfo+6]
                mov cx,word[ChunckInfo+4]
                call Read_ChunckPart

                mov ax,word[TempInfoBuffer+4]
                cmp ax,ACCEPTABLE_RATE
                je .Next
                   mov [CorrectFile],1
                .Next:
                mov [SamplingRate],ax

        jmp ProcessNext

        LIST_Process:
                mov cx,4
                mov dx,0
                call Read_ChunckPart
                cmp dword[TempInfoBuffer],'INFO'
                je .Next
                ;!!!!ERROR
                        mov [CorrectFile],1
                .Next:
        jmp ProcessNext

        IART_Process:
               mov bx,ArtistString+7
               call ClearString

               mov dx,word[ChunckInfo+6]
               mov cx,word[ChunckInfo+4]

               add word[CurrentOffset],cx
               adc word[CurrentOffset+2],dx

               cmp dword[ChunckInfo+4],31
               jbe .TooBig
                  mov cx,28
               .TooBig:
               dec cx

               mov ax,3f00h
               mov dx,ArtistString+7
               mov bx,[File_handler]
               int 21h
        jmp ProcessNext

        INAM_Process:
               mov bx,TrackString+6
               call ClearString

               mov dx,word[ChunckInfo+6]
               mov cx,word[ChunckInfo+4]

               add word[CurrentOffset],cx
               adc word[CurrentOffset+2],dx

               cmp dword[ChunckInfo+4],31
               jbe .TooBig
                  mov cx,31
               .TooBig:
               dec cx

               mov ax,3f00h
               mov dx,TrackString+6
               mov bx,[File_handler]
               int 21h
        jmp ProcessNext

        data_Process:
               mov di,DataChunck
               mov si,CurrentOffset
               movsd

               mov di,DataSize
               mov si,ChunckInfo+4
               movsd

               mov dx,word[ChunckInfo+6]
               mov cx,word[ChunckInfo+4]

               add word[CurrentOffset],cx
               adc word[CurrentOffset+2],dx
        jmp ProcessNext

        Unknown_Process:
               mov dx,word[ChunckInfo+6]
               mov cx,word[ChunckInfo+4]

               add word[CurrentOffset],cx
               adc word[CurrentOffset+2],dx
        jmp ProcessNext

        ProcessNext:
        jmp Check_WavStructure

CheckWavStructureEnd:
ret

ClearString:
               mov cx,30
               .Looper:
                        mov byte[bx],' '
                        inc bx
               loop .Looper
ret







