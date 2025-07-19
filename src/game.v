module main

import raylib as rl
import rand

enum Scene {
	main_menu
	in_game
	paused
	game_over_cs
	game_over_opt
}

struct GameState {
pub mut:
	x_scroll 			f32

	scroll_speed        i32
	jump_power          i32
	pipe_gap            i32
	pipe_interval       i32
	gravity             i32
	
	mainmenu_index      i32

	current_score       i32
	hi_score            i32
	is_last_hiscore     bool
	
	mainmenu_frame      u32

	pipes               [32]rl.Vector3 // X = x position, Y = gap location, Z = ( -1 = inactive, 1 = active )
	pipe_timer          f64

	bird_force          f32
	bird_position       f32
	bird_animation_time f32

	gameover_scene_time f64
}

struct Game {
mut:
	last_time   f64
	state       GameState
	assets      Assets
	scene 	    Scene

	draw_fps  	bool
	debug_on    bool
	dbg_rects 	[]rl.Rectangle
}

fn (mut this Game) new_pipe()
{
	for i in 0 .. this.state.pipes.len {
		if this.state.pipes[i].z <= 0 {
			this.state.pipes[i].z = 1
			this.reload_pipe(mut &this.state.pipes[i], true)
			return
		}
	}
}

fn (mut this Game) reset_pipes()
{
	for i in 0 .. this.state.pipes.len {
		this.state.pipes[i].z = 0
		this.state.pipes[i].x = 3
		this.state.pipes[i].y = f32(0.5)
	}
}

fn (mut this Game) reload_pipe(mut pipe &rl.Vector3, with_x bool)
{
	pipe.y = rand.f32_in_range(f32(0.0), f32(1.0)) or { f32(1.0) }
	pipe.x = 280
}

fn (mut this Game) update_pipe(mut pipe &rl.Vector3, speed f32)
{
	if pipe.z <= 0 { return }
	pipe.x -= speed 
	if pipe.x < -32 {
		pipe.z = -1
	}
}

fn (mut this Game) get_pipe_spawn_delay() f64 {
	return if this.state.pipe_interval < 0 || this.state.pipe_interval > 10 {
		1.5
	} else {
		([ 
			0.25, 0.75, 1.0, 
			1.25, 1.5, 1.75, 
			2.0, 2.5, 3.0, 
			4.0, 5.0
		])[this.state.pipe_interval]
	}
}

fn (this Game) get_pipe_gap() i32
{
	return i32(
		if this.state.pipe_gap < 0 || this.state.scroll_speed > 10 {
		40
		} else {
			([
				15, 20, 30, 
				40, 60, 80,
				100, 120, 150,
				180, 200, 40
			])[this.state.pipe_gap]
		}
	)
}

fn (mut this Game) get_scroll_speed(time f64) f32 {
	return f32(if this.state.scroll_speed < 0 || this.state.scroll_speed > 10 {
		1.0
	}else {
		(([
			0.25, 0.50, 0.75,
			1.00, 1.50, 2.00,
			3.00, 4.00, 5.00,
			7.00, 9.00
		])[this.state.scroll_speed])
	})  * f32(time)
}

fn (mut this Game) get_jump_power() f32 {
	return f32(if this.state.jump_power < 0 || this.state.jump_power > 10 {
		15.0
	}else {
		(([
			10.0, 11.0, 12.5,
			15.0, 16.0, 17.5,
			19.0, 22.0, 25.0,
			30.0, 40.0 
		])[this.state.jump_power])
	})
}

fn (mut this Game) get_gravity() f32 {
	return f32(if this.state.gravity < 0 || this.state.gravity > 10 {
		10.0
	}else {
		(([
			5.0, 6.0, 8.0,
			10.0, 11.0, 12.5,
			13.5, 15.0, 16.0,
			20.0, 30.0
		])[this.state.gravity])
	})
}

fn (mut this Game) is_colliding_with_any_pipe() bool
{
	bird_x := 50
	bird_y := lerp_f1(0, 260, this.state.bird_position)

	bird_w := 16
	bird_h := 8

	bird_l := bird_x - (bird_w / 2)
	bird_t := bird_y - (bird_h / 2)

	bird_rect := rl.Rectangle { bird_l, bird_t, bird_w, bird_h }


	if this.debug_on {
		this.dbg_rects << bird_rect
	}

	for i in 0 .. this.state.pipes.len {
		pipe := this.state.pipes[i]

		// Skip disabled pipes
		if pipe.z <= 0 { continue }

		pipe_w := f32(32)
		pipe_rect_x := f32(pipe.x) - ( pipe_w / 2)

		gap_y_at := lerp_f1(80, 200, pipe.y)
		gap_size_half := this.get_pipe_gap() / 2

		mut gap_top := gap_y_at - gap_size_half
		mut gap_bottom := gap_y_at + gap_size_half

		gap_top = int_max(gap_top, 32)
		gap_bottom = int_min(gap_bottom, 230)

		pipe_top_rect := rl.Rectangle { pipe_rect_x, 0, pipe_w, gap_top }
		pipe_bottom_rect := rl.Rectangle { pipe_rect_x, gap_bottom, pipe_w, 260 - gap_bottom }

		if this.debug_on {
			this.dbg_rects << pipe_top_rect
			this.dbg_rects << pipe_bottom_rect
		}

		if rl.check_collision_recs(bird_rect, pipe_top_rect) || 
		  rl.check_collision_recs(bird_rect, pipe_bottom_rect)
		{
			return true
		}
	}

	return false
}

fn (mut this Game) run() int
{
	rl.init_window(720, 960, "Vlappy Bird")

	this.last_time = rl.get_time()

	this.startup()
	for !rl.window_should_close()  {

		delta_time := rl.get_time() - this.last_time
		this.update(delta_time)

		rl.begin_drawing()
		this.render()

		this.last_time = rl.get_time()
		rl.end_drawing()

	}

	rl.close_window()
	return 0
}
