module main
import json
import os

struct GameConfig {
pub mut:
	scroll_speed        i32
	jump_power          i32
	pipe_gap            i32
	pipe_interval       i32
	gravity             i32

	hi_score            i32
}

fn (mut this Game) load_data()
{
	mut cfg := GameConfig {
		hi_score: this.state.hi_score
		scroll_speed: this.state.scroll_speed
		jump_power: this.state.jump_power
		pipe_gap: this.state.pipe_gap
		gravity: this.state.gravity
	}

	cfg_text := os.read_file("config.json") or { return }
	cfg = json.decode(GameConfig, cfg_text)  or { return }

	this.state.hi_score = cfg.hi_score
	this.state.scroll_speed = cfg.scroll_speed
	this.state.jump_power = cfg.jump_power
	this.state.pipe_gap = cfg.pipe_gap
	this.state.pipe_interval = cfg.pipe_interval
	this.state.gravity = cfg.gravity
}

fn (mut this Game) save_data()
{
	cfg := GameConfig {
		hi_score: this.state.hi_score
		scroll_speed: this.state.scroll_speed
		jump_power: this.state.jump_power
		pipe_gap: this.state.pipe_gap
		pipe_interval: this.state.pipe_interval
		gravity: this.state.gravity
	}

	cfg_text := json.encode(cfg)
	os.write_file("config.json", cfg_text) or { panic(err) }
}
