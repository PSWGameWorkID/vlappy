module main
import raylib as rl

fn (mut this Game) update(time f64)
{
	match this.scene
	{
		.main_menu {
			this.update_main_menu(time)
		}
		.in_game {
			this.update_gameplay(time)
		}
		.paused {
			this.update_paused()
		}
		.game_over_cs {
			this.update_gameover_cutscene(time)
		}
		.game_over_opt {
			this.update_gameover(time)
		}
	}

	this.listen_global_input()
}

fn (mut this Game) listen_global_input() {
	if rl.is_key_pressed( int(rl.KeyboardKey.key_f) )
	{
		this.draw_fps = !this.draw_fps
	}

	if rl.is_key_pressed( int(rl.KeyboardKey.key_d) )
	{
		this.debug_on = !this.debug_on
	}
}

fn (mut this Game) update_paused()
{
	if 
		rl.is_key_pressed ( int(rl.KeyboardKey.key_escape) ) ||
		rl.is_key_pressed ( int(rl.KeyboardKey.key_space) ) ||
		rl.is_key_pressed ( int(rl.KeyboardKey.key_enter) ) 
	{
		this.scene = .in_game
	}

	if 
		rl.is_key_pressed ( int(rl.KeyboardKey.key_tab) ) ||
		rl.is_key_pressed ( int(rl.KeyboardKey.key_backspace) ) 
	{
		this.scene = .main_menu
	}
}

fn (mut this Game) tick_pipe_updater(delta f64)
{
	this.state.pipe_timer += delta

	scroll_speed := this.get_scroll_speed(delta) * 64

	for mut pipe in this.state.pipes {
		prev_x := pipe.x
		this.update_pipe(mut &pipe, scroll_speed)

		if prev_x > 50 && pipe.x < 50 && this.scene == .in_game {
			this.state.current_score++
			rl.play_sound(this.assets.snd_point)
		}
	}

	spawn_delay := this.get_pipe_spawn_delay()
	
	if this.state.pipe_timer > spawn_delay {
		this.new_pipe()
		this.state.pipe_timer = 0
	}
}

fn (mut this Game) update_bird(delta f64, limit f32)
{
	this.state.bird_position += this.state.bird_force * f32(delta * 0.1)
	this.state.bird_position = f32_max(this.state.bird_position, 0.0)
	this.state.bird_position = f32_min(this.state.bird_position, limit)
}

fn (mut this Game) update_gameplay(delta f64)
{
	this.update_background_scroll(delta)
	this.tick_pipe_updater(delta)

	if this.state.bird_animation_time < 10 {
		this.state.bird_animation_time += f32(delta)
	}

	gravity := this.get_gravity()

	this.state.bird_force = lerp(this.state.bird_force, f32(gravity), f32(10 * delta))

	this.update_bird(delta, 1.1)

	if rl.is_key_pressed ( int(rl.KeyboardKey.key_space) ) {

		jump_power := this.get_jump_power()

		this.state.bird_force = -jump_power
		rl.play_sound(this.assets.snd_flap)
		this.state.bird_animation_time = 0.0
	}

	if rl.is_key_pressed ( int(rl.KeyboardKey.key_escape) ) {
		this.scene = .paused
	}

	if this.is_colliding_with_any_pipe() {
		this.scene = .game_over_cs
		this.start_gameover_scene()
	}

	if this.state.bird_position > 1 {
		this.scene = .game_over_cs
		this.start_gameover_scene()
	}
}

fn (mut this Game) update_background_scroll(delta f64)
{
	this.state.x_scroll += this.get_scroll_speed(delta)

	if this.state.x_scroll > 240.0
	{
		this.state.x_scroll = 0.0
	}

}

fn (mut this Game) update_main_menu(delta f64)
{
	this.update_background_scroll(delta)
	this.tick_pipe_updater(delta)
	if rl.is_key_pressed ( int(rl.KeyboardKey.key_up) ) {
		this.state.mainmenu_index--
		if this.state.mainmenu_index < 0 { this.state.mainmenu_index = 0 }
	}

	if rl.is_key_pressed( int(rl.KeyboardKey.key_down) ) {
		this.state.mainmenu_index++
		if this.state.mainmenu_index > 4 { this.state.mainmenu_index = 4 }
	}

	if rl.is_key_pressed( int(rl.KeyboardKey.key_escape) ) {
		rl.close_window()
		exit(1)
	}

	ch := match true {
		rl.is_key_pressed(int(rl.KeyboardKey.key_left))  {
			i32(-1)
		}
		rl.is_key_pressed(int(rl.KeyboardKey.key_right))  {
			i32(1)
		}
		else {
			i32(0)
		}
	}

	if rl.is_key_pressed(int(rl.KeyboardKey.key_space)) {
		this.scene =  .in_game
		this.start_gameplay()
	}

	this.state.mainmenu_frame++

	match this.state.mainmenu_index {
		0 {
			this.state.scroll_speed += ch
			this.state.scroll_speed = clamp(this.state.scroll_speed, 0, 10)
			if ch != 0 { this.save_data() }
		}
		1 {
			this.state.jump_power += ch
			this.state.jump_power = clamp(this.state.jump_power, 0, 10)
			if ch != 0 { this.save_data() }
		}
		2 {
			this.state.pipe_gap += ch
			this.state.pipe_gap = clamp(this.state.pipe_gap, 0, 10)
			if ch != 0 { this.save_data() }
		}
		3 {
			this.state.pipe_interval += ch
			this.state.pipe_interval = clamp(this.state.pipe_interval, 0, 10)
			if ch != 0 { this.save_data() }
		}
		4 {
			this.state.gravity += ch
			this.state.gravity = clamp(this.state.gravity, 0, 10)
			if ch != 0 { this.save_data() }
		}
		else {

		}
	}
}

fn (mut this Game) update_gameover_cutscene(delta f64)
{
	this.state.gameover_scene_time += delta

	if this.state.bird_position > 1.5 && this.state.gameover_scene_time > 0.5 {
		this.scene = .game_over_opt
	}

	this.state.bird_force = lerp(this.state.bird_force, f32(15), f32(10 * delta))

	this.update_bird(delta, 2.1)
}

fn (mut this Game) update_gameover(delta f64)
{

	this.update_background_scroll(delta * 0.25)
	this.tick_pipe_updater(delta * 0.25)

	if rl.is_key_pressed( int(rl.KeyboardKey.key_space) ) {
		this.scene = .in_game
		this.start_gameplay()
	}

	if rl.is_key_pressed( int(rl.KeyboardKey.key_escape) ) {
		this.scene = .main_menu
	}

}
