Play_Music:
push cx
mov [CurrentOffset],0
mov [CorrectFile],2

mov si,BaseName
mov bx,ArtistString+7
call ClearString
mov di,ArtistString+7
mov cx,7
rep movsb

mov si,BaseName
mov bx,TrackString+6
call ClearString
mov di,TrackString+6
mov cx,7
rep movsb


call Check_WavStructure
cmp [CorrectFile],0
je .Next
      push OpenFileError
      call ShowError
      jmp IncorrectFile
.Next:

mov ax,4200h
mov bx,[File_handler]
mov cx,word[DataChunck+2]
mov dx,word[DataChunck]
int 21h

call DrawPlayScreen
;Reading header data
;call Read_Header

;Time
fild dword[DataSize]
fidiv word[SamplingRate]
fistp dword[TimeInSeconds]
shr dword[TimeInSeconds],1

call Count_Time

mov di,PLAYSCREEN_START+(60+160*6)
call Fill_TimeScreen

mov di,FullTime
mov si,TimeInSeconds
movsd

mov [TimeInSeconds],0
call Count_Time
mov di,PLAYSCREEN_START+(2+160*6)
call Fill_TimeScreen
call Clear_TimeLine
call Redraw_TimeLine

;Counting sound coeff
call Count_Sound_Coeff

;Reprogramming PIT for correct rate
call Programming_PIT

;Set new interrupt
call Install_new_interrupt

;First load
mov cx,BLOCK_SIZE_IN_BYTES
call Load_FilePart

;Music cycle
mov [EnableSound],1
mov [EndSound],0
mov [StopSound],0
Next_block:

;Getting current offset
       cmp [LoadData],1
       jne _Process_Music_Key
                cmp [StopSound],1
                je _Process_Music_Key
                mov [EnableSound],0
                mov cx,BLOCK_SIZE_IN_BYTES
                call Load_FilePart
                mov [EnableSound],1

       _Process_Music_Key:
                mov ah,01h
                int 16h
                jz _Next
                mov ah,00h
                int 16h

                cmp ah,1h
                je Esc_Music_Key

                cmp ah,39h
                je Space_Music_Key

                cmp ah,77
                je Forward_Music_Key

                cmp ah,75
                je Backward_Music_Key
                jmp _Next

                Space_Music_Key:
                        xor [StopSound],1
                        xor [EnableSound],1
                        jmp _Next
                Esc_Music_Key:
                        mov [EndSound],1
                        mov [EndPlaylist],1
                        jmp _Next
                Forward_Music_Key:
                        mov [EndSound],1
                        jmp _Next
                Backward_Music_Key:
                        dec word[OrderPos]
                        mov [EndSound],1
                        mov [EndPlaylist],2

                jmp _Next
_Next:
cmp [EndSound],0
je Next_block
_EndMusic:
;OFFSound
mov [EnableSound],0

;OFF pc speaker
in al,61h
and al, 1111_1100b
out 61h,al

;call Close_File
;Restore IRQ
call IRQ_Restore

call Restore_PIT

call Restore_PlayScreen
IncorrectFile:
call Close_File
pop cx
ret

ChangeRandomState:
        push es
        push 0xb800
        pop es
        xor byte[es:RANDOW_POS+1],0011b
        xor [RandomState],1
        pop es
ret
