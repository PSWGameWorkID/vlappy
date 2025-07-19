module main
import raylib as rl

const spr_background_l1 := $embed_file("../assets/spr_background_l1.png")
const spr_background_l2 := $embed_file("../assets/spr_background_l2.png")
const spr_background_l3 := $embed_file("../assets/spr_background_l3.png")
const spr_background_l4 := $embed_file("../assets/spr_background_l4.png")
const spr_bird          := $embed_file("../assets/spr_bird.png")
const spr_ground        := $embed_file("../assets/spr_ground.png")
const spr_pipes         := $embed_file("../assets/spr_pipes.png")
const icon              := $embed_file("../assets/icon.png")

const snd_flap          := $embed_file("../assets/flap.wav", .zlib)
const snd_gameover      := $embed_file("../assets/gameover.wav", .zlib)
const snd_point         := $embed_file("../assets/point.wav", .zlib)

struct Assets {
pub mut:
	spr_background_l1    rl.Texture2D
	spr_background_l2    rl.Texture2D
	spr_background_l3    rl.Texture2D
	spr_background_l4    rl.Texture2D
	spr_bird    		 rl.Texture2D
	spr_ground    		 rl.Texture2D
	spr_pipes    		 rl.Texture2D

	snd_flap             rl.Sound
	snd_gameover         rl.Sound
	snd_point            rl.Sound

	fb_origsize          rl.RenderTexture2D
}

fn (mut this Game) load_all_assets()
{
	unsafe {
		img_icon := rl.load_image_from_memory(".png", icon.to_bytes().data, icon.len)
		rl.set_window_icon(img_icon)	
	}

	this.load_all_sprite()
	this.load_all_sounds()
}

fn (mut this Game) load_all_sprite()
{
	this.assets.spr_background_l1 = this.load_sprite(spr_background_l1.to_bytes())
	this.assets.spr_background_l2 = this.load_sprite(spr_background_l2.to_bytes())
	this.assets.spr_background_l3 = this.load_sprite(spr_background_l3.to_bytes())
	this.assets.spr_background_l4 = this.load_sprite(spr_background_l4.to_bytes())
	this.assets.spr_bird          = this.load_sprite(spr_bird.to_bytes())
	this.assets.spr_ground        = this.load_sprite(spr_ground.to_bytes())
	this.assets.spr_pipes         = this.load_sprite(spr_pipes.to_bytes())
}

fn (mut this Game) load_all_sounds()
{
	this.assets.snd_flap     = this.load_sound(snd_flap.to_bytes())
	this.assets.snd_gameover = this.load_sound(snd_gameover.to_bytes())
	this.assets.snd_point    = this.load_sound(snd_point.to_bytes())
}

fn (mut this Game) load_sprite(data []u8) rl.Texture2D
{
	mem_img := rl.load_image_from_memory(".png", data.data, data.len)
	defer { rl.unload_image(mem_img) }

	tex := rl.load_texture_from_image(mem_img)
	return tex
}

fn (mut this Game) load_sound(data []u8) rl.Sound {
	mem_wav := rl.load_wave_from_memory(".wav", data.data, data.len)
	defer { rl.unload_wave(mem_wav) }

	snd := rl.load_sound_from_wave(mem_wav)
	return snd
}
