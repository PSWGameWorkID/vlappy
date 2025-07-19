module main
import raylib as rl

fn (mut this Game) startup()
{
	rl.set_exit_key(int(rl.KeyboardKey.key_null)) // Disable raylib's program-wide escape key exit

	rl.init_audio_device()

	this.debug_on = false
	this.draw_fps = false

	this.load_all_assets()

	this.assets.fb_origsize = rl.load_render_texture(240, 320)
	this.scene = .main_menu
	this.state.scroll_speed = 3
	this.state.jump_power = 3
	this.state.pipe_gap = 3
	this.state.pipe_interval = 3
	this.state.gravity = 3
	this.load_data()
	this.new_pipe()
}

fn (mut this Game) start_gameplay()
{
	this.reset_pipes()
	this.state.bird_position = 0.5
	this.state.bird_force = 0.0
	this.state.current_score = 0
	this.state.is_last_hiscore = false
}

fn (mut this Game) start_gameover_scene()
{
	this.state.gameover_scene_time = 0
	this.state.bird_force = -50.0

	rl.play_sound(this.assets.snd_gameover)

	this.state.is_last_hiscore = this.state.current_score > this.state.hi_score

	if this.state.is_last_hiscore {
		this.state.hi_score = this.state.current_score
		this.save_data()
	}

}