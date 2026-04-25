extends Node

const MUSIC_STREAM := preload("res://Hexagone_Title_Screen/Music/Music.wav")
const MUSIC_BUS := &"Music"

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "BackgroundMusic"
	_player.bus = MUSIC_BUS
	_player.stream = MUSIC_STREAM
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_player)
	_ensure_music_playing()


func _ensure_music_playing() -> void:
	if _player.playing:
		return
	_player.play()


func play_music() -> void:
	_ensure_music_playing()


func stop_music() -> void:
	if _player.playing:
		_player.stop()
