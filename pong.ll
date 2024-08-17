; ModuleID = 'helloworld.c'
target triple = "x86_64-pc-linux-gnu"

; globals
@WINDOW_TITLE = private unnamed_addr constant [11 x i8] c"RL in LLVM\00"
@KEY_DOWN   = constant i32 264
@KEY_UP     = constant i32 265
@KEY_S      = constant i32 83
@KEY_W      = constant i32 87
@KEY_R      = constant i32 82
; note: rl colors are packed as abgr when an int
@RLCOLOR_BLACK  = constant i32 0
@RLCOLOR_WHITE  = constant i32 4294967295
@RLCOLOR_RED    = constant i32 4281805286
@RLCOLOR_BLUE   = constant i32 4294015232
@RLCOLOR_GREEN  = constant i32 4281394176

@PADDLE_SPEED = constant i32 30

; external functions
declare void @InitWindow(i32, i32, i8*) 
declare zeroext i1 @WindowShouldClose() 
declare void @CloseWindow() 
declare void @SetTargetFPS(i32)

declare void @BeginDrawing() 
declare void @EndDrawing() 
declare void @ClearBackground(i32)

declare void @DrawRectangle(i32, i32, i32, i32, i32)

declare i1 @IsKeyPressed(i32)
declare i1 @IsKeyDown(i32)

declare i32 @printf(i8* noundef, ...) 

; local functions
;define i32 @move_paddle(i32* _key, i32 paddle_pos){ 
;    %key_down = call i1 @KeyIsDown(i32* _key)
;    br i1 %key_down, label %do_move, label %end_move
;do_move:
;  %vel = load i32, i32* @PADDLE_SPEED
;  %new_paddle_pos = add i32 %paddle_pos, vel
;  br %end_move
;do_not_move
;  %new_paddle_pos = i32 %paddle_pos
;  br %end_move
;end_move:
;    ret i32 %new_paddle_pos
;}

define i32 @cond_add(i1 %condition, i32 %base, i32 %addition){
  br i1 %condition, label %_add, label %_no_add
_add:
  %new_val = add i32 %base, %addition
  ret i32 %new_val
_no_add:
  ret i32 %base
}

define i32 @cond_sub(i1 %condition, i32 %base, i32 %subtraction){
  br i1 %condition, label %_sub, label %_no_sub
_sub:
  %new_val = sub i32 %base, %subtraction
  ret i32 %new_val
_no_sub:
  ret i32 %base
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() {
  %win_width = alloca i32  
  %win_height = alloca i32  
  store i32 1000, i32* %win_width 
  store i32 1000, i32* %win_height  
  %win_width_loc = load i32, i32* %win_width 
  %win_height_loc = load i32, i32* %win_height 
  call void @InitWindow(i32 %win_width_loc, i32 %win_height_loc, i8* getelementptr ([11 x i8], [11 x i8]* @WINDOW_TITLE, i64 0, i64 0))
  call void @SetTargetFPS(i32 60)
  br label %rec_setup

rec_setup:
  %rec_width = alloca i32
  %rec_height = alloca i32
  %rec_x = alloca i32
  %rec_y = alloca i32
  store i32 100, i32* %rec_width
  store i32 100, i32* %rec_height
  store i32 50, i32* %rec_x
  store i32 50, i32* %rec_y
  br label %main_window_loop_check_conds

main_window_loop_check_conds:                                                
  %win_should_close = call i1 @WindowShouldClose()
  %win_should_not_close = xor i1 %win_should_close, true        ; xor with true -> flip bit
  br i1 %win_should_not_close, label %main_window_loop_body, label %main_window_loop_end

main_window_loop_body:
  %loc_rec_x = load i32, i32* %rec_x
  %loc_rec_y = load i32, i32* %rec_y
  %loc_rec_width = load i32, i32* %rec_width
  %loc_rec_height = load i32, i32* %rec_height
  %rl_black = load i32, i32* @RLCOLOR_BLACK
  %rec_col = load i32, i32* @RLCOLOR_BLUE
  call void @BeginDrawing()
  call void @ClearBackground(i32 %rl_black)
  call void @DrawRectangle(i32 %loc_rec_x, i32 %loc_rec_y, i32 %loc_rec_width, i32 %loc_rec_height, i32 %rec_col)
  call void @EndDrawing()
  ;%key_w = load i32, i32* @KEY_W
  br label %move_left_paddle
  ;%w_pressed = call i1 @IsKeyDown(i32 %key_w)
  ;br i1 %w_pressed, label %increment_rec, label %main_window_loop_check_conds
  ;br label %increment_rec

increment_rec:
  %loc_rec_x1 = load i32, i32* %rec_x
  %inc_rec_x = add i32 %loc_rec_x1, 1
  store i32 %inc_rec_x, i32* %rec_x
  br label %main_window_loop_check_conds

move_left_paddle:
  ;%new_lp_speed = call i32 move_paddle(i32* @KEY_W, i32 %rec_y) 
  %key_w = load i32, i32* @KEY_W
  %key_s = load i32, i32* @KEY_S
  %paddle_vel = load i32, i32* @PADDLE_SPEED
  %w_pressed = call i1 @IsKeyDown(i32 %key_w)
  %s_pressed = call i1 @IsKeyDown(i32 %key_s)
  %lp_pos = load i32, i32* %rec_y
  %lp_pos_moved_down = call i32 @cond_add(i1 %s_pressed, i32 %lp_pos, i32 %paddle_vel)
  %lp_pos_moved_up = call i32 @cond_sub(i1 %w_pressed, i32 %lp_pos_moved_down, i32 %paddle_vel)
  store i32 %lp_pos_moved_up, i32* %rec_y
  br label %main_window_loop_check_conds

main_window_loop_end:
  call void @CloseWindow()
  ret i32 0
}

