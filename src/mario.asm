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

; --- tile colours, one byte per tile code (0 to 12) ---
tilecolour:     db 9,6,4,14,14,8,2,2,2,2,7,9,9

; --- camera (first visible column, used in Part 3 only) ---
first_col:      dw 0

; --- ORIGINAL MAP: 60 columns x 12 rows, never changed ---
; each line below = 10 columns, each row = 6 lines
originalmap:
; row 0 (HUD)
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
; row 1
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
; row 2
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,12,0,0
; row 3
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,12,0,0
; row 4
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,12,0,0
; row 5
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,12,0,0
; row 6
                db 0,0,0,0,0,0,0,0,4,0
                db 3,0,0,2,3,2,3,2,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 2,4,2,2,2,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,10,0,0,0,12,0,0
; row 7
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,11,11,11,11,0,0,0,0,0
                db 0,0,0,0,0,6,7,0,0,0
                db 0,11,11,11,0,0,0,0,0,0
                db 0,0,10,10,0,0,0,12,0,0
; row 8
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,6,7
                db 0,0,0,0,0,8,9,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,10,10,10,0,0,0,12,0,0
; row 9 (Mario stands here)
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 0,0,0,0,0,11,11,11,8,9
                db 0,0,0,0,0,8,9,0,0,0
                db 0,0,0,0,0,0,0,0,0,0
                db 10,10,10,10,0,0,0,10,0,0
; row 10 (ground)
                db 1,1,1,1,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1
                db 1,1,0,0,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1
                db 1,0,0,0,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1
; row 11 (ground)
                db 1,1,1,1,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1
                db 1,1,0,0,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1
                db 1,0,0,0,1,1,1,1,1,1
                db 1,1,1,1,1,1,1,1,1,1

; --- WORKING MAP: a copy of the original (720 zero bytes for now) ---
workmap:        times 720 db 0

; --- where drawing goes (0xa000 = screen). Changes in Part 5 ---
drawseg:        dw 0xa000

; --- SPRITE: small Mario standing, 16x16 ---
spr_mario_stand:
                db 0,0,0,0,4,4,4,4,4,0,0,0,0,0,0,0
                db 0,0,0,4,4,4,4,4,4,4,4,0,0,0,0,0
                db 0,0,0,6,6,6,12,12,6,12,0,0,0,0,0,0
                db 0,0,6,12,6,12,12,12,6,12,12,12,0,0,0,0
                db 0,0,6,12,6,6,12,12,12,6,12,12,12,0,0,0
                db 0,0,0,6,12,12,12,12,6,6,6,6,0,0,0,0
                db 0,0,0,0,12,12,12,12,12,12,12,0,0,0,0,0
                db 0,0,0,4,4,1,4,4,4,0,0,0,0,0,0,0
                db 0,0,4,4,4,1,4,4,1,4,4,4,0,0,0,0
                db 0,4,4,4,4,1,1,1,1,4,4,4,4,0,0,0
                db 0,12,12,4,1,14,1,1,14,1,4,12,12,0,0,0
                db 0,12,12,12,1,1,1,1,1,1,12,12,12,0,0,0
                db 0,12,12,1,1,1,1,1,1,1,1,12,12,0,0,0
                db 0,0,0,1,1,1,0,0,1,1,1,0,0,0,0,0
                db 0,0,6,6,6,0,0,0,0,6,6,6,0,0,0,0
                db 0,6,6,6,6,0,0,0,0,6,6,6,6,0,0,0

; --- SPRITE: Goomba walking, 16x16 ---
spr_goomba:
                db 0,0,0,0,0,0,6,6,6,6,0,0,0,0,0,0
                db 0,0,0,0,6,6,6,6,6,6,6,6,0,0,0,0
                db 0,0,0,6,6,6,6,6,6,6,6,6,6,0,0,0
                db 0,0,6,6,6,6,6,6,6,6,6,6,6,6,0,0
                db 0,6,6,6,15,15,6,6,6,6,15,15,6,6,6,0
                db 0,6,6,15,15,15,6,6,6,6,15,15,15,6,6,0
                db 0,6,6,15,8,15,6,6,6,6,15,8,15,6,6,0
                db 0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0
                db 0,0,6,6,6,6,6,6,6,6,6,6,6,6,0,0
                db 0,0,0,0,6,6,14,14,14,14,6,6,0,0,0,0
                db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
                db 0,0,0,0,14,14,14,14,14,14,14,14,0,0,0,0
                db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
                db 0,0,0,8,8,8,8,0,0,8,8,8,8,0,0,0
                db 0,0,8,8,8,8,8,0,0,8,8,8,8,8,0,0
                db 0,0,8,8,8,8,0,0,0,0,8,8,8,8,0,0

; --- SPRITE: small Mario running, 16x16 ---
spr_mario_run:
                db 0,0,0,0,4,4,4,4,4,0,0,0,0,0,0,0
                db 0,0,0,4,4,4,4,4,4,4,4,0,0,0,0,0
                db 0,0,0,6,6,6,12,12,6,12,0,0,0,0,0,0
                db 0,0,6,12,6,12,12,12,6,12,12,12,0,0,0,0
                db 0,0,6,12,6,6,12,12,12,6,12,12,12,0,0,0
                db 0,0,0,6,12,12,12,12,6,6,6,6,0,0,0,0
                db 0,0,0,0,12,12,12,12,12,12,12,0,0,0,0,0
                db 0,0,0,4,4,4,1,4,4,4,0,0,0,0,0,0
                db 0,0,4,4,4,4,1,1,4,4,4,0,0,0,0,0
                db 0,12,12,4,4,1,1,1,1,1,4,0,0,0,0,0
                db 0,12,12,12,1,1,1,1,1,1,1,0,0,0,0,0
                db 0,0,12,12,1,1,1,1,1,1,1,0,0,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0
                db 0,0,6,6,1,1,1,0,1,1,6,6,0,0,0,0
                db 0,6,6,6,0,0,0,0,0,0,6,6,6,0,0,0
                db 0,6,6,0,0,0,0,0,0,0,0,0,6,6,0,0

; --- SPRITE: small Mario jumping, 16x16 ---
spr_mario_jump:
                db 0,0,0,0,4,4,4,4,4,0,0,0,0,12,12,0
                db 0,0,0,4,4,4,4,4,4,4,4,0,0,12,12,12
                db 0,0,0,6,6,6,12,12,6,12,0,0,0,12,12,0
                db 0,0,6,12,6,12,12,12,6,12,12,12,0,0,0,0
                db 0,0,6,12,6,6,12,12,12,6,12,12,12,0,0,0
                db 0,0,0,6,12,12,12,12,6,6,6,6,0,0,0,0
                db 0,0,0,0,12,12,12,12,12,12,12,0,0,0,0,0
                db 0,0,4,4,4,4,1,4,4,4,4,4,0,0,0,0
                db 0,4,4,4,4,4,1,1,4,4,4,4,4,0,0,0
                db 0,12,12,4,4,1,1,1,1,1,1,4,4,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0
                db 0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0
                db 0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0
                db 0,0,1,1,1,0,0,0,0,0,0,1,1,1,0,0
                db 0,6,6,6,6,0,0,0,0,0,0,6,6,6,6,0
                db 0,6,6,6,6,0,0,0,0,0,0,6,6,6,6,0

; --- SPRITE: Super Mario top half (16x16), used for all poses ---
spr_super_top:
                db 0,0,0,0,0,4,4,4,4,4,0,0,0,0,0,0
                db 0,0,0,0,4,4,4,4,4,4,4,4,0,0,0,0
                db 0,0,0,0,6,6,6,12,12,6,12,0,0,0,0,0
                db 0,0,0,6,12,6,12,12,12,6,12,12,12,0,0,0
                db 0,0,0,6,12,6,6,12,12,12,6,12,12,12,0,0
                db 0,0,0,0,6,12,12,12,12,6,6,6,6,0,0,0
                db 0,0,0,0,0,12,12,12,12,12,12,12,0,0,0,0
                db 0,0,0,0,4,4,4,1,4,4,4,0,0,0,0,0
                db 0,0,0,4,4,4,4,1,4,4,1,4,4,4,0,0
                db 0,4,4,4,4,4,4,1,1,1,1,4,4,4,4,0
                db 0,12,12,4,4,1,14,1,1,14,1,4,4,12,12,0
                db 0,12,12,12,1,1,1,1,1,1,1,1,12,12,12,0
                db 0,12,12,12,1,1,1,1,1,1,1,1,12,12,12,0
                db 0,12,12,1,1,1,1,1,1,1,1,1,1,12,12,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0

; --- SPRITE: Super Mario bottom half, standing ---
spr_super_stand_bot:
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,0,0,1,1,1,1,0,0,0
                db 0,0,6,6,6,6,6,0,0,6,6,6,6,6,0,0
                db 0,6,6,6,6,6,6,0,0,6,6,6,6,6,6,0
                db 0,6,6,6,6,6,6,0,0,6,6,6,6,6,6,0

; --- SPRITE: Super Mario bottom half, running ---
spr_super_run_bot:
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,1,1,1,1,1,0,0,0,1,1,1,1,0,0
                db 0,0,1,1,1,1,1,0,0,0,1,1,1,1,0,0
                db 0,0,1,1,1,1,1,0,0,0,1,1,1,1,0,0
                db 0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
                db 0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
                db 0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
                db 0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0
                db 0,6,6,6,6,6,0,0,0,0,0,0,6,6,6,6
                db 6,6,6,6,6,6,0,0,0,0,0,0,6,6,6,0
                db 6,6,6,6,6,6,0,0,0,0,0,0,6,6,6,0

; --- SPRITE: Super Mario bottom half, jumping ---
spr_super_jump_bot:
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
                db 0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0
                db 0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0
                db 0,1,1,1,1,1,0,0,0,0,1,1,1,1,1,0
                db 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
                db 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
                db 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
                db 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
                db 6,6,6,6,6,0,0,0,0,0,0,0,6,6,6,6
                db 6,6,6,6,6,6,0,0,0,0,0,0,0,6,6,6
                db 6,6,6,6,6,6,0,0,0,0,0,0,0,6,6,6

; --- SPRITE: Goomba flattened, 16x16 ---
spr_goomba_flat:
                times 160 db 0
                db 0,0,0,6,6,6,6,6,6,6,6,6,6,0,0,0
                db 0,0,6,6,6,6,6,6,6,6,6,6,6,6,0,0
                db 0,6,6,15,15,6,6,6,6,6,15,15,6,6,6,0
                db 0,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0
                db 0,0,8,8,8,8,14,14,14,14,8,8,8,8,0,0
                db 0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0

; --- SPRITE: Koopa Troopa, 16x16 ---
spr_koopa:
                db 0,0,0,0,0,0,0,0,0,0,14,14,14,0,0,0
                db 0,0,0,0,0,0,0,0,0,14,14,14,14,14,0,0
                db 0,0,0,0,0,0,0,0,0,14,15,8,14,14,0,0
                db 0,0,0,0,0,0,0,0,0,14,14,14,14,14,0,0
                db 0,0,0,0,0,0,0,0,14,14,14,14,0,0,0,0
                db 0,0,0,2,2,2,2,2,2,14,14,0,0,0,0,0
                db 0,0,2,2,15,15,2,2,15,15,2,14,0,0,0,0
                db 0,0,2,2,15,15,2,2,15,15,2,2,0,0,0,0
                db 0,0,2,2,2,2,2,2,2,2,2,2,0,0,0,0
                db 0,0,0,2,2,2,2,2,2,2,2,0,0,0,0,0
                db 0,0,0,14,14,14,14,14,14,14,14,0,0,0,0,0
                db 0,0,0,0,14,14,14,14,14,14,0,0,0,0,0,0
                db 0,0,0,14,14,14,0,0,14,14,14,0,0,0,0,0
                db 0,0,0,14,14,14,0,0,14,14,14,0,0,0,0,0
                db 0,6,6,6,6,6,0,0,0,6,6,6,6,6,0,0
                db 0,6,6,6,6,6,0,0,0,6,6,6,6,6,0,0

; --- SPRITE: Koopa shell, 16x16 ---
spr_shell:
                times 128 db 0
                db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
                db 0,0,0,0,2,2,15,2,2,15,2,2,0,0,0,0
                db 0,0,0,2,2,2,15,2,2,15,2,2,2,0,0,0
                db 0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0
                db 0,0,2,2,2,2,2,2,2,2,2,2,2,2,0,0
                db 0,0,14,14,2,2,2,2,2,2,2,2,14,14,0,0
                db 0,0,0,14,14,14,14,14,14,14,14,14,14,0,0,0
                db 0,0,0,0,14,14,14,14,14,14,14,14,0,0,0,0

; --- SPRITE: mushroom power-up, 16x16 ---
spr_mushroom:
                db 0,0,0,0,0,4,4,4,4,4,4,0,0,0,0,0
                db 0,0,0,4,4,4,15,15,4,4,4,4,0,0,0,0
                db 0,0,4,4,15,15,15,15,4,4,4,15,15,4,0,0
                db 0,4,4,4,15,15,15,15,4,4,4,4,15,4,4,0
                db 0,4,4,4,4,15,15,4,4,4,4,4,4,4,4,0
                db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                db 0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0
                db 0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0
                db 0,0,0,0,15,15,15,15,15,15,15,15,0,0,0,0
                db 0,0,0,0,15,0,0,15,15,0,0,15,0,0,0,0
                db 0,0,0,0,15,0,0,15,15,0,0,15,0,0,0,0
                db 0,0,0,0,15,15,15,15,15,15,15,15,0,0,0,0
                db 0,0,0,0,15,15,15,15,15,15,15,15,0,0,0,0
                db 0,0,0,0,15,15,15,15,15,15,15,15,0,0,0,0
                db 0,0,0,0,15,15,15,15,15,15,15,15,0,0,0,0

; --- SPRITE: coin, 16x16 ---
spr_coin:
                times 16 db 0
                db 0,0,0,0,0,0,14,14,14,14,0,0,0,0,0,0
                db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
                times 10 db 0,0,0,0,14,14,14,6,6,14,14,14,0,0,0,0
                db 0,0,0,0,0,14,14,14,14,14,14,0,0,0,0,0
                db 0,0,0,0,0,0,14,14,14,14,0,0,0,0,0,0
                times 16 db 0

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
; PROCEDURE: resetmap
; Purpose : copies the original map into the working map
; Inputs  : none
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
resetmap:       push es
                push cx
                push si
                push di

                push ds
                pop es                  ; es = ds
                cld
                mov si, originalmap
                mov di, workmap
                mov cx, 720
                rep movsb

                pop di
                pop si
                pop cx
                pop es
                ret

; ------------------------------------------------------------
; PROCEDURE: gettile
; Purpose : gives the tile code at a pixel position
; Inputs  : [bp+6] = px, [bp+4] = py
; Outputs : ax = tile code (0 if outside the map height)
; Changes : only ax
; ------------------------------------------------------------
gettile:        push bp
                mov bp, sp
                push bx
                push si

                mov ax, 0               ; default answer = sky
                mov bx, [bp+4]          ; bx = py
                cmp bx, 192
                jae gettile_end         ; outside the map

                shr bx, 1
                shr bx, 1
                shr bx, 1
                shr bx, 1               ; bx = row
                mov al, 60
                mul bl                  ; ax = row * 60
                mov si, [bp+6]          ; si = px
                shr si, 1
                shr si, 1
                shr si, 1
                shr si, 1               ; si = column
                add si, ax              ; si = row*60 + column
                mov al, [workmap+si]
                mov ah, 0

gettile_end:    pop si
                pop bx
                pop bp
                ret 4

; ------------------------------------------------------------
; PROCEDURE: drawtile
; Purpose : draws one 16x16 tile
; Inputs  : [bp+8] = x, [bp+6] = y, [bp+4] = tile code
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
drawtile:       push bp
                mov bp, sp
                push ax
                push bx

                mov bx, [bp+4]          ; bx = tile code
                cmp bx, 0
                je tile_sky
                cmp bx, 11
                je tile_coin
                cmp bx, 12
                je tile_pole

                ; solid tile: black border, then coloured inside
                push word [bp+8]
                push word [bp+6]
                mov ax, 16
                push ax
                push ax
                mov ax, 0
                push ax
                call fillrect

                mov ax, [bp+8]
                add ax, 1
                push ax
                mov ax, [bp+6]
                add ax, 1
                push ax
                mov ax, 14
                push ax
                push ax
                mov al, [tilecolour+bx]
                mov ah, 0
                push ax
                call fillrect
                jmp tile_done

tile_sky:       push word [bp+8]
                push word [bp+6]
                mov ax, 16
                push ax
                push ax
                mov ax, 9
                push ax
                call fillrect
                jmp tile_done

tile_coin:      push word [bp+8]        ; sky behind the coin
                push word [bp+6]
                mov ax, 16
                push ax
                push ax
                mov ax, 9
                push ax
                call fillrect

                mov ax, [bp+8]          ; yellow coin
                add ax, 5
                push ax
                mov ax, [bp+6]
                add ax, 3
                push ax
                mov ax, 6
                push ax
                mov ax, 10
                push ax
                mov ax, 14
                push ax
                call fillrect
                jmp tile_done

tile_pole:      push word [bp+8]        ; sky behind the pole
                push word [bp+6]
                mov ax, 16
                push ax
                push ax
                mov ax, 9
                push ax
                call fillrect

                mov ax, [bp+8]          ; white pole
                add ax, 7
                push ax
                push word [bp+6]
                mov ax, 2
                push ax
                mov ax, 16
                push ax
                mov ax, 15
                push ax
                call fillrect

tile_done:      pop bx
                pop ax
                pop bp
                ret 6

; ------------------------------------------------------------
; PROCEDURE: drawmap
; Purpose : draws 20 columns of the working map, rows 1 to 11
; Inputs  : [bp+4] = first column to draw (0 to 40)
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
drawmap:        push bp
                mov bp, sp
                push ax
                push bx
                push cx
                push dx
                push si

                mov dx, 1               ; dx = row (1 to 11)
nextmaprow:     mov cx, 0               ; cx = screen column (0 to 19)

nextmapcol:     mov al, dl
                mov bl, 60
                mul bl                  ; ax = row * 60
                add ax, [bp+4]          ; + first column
                add ax, cx              ; + screen column
                mov si, ax
                mov al, [workmap+si]    ; al = tile code
                mov ah, 0

                mov bx, cx
                shl bx, 1
                shl bx, 1
                shl bx, 1
                shl bx, 1               ; bx = x = column * 16
                push bx
                mov bx, dx
                shl bx, 1
                shl bx, 1
                shl bx, 1
                shl bx, 1               ; bx = y = row * 16
                push bx
                push ax                 ; tile code
                call drawtile

                inc cx
                cmp cx, 20
                jne nextmapcol

                inc dx
                cmp dx, 12
                jne nextmaprow

                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                pop bp
                ret 2
; ------------------------------------------------------------
; PROCEDURE: drawsprite
; Purpose : draws a 16x16 sprite, colour 0 is transparent
;           pixels outside the screen are skipped (clipping)
; Inputs  : [bp+10] = x, [bp+8] = y (can be negative),
;           [bp+6] = address of sprite, [bp+4] = flags
;           (flags bit 0 = 1 means mirrored, facing left)
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
drawsprite:     push bp
                mov bp, sp
                push es
                push ax
                push bx
                push cx
                push dx
                push si
                push di

                mov ax, [drawseg]
                mov es, ax
                mov si, [bp+6]          ; si = sprite data
                mov dx, 0               ; dx = sprite row (0 to 15)

sprow:          mov ax, [bp+8]
                add ax, dx              ; ax = screen y of this row
                cmp ax, 0
                jl nextsprow            ; above the screen
                cmp ax, 200
                jge nextsprow           ; below the screen

                mov bx, ax
                mov cl, 8
                shl ax, cl              ; y*256
                mov cl, 6
                shl bx, cl              ; y*64
                add ax, bx
                mov di, ax              ; di = y*320

                mov cx, 0               ; cx = sprite column (0 to 15)

spcol:          mov bx, [bp+10]
                add bx, cx              ; bx = screen x of this pixel
                cmp bx, 0
                jl nextspcol            ; left of the screen
                cmp bx, 320
                jge nextspcol           ; right of the screen

                push bx                 ; save screen x
                mov bx, cx              ; bx = source column
                test word [bp+4], 1
                jz nomirror
                mov bx, 15
                sub bx, cx              ; mirrored: 15 - column
nomirror:       mov ax, dx
                shl ax, 1
                shl ax, 1
                shl ax, 1
                shl ax, 1               ; ax = row * 16
                add ax, bx
                mov bx, ax
                mov al, [si+bx]         ; al = colour
                pop bx                  ; bx = screen x

                cmp al, 0
                je nextspcol            ; transparent

                push di
                add di, bx
                mov [es:di], al
                pop di

nextspcol:      inc cx
                cmp cx, 16
                jne spcol

nextsprow:      inc dx
                cmp dx, 16
                jne sprow

                pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                pop es
                pop bp
                ret 8
; ------------------------------------------------------------
; PROCEDURE: drawsuper
; Purpose : draws Super Mario (16x32) = top half + bottom half
; Inputs  : [bp+10] = x, [bp+8] = y (top of sprite),
;           [bp+6] = address of the bottom half, [bp+4] = flags
; Outputs : none
; Changes : no register is changed
; ------------------------------------------------------------
drawsuper:      push bp
                mov bp, sp
                push ax

                push word [bp+10]       ; top half
                push word [bp+8]
                mov ax, spr_super_top
                push ax
                push word [bp+4]
                call drawsprite

                push word [bp+10]       ; bottom half, 16 pixels lower
                mov ax, [bp+8]
                add ax, 16
                push ax
                push word [bp+6]
                push word [bp+4]
                call drawsprite

                pop ax
                pop bp
                ret 8
; ------------------------------------------------------------
; MAIN - Part 4 test: all sprites
; ------------------------------------------------------------
start:          mov ax, 0x0013          ; VGA mode 13h
                int 0x10

                call resetmap
                mov ax, 0
                push ax
                call drawmap

                ; --- row 1 (y=40): Mario run, Mario jump ---
                mov ax, 20
                push ax
                mov ax, 40
                push ax
                mov ax, spr_mario_run
                push ax
                mov ax, 0
                push ax
                call drawsprite

                mov ax, 50
                push ax
                mov ax, 40
                push ax
                mov ax, spr_mario_jump
                push ax
                mov ax, 0
                push ax
                call drawsprite

                ; --- row 2 (y=70): goomba flat, koopa, shell, mushroom, coin ---
                mov ax, 20
                push ax
                mov ax, 70
                push ax
                mov ax, spr_goomba_flat
                push ax
                mov ax, 0
                push ax
                call drawsprite

                mov ax, 50
                push ax
                mov ax, 70
                push ax
                mov ax, spr_koopa
                push ax
                mov ax, 0
                push ax
                call drawsprite

                mov ax, 80
                push ax
                mov ax, 70
                push ax
                mov ax, spr_shell
                push ax
                mov ax, 0
                push ax
                call drawsprite

                mov ax, 110
                push ax
                mov ax, 70
                push ax
                mov ax, spr_mushroom
                push ax
                mov ax, 0
                push ax
                call drawsprite

                mov ax, 140
                push ax
                mov ax, 70
                push ax
                mov ax, spr_coin
                push ax
                mov ax, 0
                push ax
                call drawsprite

                ; --- row 3 (y=100): Super Mario stand, run, jump, mirrored ---
                mov ax, 20
                push ax
                mov ax, 100
                push ax
                mov ax, spr_super_stand_bot
                push ax
                mov ax, 0
                push ax
                call drawsuper

                mov ax, 50
                push ax
                mov ax, 100
                push ax
                mov ax, spr_super_run_bot
                push ax
                mov ax, 0
                push ax
                call drawsuper

                mov ax, 80
                push ax
                mov ax, 100
                push ax
                mov ax, spr_super_jump_bot
                push ax
                mov ax, 0
                push ax
                call drawsuper

                mov ax, 110
                push ax
                mov ax, 100
                push ax
                mov ax, spr_super_stand_bot
                push ax
                mov ax, 1
                push ax
                call drawsuper

                mov ah, 0x00            ; wait for a key
                int 0x16

                mov ax, 0x0003          ; back to text mode
                int 0x10

                mov ax, 0x4c00          ; exit to DOS
                int 0x21