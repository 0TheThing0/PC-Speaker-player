IRQ_Player:
;Don't change any register (INTERRUPT!!!!!)
       push ax bx cx si es ds;REDO
       ;pushf
       ;Getting correct es segment
       push cs
       pop es

       ;is music on???
       cmp [es:EnableSound],0
       je _End

       ;Getting current offset
       mov si,[es:oMusicBuffer]
       cmp si,BLOCK_SIZE_IN_BYTES
       jb ReadNote

                ;CMP avaible block with base size
                cmp dword[es:WAVFileData+SIZE_OFFSET],BLOCK_SIZE_IN_BYTES
                ja _GetFullChunk
                ;Get low
                mov [es:EndSound],1
                jmp _End

                _GetFullChunk:
                xor si,si
                mov [es:oMusicBuffer],0
                sub dword[es:WAVFileData+SIZE_OFFSET],BLOCK_SIZE_IN_BYTES
                mov cx,BLOCK_SIZE_IN_BYTES
                call Load_FilePart

ReadNote:
        mov ds,[es:sMusicBuffer]
        ; I'm not sure in lodsw. SOMETHING STRANGE
        mov ax,[ds:si]
        add [es:oMusicBuffer],2

        ;Music counting
        ;TO DO: Redo + filter
        cmp ax,-32760
        jl _OffSound
           mov [es:Value],ax
           fld [es:MainCoeff]
           fild word[es:Value]
           fiadd [es:Mid]
           fdivp ST1,ST0
           fistp word[es:Value]

        ;Test pc speaker
        in al,61h
        ;test al, 0000_0011b
        ;jnz _AlreadyInclude

           ;Include pc speaker
           or al, 0000_0011b
           out 61h,al

_AlreadyInclude:
        mov al,0b6h
        out 43h,al
        ; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
        ;~100√ц (0x2e9b) ~22050√ц(0036h)

        mov bx,[es:Value]
        mov al,bl
        out 42h,al

        mov al,bh
        out 42h,al
        jmp _End

_OffSound:
        ;in al,61h
        ;and al, 1111_1100b
        ;out 61h,al
_End:
        mov AL,20h
        out 20h,AL
        ;popf
        pop es ds si cx bx ax ;REDO
iret

IRQ_Restore:
        CLI
        push dx ds
        mov DX,[IRQ0_Offset]
        mov DS,[IRQ0_Segment]
        mov AX,2508h
        int 21h
        STI
        ;mov [Sampling_Rate],65536
        ;call Programming_PIT
        pop ds dx
ret


Install_new_interrupt:
        push bx dx es
        ;Get interrupt number (00h to FFh)
        mov ax,3508h
        int 21h
        ;es:bx address of interrupt handler
        mov [IRQ0_Offset],bx
        mov [IRQ0_Segment],es

        ;Set new irq interrupt
        mov ax,2508h
        mov dx,IRQ_Player
        int 21h
        pop es dx bx
ret

Programming_PIT:
        ;In: Sampling rate in [SamplingRate]
        push dx
        mov dx,12h
        mov ax,34ddh
        div [SamplingRate]
        mov dx,ax

        mov al,34h
        ;0011 0100 ?? разобратьс€, почему 34
        ;1011 0110
        out 43h,al
        ; ƒелитель дл€ 1193181 дл€ получени€ частоты 1193181/x √ц
        ;~100√ц (0x2e9b) ~22050√ц(0036h)
        mov al,dl
        out 40h,al
        mov al,dh
        out 40h,al
        pop dx
ret


/////////////////////////



Load_FilePart:
        ;In: cx - amount of data in chuncks
        push dx bx ds
        mov ah,3fh
        xor dx,dx
        mov bx,[es:File_handler]
        mov ds,[es:sMusicBuffer]
        int 21h
        pop ds bx dx
ret


Open_File:
        ;Openning music file for read
        mov ax,3d00h
        mov dx,MusicFile
        int 21h
        ;ax - file handler
        mov [File_handler],ax
ret

Close_File:
        ;Close music file
        mov ax,3eh
        mov bx,[File_handler]
        int 21h
ret

Read_Header:
        push dx bx cx
        ;Read first 44 bytes from wav file to get data
        mov ah,3fh
        mov cx,44
        mov dx,WAVFileData
        mov bx,[File_handler]
        int 21h

        ;Reading wav sampling rate
        mov ax,word[WAVFileData+24]
        mov [SamplingRate],ax

        ;Lowering file size
        sub dword[WAVFileData+SIZE_OFFSET],36

        pop cx bx dx
ret

Allocate_Memory:
push bx
        ;4ah - Shrink a Memory Block, es - segment of an allocated memory block
        ;bx - size of block in paragraphs(16-byte chunks)
        mov ah,4ah
        ;1000h*16=65536 - size of programm to save stack
        mov bx,1000h
        ;!!! Just to be sure that cs=es (but it should be)
        push cs
        pop es
        ;
        int 21h
        ;in ax - error code, bx - largest block avaible
        ;Why should I move stack DOWN???!!

        ;48h - allocate memory block, bx - avaible size in chunks
        mov ah,48h
        mov bx,BLOCK_SIZE_IN_CHUNKS
        int 21h
        ;ax - error code or segment addres, bx - avaible size in chunks
        mov [sMusicBuffer],ax
pop bx
ret

Restore_memory:
        push es
        mov ah,49h
        mov es,[sMusicBuffer]
        int 21h
        pop es
ret

//////

org 100h
BASE_HEAR_SOUND = 24000
BASE_SAMPLE_VALUE = 1234ddh
BASE_SAMPLE_SIZE = 65535
SIZE_OFFSET = 4

BLOCK_SIZE_IN_BYTES = 32000
BLOCK_SIZE_IN_CHUNKS = BLOCK_SIZE_IN_BYTES/16
BLOCK_SIZE_IN_WORD = BLOCK_SIZE_IN_BYTES/2

Main:
finit
;Allocating memory for buffer
call Allocate_Memory

;Openning file
call Open_File

;Reading header data
call Read_Header

;Counting sound coeff
call Count_Sound_Coeff

;Reprogramming PIT for correct rate
call Programming_PIT

;Set new interrupt
call Install_new_interrupt

;First load
mov cx,16000
call Load_FilePart

;Music cycle
mov [EnableSound],1

Next_block:
cmp [EndSound],0
je Next_block

;OFFSound
mov [EnableSound],0
mov ah,09h
mov dx,Done
int 21h

;OFF pc speaker
in al,61h
and al, 1111_1100b
out 61h,al

;Restore IRQ
call IRQ_Restore
;Close file
call Close_File
;Asking for memory restoration
call Restore_memory
ret

;include "Units\Sound.c"
include "Units\DataLoader.c"
include "Units\Interrupts.c"
include "Units\Math.c"

include "Units\Interrupts.di"
include "Units\DataLoader.di"

WAVFileData db 44 dup ?
EnableSound db 0

Value dw 0
Mid dd 32769
MainCoeff dd ?

SamplingSize dd BASE_SAMPLE_SIZE
SampleValue dd BASE_SAMPLE_VALUE
SoundCoeff dd BASE_HEAR_SOUND
SamplingRate dw ?
EndSound db 0
Done db 'done$'

