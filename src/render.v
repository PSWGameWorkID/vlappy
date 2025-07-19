module main
import raylib as rl

fn (mut this Game) render() 
{
	rl.begin_texture_mode(this.assets.fb_origsize)

	match this.scene {
		.main_menu {
			this.draw_main_menu()
		}
		.in_game, .paused {
			this.draw_gameplay()
		}
		.game_over_cs, .game_over_opt {
			this.draw_gameover()
		}
	}

	if this.debug_on {
		this.render_debug()
	}

	rl.end_texture_mode()
	rl.clear_background(rl.white)

	rl.draw_texture_pro(
		this.assets.fb_origsize.texture, 
		rl.Rectangle {0,0,240,-320},
		rl.Rectangle {0,0,720,960},
		rl.Vector2{0,0},
		f32(0.0),
		rl.white
	)

	if this.draw_fps {
		rl.draw_fps(10,10)
	}
}

fn (this Game) render_pipe(mut pipe &rl.Vector3)
{
	if pipe.z <= 0 { return }

	gap_y_at := lerp_f1(80, 200, pipe.y)
	gap_size_half := this.get_pipe_gap() / 2
	pipe_width := 32
	mut gap_top := gap_y_at - gap_size_half
	mut gap_bottom := gap_y_at + gap_size_half

	gap_top = int_max(gap_top, 32)
	gap_bottom = int_min(gap_bottom, 230)

	pipe_l := pipe.x - (pipe_width / 2)

	rl.draw_texture_pro(
		this.assets.spr_pipes, 
		rl.Rectangle {0, 0, 32, 16},
		rl.Rectangle {pipe_l, 0, pipe_width, gap_top - 16},
		rl.Vector2 {0.0,0.0},
		f32(0.0),
		rl.white
	)

	rl.draw_texture_pro(
		this.assets.spr_pipes, 
		rl.Rectangle {0, 16, 32, 16},
		rl.Rectangle {pipe_l, gap_top - 16, pipe_width, 16},
		rl.Vector2 {0.0,0.0},
		f32(0.0),
		rl.white
	)

	rl.draw_texture_pro(
		this.assets.spr_pipes, 
		rl.Rectangle {0, 32, 32, 16},
		rl.Rectangle {pipe_l, gap_bottom, pipe_width, 16},
		rl.Vector2 {0.0,0.0},
		f32(0.0),
		rl.white
	)

	rl.draw_texture_pro(
		this.assets.spr_pipes, 
		rl.Rectangle {0, 48, 32, 16},
		rl.Rectangle {pipe_l, gap_bottom + 16, pipe_width, 244 - gap_bottom},
		rl.Vector2 {0.0,0.0},
		f32(0.0),
		rl.white
	)
}

fn (mut this Game) draw_gameplay()
{
	this.draw_background()
	this.draw_bird()
	this.render_all_pipes()
	this.draw_foreground()

	if this.scene == .paused {
		this.draw_gameplay_paused()
	}

	this.draw_gameplay_hud()
}

fn (mut this Game) draw_gameplay_paused()
{
	paused_text := "Paused"
	info_1 := "[SPACE] / [ESC] - Resume"
	info_2 := "[BACKSPACE] / [TAB] - Main Menu"
	
	paused_w := rl.measure_text(paused_text, 30)
	info_1_w := rl.measure_text(info_1, 5)
	info_2_w := rl.measure_text(info_2, 5)

	rl.draw_text(paused_text, 120 - (paused_w / 2), 60, 30, rl.black)
	rl.draw_text(info_1, 120 - (info_1_w / 2), 100, 5, rl.black)
	rl.draw_text(info_2, 120 - (info_2_w / 2), 110, 5, rl.black)
}

fn (mut this Game) draw_gameplay_hud()
{
	c_score := "SCORE"
	h_score := "HI"

	rl.draw_text(h_score, 20, 20, 10, rl.white)
	rl.draw_text(c_score, 20, 30, 10, rl.white)

	rl.draw_text(": ${this.state.hi_score:00000000}", 60, 20, 10, rl.white)
	rl.draw_text(": ${this.state.current_score:00000000}", 60, 30, 10, rl.white)
}

fn (mut this Game) draw_bird()
{
	frame_index := int_min(int(this.state.bird_animation_time * 8), 3)
	frame_uv_x := (frame_index % 2) * 32
	frame_uv_y:= (frame_index / 2) * 16

	angle := lerp(f32(-45), f32(90), clamp(invlerp( this.state.bird_force, f32(-10), f32(10)), f32(0.0), f32(1.0)))

	pos_y := this.state.bird_position * 260

	rl.draw_texture_pro(
		this.assets.spr_bird, 
		rl.Rectangle {frame_uv_x, frame_uv_y, 32, 16},
		rl.Rectangle { 50, pos_y, 32, 16 },
		rl.Vector2 { 16, 8},
		angle,
		rl.white
		)
}

fn (mut this Game) render_debug()
{
	for rect in this.dbg_rects {
		rl.draw_rectangle(int(rect.x), int(rect.y), int(rect.width), int(rect.height), rl.Color { 255,0,0,64 })
	}

	this.dbg_rects.clear()
}

fn (mut this Game) draw_background()
{
	for y := 0; y < 320; y += 32 {
		for x := 0; x < 240; x += 32 {
			rl.draw_texture(this.assets.spr_background_l4, x, y, rl.white)
		}
	}

	for x := 0; x < 300; x += 128 {
		rl.draw_texture(this.assets.spr_background_l3, x - (int(this.state.x_scroll * 8) % 128), 120, rl.white)
	}

	for x := 0; x < 300; x += 80 {
		rl.draw_texture(this.assets.spr_background_l2, x - (int(this.state.x_scroll * 16) % 80), 180, rl.white)
	}

	for x := 0; x < 300; x += 64 {
		rl.draw_texture(this.assets.spr_background_l1, x - (int(this.state.x_scroll * 32) % 64), 200, rl.white)
	}
}

fn (mut this Game) draw_foreground()
{
	for x := 0; x < 300; x += 32 {
		xoffset := x - (int(this.state.x_scroll * 64) % 32)

		rl.draw_texture(this.assets.spr_ground, xoffset, 260, rl.white)
		rl.draw_texture_pro(this.assets.spr_ground, 
			rl.Rectangle {0,8,-32,24},
			rl.Rectangle {xoffset - 8,292,32,24},
			rl.Vector2{0,0},
			f32(0.0),
			rl.white
		)
		rl.draw_texture_pro(this.assets.spr_ground, 
			rl.Rectangle {0,8,32,24},
			rl.Rectangle {xoffset - 16,310,32,24},
			rl.Vector2{0,0},
			f32(0.0),
			rl.white
		)
	}
}

fn (mut this Game) render_all_pipes()
{
	for mut pipe in this.state.pipes {
		this.render_pipe(mut &pipe)
	}
}

fn (mut this Game) draw_main_menu() {

	title := "Vlappy Bird"
	subtitle := "~Just a demo on V and Raylib~"
	play := "Press [SPACE] to Start"
	hi_score := "High Score: ${this.state.hi_score}"

	title_w := rl.measure_text(title, 30)
	subtitle_w := rl.measure_text(subtitle, 5)
	play_w := rl.measure_text(play, 10)
	hi_score_w := rl.measure_text(hi_score, 5)

	this.draw_background()

	rl.draw_text(title, 120 - title_w/2, 30, 30, rl.orange )
	rl.draw_text(subtitle, 120 - subtitle_w/2, 65, 5, rl.white )

	this.render_all_pipes()
	this.draw_foreground()

	rl.draw_text(play, 120 - play_w/2, 280, 10, rl.black )
	rl.draw_text(hi_score, 120 - hi_score_w/2, 10, 5, rl.white )

	this.draw_menu_setting_item("Scroll Speed", "${this.state.scroll_speed}", 100, 0)
	this.draw_menu_setting_item("Jump Height", "${this.state.jump_power}", 115, 1)
	this.draw_menu_setting_item("Pipe Gap", "${this.state.pipe_gap}", 130, 2)
	this.draw_menu_setting_item("Pipe Interval", "${this.state.pipe_interval}", 145, 3)
	this.draw_menu_setting_item("Gravity", "${this.state.gravity}", 160, 4)

}

fn (mut this Game) draw_menu_setting_item(text string, value string, y i32, index i32)
{
	is_active := this.state.mainmenu_index == index
	color := if is_active { rl.darkblue } else { rl.black }

	if is_active {
		rl.draw_text(">", 15, y, 10, color)
	}

	rl.draw_text(text, 30, y, 10, color)

	value_w := rl.measure_text(value, 10)
	rl.draw_text(value, 200 - value_w, y, 10, color)
}

fn (mut this Game) draw_gameover() {
	this.draw_background()

	if this.scene ==.game_over_opt {

		title  := "Game Over"
		title_w := rl.measure_text(title, 30)
		rl.draw_text(title, 120 - (title_w / 2), 40, 30, rl.orange)
	}

	this.render_all_pipes()

	if this.scene == .game_over_cs {
		alpha_time := clamp(this.state.gameover_scene_time / 0.3, 0.0, 1.0)
		alpha := lerp_f1(255, 0, alpha_time)
		color := rl.Color { 255, 255, 255, u8(alpha) }
		rl.draw_rectangle(0,0,240,320, color)
	}

	this.draw_foreground()
	this.draw_bird()

	if this.scene == .game_over_opt
	{
		score := if this.state.is_last_hiscore {
			"NEW HIGH SCORE : ${this.state.current_score}"
		} else {
			"Score : ${this.state.current_score}"
		}

		score_color := if this.state.is_last_hiscore {
			rl.blue
		} else {
			rl.white
		}

		line_1 := "[SPACE] - Play Again"
		line_2 := "[ESC] - Back to Main Menu"

		score_w := rl.measure_text(score, 5)
		line_1_w := rl.measure_text(line_1, 5)
		line_2_w := rl.measure_text(line_2, 5)

		rl.draw_text(score,  120 - (score_w / 2), 80, 5, score_color)
		rl.draw_text(line_1, 120 - (line_1_w / 2), 105, 5, rl.black)
		rl.draw_text(line_2, 120 - (line_2_w / 2), 117, 5, rl.black)
	}
}
