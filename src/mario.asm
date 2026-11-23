; ============================================================
; MARIO.ASM - Super Mario Engine (x86, NASM, DOSBox)
; Part 1: program skeleton
; ============================================================
[org 0x0100]
                jmp start

; ------------------------------------------------------------
; DATA
; ------------------------------------------------------------
; --- hero data ---
mario_x:        dw 0
mario_y:        dw 0

; --- score and clock data ---
score_lo:       dw 0
score_hi:       dw 0
coins:          dw 0
lives:          dw 3
game_time:      dw 300

; --- test message ---
message:        db 'Super Mario Engine - Part 1 OK'
length:         dw 30

; ------------------------------------------------------------
; PROCEDURE: clrscr
; Purpose : clears the text screen
; Inputs  : none
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
clrscr:         push es
                push ax
                push di

                mov ax, 0xb800
                mov es, ax
                mov di, 0

nextloc:        mov word [es:di], 0x0720
                add di, 2
                cmp di, 4000
                jne nextloc

                pop di
                pop ax
                pop es
                ret

; ------------------------------------------------------------
; PROCEDURE: printstr
; Purpose : prints a string at the top left, white on black
; Inputs  : [bp+6] = address of string, [bp+4] = length
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
printstr:       push bp
                mov bp, sp
                push es
                push ax
                push cx
                push si
                push di

                mov ax, 0xb800
                mov es, ax
                mov di, 0
                mov si, [bp+6]
                mov cx, [bp+4]
                mov ah, 0x07

nextchar:       mov al, [si]
                mov [es:di], ax
                add di, 2
                add si, 1
                loop nextchar

                pop di
                pop si
                pop cx
                pop ax
                pop es
                pop bp
                ret 4


; ------------------------------------------------------------
; PROCEDURE: putpixel
; Purpose : draws one pixel in VGA mode 13h
; Inputs  : [bp+8] = x, [bp+6] = y, [bp+4] = colour
; Outputs : none
; Changes : no register is changed
; Formula : offset = y*320 + x = (y*256) + (y*64) + x
; ------------------------------------------------------------
putpixel:       push bp
                mov bp, sp
                push es
                push ax
                push bx
                push cx
                push di

                mov ax, 0xa000
                mov es, ax

                mov ax, [bp+6]          ; ax = y
                mov bx, ax              ; bx = y
                mov cl, 8
                shl ax, cl              ; ax = y*256
                mov cl, 6
                shl bx, cl              ; bx = y*64
                add ax, bx              ; ax = y*320
                add ax, [bp+8]          ; ax = y*320 + x
                mov di, ax

                mov al, [bp+4]          ; colour
                mov [es:di], al

                pop di
                pop cx
                pop bx
                pop ax
                pop es
                pop bp
                ret 6

; ------------------------------------------------------------
; PROCEDURE: fillrect
; Purpose : fills a rectangle with one colour
; Inputs  : [bp+12] = x, [bp+10] = y, [bp+8] = width,
;           [bp+6] = height, [bp+4] = colour
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
fillrect:       push bp
                mov bp, sp
                push es
                push ax
                push bx
                push cx
                push dx
                push di

                mov ax, 0xa000
                mov es, ax
                cld

                mov ax, [bp+10]         ; ax = y
                mov bx, ax
                mov cl, 8
                shl ax, cl              ; y*256
                mov cl, 6
                shl bx, cl              ; y*64
                add ax, bx              ; y*320
                add ax, [bp+12]         ; + x
                mov di, ax              ; di = first pixel

                mov dx, [bp+6]          ; dx = rows left
                mov al, [bp+4]          ; al = colour

nextrow:        mov cx, [bp+8]          ; cx = width
                push di
                rep stosb               ; draw one row
                pop di
                add di, 320             ; go to next row
                dec dx
                jnz nextrow

                pop di
                pop dx
                pop cx
                pop bx
                pop ax
                pop es
                pop bp
                ret 10

; ------------------------------------------------------------
; MAIN - Part 2 test screen
; ------------------------------------------------------------
start:          mov ax, 0x0013          ; VGA mode 13h
                int 0x10

                ; sky: x=0 y=0 w=320 h=200 colour=9
                mov ax, 0
                push ax
                mov ax, 0
                push ax
                mov ax, 320
                push ax
                mov ax, 200
                push ax
                mov ax, 9
                push ax
                call fillrect

                ; grass: x=0 y=160 w=320 h=16 colour=2
                mov ax, 0
                push ax
                mov ax, 160
                push ax
                mov ax, 320
                push ax
                mov ax, 16
                push ax
                mov ax, 2
                push ax
                call fillrect

                ; ground: x=0 y=176 w=320 h=24 colour=6
                mov ax, 0
                push ax
                mov ax, 176
                push ax
                mov ax, 320
                push ax
                mov ax, 24
                push ax
                mov ax, 6
                push ax
                call fillrect

                ; red box: x=50 y=100 w=16 h=16 colour=4
                mov ax, 50
                push ax
                mov ax, 100
                push ax
                mov ax, 16
                push ax
                mov ax, 16
                push ax
                mov ax, 4
                push ax
                call fillrect

                ; yellow box: x=100 y=80 w=32 h=16 colour=14
                mov ax, 100
                push ax
                mov ax, 80
                push ax
                mov ax, 32
                push ax
                mov ax, 16
                push ax
                mov ax, 14
                push ax
                call fillrect

                ; white box: x=200 y=100 w=16 h=32 colour=15
                mov ax, 200
                push ax
                mov ax, 100
                push ax
                mov ax, 16
                push ax
                mov ax, 32
                push ax
                mov ax, 15
                push ax
                call fillrect

                ; three white pixels: (10,10) (11,10) (12,10)
                mov ax, 10
                push ax
                mov ax, 10
                push ax
                mov ax, 15
                push ax
                call putpixel

                mov ax, 11
                push ax
                mov ax, 10
                push ax
                mov ax, 15
                push ax
                call putpixel

                mov ax, 12
                push ax
                mov ax, 10
                push ax
                mov ax, 15
                push ax
                call putpixel

                ; red pixel in the bottom right corner (319,199)
                mov ax, 319
                push ax
                mov ax, 199
                push ax
                mov ax, 4
                push ax
                call putpixel

                mov ah, 0x00            ; wait for a key
                int 0x16

                mov ax, 0x0003          ; back to text mode
                int 0x10

                mov ax, 0x4c00          ; exit to DOS
                int 0x21