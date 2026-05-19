extends Node

const MUSIC_STREAM := preload("res://Hexagone_Title_Screen/Music/Music.wav")
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"
const SAMPLE_RATE: int = 44100

const HOVER_VOLUME_DB: float = -15.0
const CLICK_VOLUME_DB: float = -4.0
const PLACE_VOLUME_DB: float = -2.0

var _player: AudioStreamPlayer
var _hover_sfx: AudioStreamWAV
var _click_sfx: AudioStreamWAV
var _place_sfx: AudioStreamWAV


func _ready() -> void:
	_hover_sfx = _create_hover_sound()
	_click_sfx = _create_button_click_sound()
	_place_sfx = _create_place_sound()

	_player = AudioStreamPlayer.new()
	_player.name = "BackgroundMusic"
	_player.bus = MUSIC_BUS
	_player.stream = MUSIC_STREAM
	_player.volume_db = 0.0
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_music_loop()
	_player.finished.connect(_ensure_music_playing)
	add_child(_player)
	_set_bus_full_volume(MUSIC_BUS)
	_ensure_music_playing()
	get_tree().node_added.connect(_register_ui_node)
	call_deferred("_register_existing_ui", get_tree().root)


func _ensure_music_playing() -> void:
	if _player.playing:
		return
	_player.play()


func play_music() -> void:
	_ensure_music_playing()


func _configure_music_loop() -> void:
	var wav_stream := MUSIC_STREAM as AudioStreamWAV
	if wav_stream == null:
		return
	wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav_stream.loop_begin = 0
	wav_stream.loop_end = wav_stream.data.size() / (4 if wav_stream.stereo else 2)


func stop_music() -> void:
	if _player.playing:
		_player.stop()


func play_place_sfx() -> void:
	_play_sfx(_place_sfx, PLACE_VOLUME_DB)


func play_button_click_sfx() -> void:
	_play_sfx(_click_sfx, CLICK_VOLUME_DB)


func play_button_hover_sfx() -> void:
	_play_sfx(_hover_sfx, HOVER_VOLUME_DB)


func _register_existing_ui(node: Node) -> void:
	_register_ui_node(node)
	for child: Node in node.get_children():
		_register_existing_ui(child)


func _register_ui_node(node: Node) -> void:
	var button: BaseButton = node as BaseButton
	if button == null:
		return
	var hover_callable: Callable = Callable(self, "play_button_hover_sfx")
	var click_callable: Callable = Callable(self, "play_button_click_sfx")
	if not button.mouse_entered.is_connected(hover_callable):
		button.mouse_entered.connect(hover_callable)
	if not button.pressed.is_connected(click_callable):
		button.pressed.connect(click_callable)


func _play_sfx(stream: AudioStreamWAV, volume_db: float) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.bus = SFX_BUS
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	sfx_player.play()


func _create_hover_sound() -> AudioStreamWAV:
	return _create_tone(1200.0, 0.045, 0.55, 980.0)


func _create_button_click_sound() -> AudioStreamWAV:
	var duration: float = 0.105
	var sample_count: int = int(float(SAMPLE_RATE) * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for i: int in range(sample_count):
		var time: float = float(i) / float(SAMPLE_RATE)
		var sample: float = 0.0
		if time < 0.035:
			var phase_a: float = time / 0.035
			sample += sin(TAU * 980.0 * time) * (1.0 - phase_a) * 0.85
		elif time < 0.075:
			var phase_b: float = (time - 0.035) / 0.04
			sample += sin(TAU * 540.0 * time) * (1.0 - phase_b) * 0.65
		_write_sample(bytes, i, sample)

	return _create_stream_from_bytes(bytes)


func _create_place_sound() -> AudioStreamWAV:
	var duration: float = 0.32
	var sample_count: int = int(float(SAMPLE_RATE) * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for i: int in range(sample_count):
		var time: float = float(i) / float(SAMPLE_RATE)
		var progress: float = time / duration
		var thud_envelope: float = pow(1.0 - progress, 2.2)
		var thud: float = sin(TAU * lerpf(145.0, 70.0, progress) * time) * thud_envelope * 0.9
		var scrape_noise: float = (_pseudo_noise(i) * 2.0 - 1.0) * pow(1.0 - progress, 3.0) * 0.18
		var hammer_a: float = _short_hit(time, 0.055, 760.0, 0.035, 0.55)
		var hammer_b: float = _short_hit(time, 0.145, 520.0, 0.055, 0.42)
		_write_sample(bytes, i, thud + scrape_noise + hammer_a + hammer_b)

	return _create_stream_from_bytes(bytes)


func _create_tone(frequency: float, duration: float, amplitude: float, end_frequency: float = -1.0) -> AudioStreamWAV:
	var sample_count: int = int(float(SAMPLE_RATE) * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(sample_count * 2)

	for i: int in range(sample_count):
		var progress: float = float(i) / float(maxi(sample_count - 1, 1))
		var envelope: float = sin(progress * PI)
		var current_frequency: float = frequency
		if end_frequency > 0.0:
			current_frequency = lerpf(frequency, end_frequency, progress)
		var sample: float = sin(TAU * current_frequency * float(i) / float(SAMPLE_RATE)) * amplitude * envelope
		_write_sample(bytes, i, sample)

	return _create_stream_from_bytes(bytes)


func _short_hit(time: float, start_time: float, frequency: float, duration: float, amplitude: float) -> float:
	if time < start_time or time > start_time + duration:
		return 0.0
	var progress: float = (time - start_time) / duration
	return sin(TAU * frequency * time) * pow(1.0 - progress, 2.0) * amplitude


func _pseudo_noise(index: int) -> float:
	return fposmod(sin(float(index) * 12.9898) * 43758.5453, 1.0)


func _write_sample(bytes: PackedByteArray, index: int, sample: float) -> void:
	var value: int = clampi(int(sample * 32767.0), -32768, 32767)
	if value < 0:
		value += 65536
	bytes[index * 2] = value & 0xff
	bytes[index * 2 + 1] = (value >> 8) & 0xff


func _create_stream_from_bytes(bytes: PackedByteArray) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream


func _set_bus_full_volume(bus_name: StringName) -> void:
	var bus_id := AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		return
	AudioServer.set_bus_mute(bus_id, false)
	AudioServer.set_bus_volume_db(bus_id, 0.0)
