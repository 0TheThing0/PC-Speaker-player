PlayMusic:
push cx
call DrawPlayScreen
;Reading header data
call Read_Header

;Time
mov di,PLAYSCREEN_START+(60+160*6)
call FillTimeScreen

mov di,FullTime
mov si,TimeInSeconds
movsd

mov [TimeInSeconds],0
call Count_Time
mov di,PLAYSCREEN_START+(2+160*6)
call FillTimeScreen
call ClearTimeLine
call RedrawTimeLine

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

call Close_File
call RestorePlayScreen
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
