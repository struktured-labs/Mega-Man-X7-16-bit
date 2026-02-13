extends "res://src/Levels/music_player.gd"
export var lava_intro : AudioStream
export var lava_song : AudioStream

func play_lava_song() -> void:
	print_debug("Playing Lava Song")
	volume_db = volume + 5
	play_song(lava_song,lava_intro)
