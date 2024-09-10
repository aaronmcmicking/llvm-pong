; ModuleID = 'helloworld.c'
target triple = "x86_64-pc-linux-gnu"

; globals
@WINDOW_TITLE = private unnamed_addr constant [11 x i8] c"RL in LLVM\00"
@WIN_WIDTH  = constant i32 1000
@WIN_HEIGHT = constant i32 1000

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

@PADDLE_SPEED   = constant i32 30
@PADDLE_WIDTH   = constant i32 15
@PADDLE_HEIGHT  = constant i32 125
@BALL_RADIUS    = constant float 10.0

; external functions
declare void @InitWindow(i32, i32, i8*) 
declare zeroext i1 @WindowShouldClose() 
declare void @CloseWindow() 
declare void @SetTargetFPS(i32)

declare void @BeginDrawing() 
declare void @EndDrawing() 
declare void @ClearBackground(i32)

declare void @DrawRectangle(i32, i32, i32, i32, i32)
declare void @DrawCircle(i32, i32, float, i32)

declare i1 @IsKeyPressed(i32)
declare i1 @IsKeyDown(i32)

declare i32 @printf(i8* noundef, ...) 

; local functions
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
  ;%win_width = alloca i32  
  ;%win_height = alloca i32  
  ;store i32 1000, i32* %win_width 
  ;store i32 1000, i32* %win_height  
  %win_width = load i32, i32* @WIN_WIDTH
  %win_height = load i32, i32* @WIN_HEIGHT
  ;%win_width_loc = load i32, i32* %win_width 
  ;%win_height_loc = load i32, i32* %win_height 
  call void @InitWindow(i32 %win_width, i32 %win_height, i8* getelementptr ([11 x i8], [11 x i8]* @WINDOW_TITLE, i64 0, i64 0))
  call void @SetTargetFPS(i32 60)
  br label %ball_setup

ball_setup:
  %ball_x = alloca i32
  %ball_y = alloca i32
  %ball_y_vel = alloca i32
  %ball_x_vel = alloca i32
  %ball_buffer = alloca i32
  store i32 500, i32* %ball_x
  store i32 500, i32* %ball_y
  store i32 10, i32* %ball_y_vel
  store i32 -5, i32* %ball_x_vel
  store i32 5, i32* %ball_buffer
  br label %left_paddle_setup

left_paddle_setup:
  %paddle_width = load i32, i32* @PADDLE_WIDTH
  %paddle_height = load i32, i32* @PADDLE_HEIGHT
  %left_paddle_width = alloca i32
  %left_paddle_height = alloca i32
  %left_paddle_x = alloca i32
  %left_paddle_y = alloca i32
  store i32 %paddle_width, i32* %left_paddle_width
  store i32 %paddle_height, i32* %left_paddle_height
  store i32 50, i32* %left_paddle_x
  store i32 50, i32* %left_paddle_y
  br label %right_paddle_setup

right_paddle_setup:
  %right_paddle_width = alloca i32
  %right_paddle_height = alloca i32
  %right_paddle_x = alloca i32
  %right_paddle_y = alloca i32
  store i32 %paddle_width, i32* %right_paddle_width
  store i32 %paddle_height, i32* %right_paddle_height
  store i32 950, i32* %right_paddle_x
  store i32 50, i32* %right_paddle_y
  br label %main_window_loop_check_conds

main_window_loop_check_conds:                                                
  %win_should_close = call i1 @WindowShouldClose()
  %win_should_not_close = xor i1 %win_should_close, true        ; xor with true -> flip bit
  br i1 %win_should_not_close, label %main_window_loop_body, label %main_window_loop_end

main_window_loop_body:
  br label %move_left_paddle

move_left_paddle:
  ;%new_lp_speed = call i32 move_paddle(i32* @KEY_W, i32 %left_paddle_y) 
  %key_w = load i32, i32* @KEY_W
  %key_s = load i32, i32* @KEY_S
  %paddle_vel = load i32, i32* @PADDLE_SPEED
  %w_pressed = call i1 @IsKeyDown(i32 %key_w)
  %s_pressed = call i1 @IsKeyDown(i32 %key_s)
  %lp_pos = load i32, i32* %left_paddle_y
  %lp_pos_moved_down = call i32 @cond_add(i1 %s_pressed, i32 %lp_pos, i32 %paddle_vel)
  %lp_pos_moved_up = call i32 @cond_sub(i1 %w_pressed, i32 %lp_pos_moved_down, i32 %paddle_vel)
  store i32 %lp_pos_moved_up, i32* %left_paddle_y
  br label %move_right_paddle

move_right_paddle:
  ;%new_lp_speed = call i32 move_paddle(i32* @KEY_W, i32 %right_paddle_y) 
  %key_up = load i32, i32* @KEY_UP
  %key_down = load i32, i32* @KEY_DOWN
  ;%paddle_vel = load i32, i32* @PADDLE_SPEED
  %up_pressed = call i1 @IsKeyDown(i32 %key_up)
  %down_pressed = call i1 @IsKeyDown(i32 %key_down)
  %rp_pos = load i32, i32* %right_paddle_y
  %rp_pos_moved_down = call i32 @cond_add(i1 %down_pressed, i32 %rp_pos, i32 %paddle_vel)
  %rp_pos_moved_up = call i32 @cond_sub(i1 %up_pressed, i32 %rp_pos_moved_down, i32 %paddle_vel)
  store i32 %rp_pos_moved_up, i32* %right_paddle_y
  br label %move_ball

move_ball:
  br label %bounce_wall_off_roof_floor

bounce_wall_off_roof_floor:
  %b_pos_y = load i32, i32* %ball_y
  %win_height_y = load i32, i32* @WIN_HEIGHT
  %at_roof = icmp slt i32 %b_pos_y, 10
  %at_floor = icmp sgt i32 %b_pos_y, %win_height_y
  %at_roof_or_floor = or i1 %at_roof, %at_floor
  br i1 %at_roof_or_floor, label %rev_ball_y_vel, label %dont_flip_y_vel

rev_ball_y_vel:
  ; flip y vel 
  %loc_ball_y_vel = load i32, i32* %ball_y_vel
  %flipped_ball_y_vel = xor i32 %loc_ball_y_vel, -1
  store i32 %flipped_ball_y_vel, i32* %ball_y_vel
  br label %dont_flip_y_vel
dont_flip_y_vel:
  %cur_ball_y_vel = load i32, i32* %ball_y_vel
  %b_pos_new_y = add nsw i32 %b_pos_y, %cur_ball_y_vel
  store i32 %b_pos_new_y, i32* %ball_y
br label %bounce_off_paddle

bounce_off_paddle:
  %b_pos_x = load i32, i32* %ball_x

  %lp_x = load i32, i32* %left_paddle_x
  %lp_w = load i32, i32* @PADDLE_WIDTH
  ;%lp_offset = sdiv i32 %lp_w, 2
  ;%lp_bound = add nsw i32 %lp_x, %lp_offset
  %lp_bound = add nsw i32 %lp_x, %lp_w
  %b_rad_float = load float, float* @BALL_RADIUS
  %b_rad = fptosi float %b_rad_float to i32
  %b_l_bound = sub i32 %b_pos_x, %b_rad
  %b_in_lp_width = icmp slt i32 %b_l_bound, %lp_bound
  br i1 %b_in_lp_width, label %rev_ball_x_vel, label %update_ball_pos

rev_ball_x_vel:
  %loc_ball_x_vel = load i32, i32* %ball_x_vel
  %flipped_ball_x_vel = xor i32 %loc_ball_x_vel, -1
  store i32 %flipped_ball_x_vel, i32* %ball_x_vel
  %ball_x_buffer = load i32, i32* %ball_buffer
  %buffered_ball_x = add nsw i32 %b_pos_x, %ball_x_buffer
  store i32 %buffered_ball_x, i32* %ball_x_vel
  %flipped_ball_buffer = xor i32 %ball_x_buffer, -1
  store i32 %flipped_ball_x_vel, i32* %ball_buffer
  br label %update_ball_pos

update_ball_pos:
  %loc2_ball_x_vel = load i32, i32* %ball_x_vel
  %new_b_pos_x = add i32 %b_pos_x, %loc2_ball_x_vel
  store i32 %new_b_pos_x, i32* %ball_x
  br label %render

render:
  %rl_black = load i32, i32* @RLCOLOR_BLACK
  %paddle_col = load i32, i32* @RLCOLOR_WHITE
  %loc_left_paddle_x = load i32, i32* %left_paddle_x
  %loc_left_paddle_y = load i32, i32* %left_paddle_y
  %loc_left_paddle_width = load i32, i32* %left_paddle_width
  %loc_left_paddle_height = load i32, i32* %left_paddle_height

  %loc_right_paddle_x = load i32, i32* %right_paddle_x
  %loc_right_paddle_y = load i32, i32* %right_paddle_y
  %loc_right_paddle_width = load i32, i32* %right_paddle_width
  %loc_right_paddle_height = load i32, i32* %right_paddle_height

  %loc_ball_x = load i32, i32* %ball_x
  %loc_ball_y = load i32, i32* %ball_y

  call void @BeginDrawing()
  call void @ClearBackground(i32 %rl_black)
  ; left paddle
  call void @DrawRectangle(i32 %loc_left_paddle_x, i32 %loc_left_paddle_y, i32 %loc_left_paddle_width, i32 %loc_left_paddle_height, i32 %paddle_col)
  ; right paddle
  call void @DrawRectangle(i32 %loc_right_paddle_x, i32 %loc_right_paddle_y, i32 %loc_right_paddle_width, i32 %loc_right_paddle_height, i32 %paddle_col)
  ; ball
  %ball_radius = load float, float* @BALL_RADIUS
  call void @DrawCircle(i32 %loc_ball_x, i32 %loc_ball_y, float %ball_radius, i32 %paddle_col)
  ; end draw
  call void @EndDrawing()
  br label %main_window_loop_check_conds


main_window_loop_end:
  call void @CloseWindow()
  ret i32 0
}

