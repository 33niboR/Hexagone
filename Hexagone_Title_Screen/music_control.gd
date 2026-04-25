extends HSlider

@export var audio_bus_name: String

var audio_bus_id: int = -1

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		push_warning("Audio bus '%s' was not found." % audio_bus_name)
		return
	var value_changed_callable: Callable = Callable(self, "_on_value_changed")
	if not value_changed.is_connected(value_changed_callable):
		value_changed.connect(value_changed_callable)
	set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id)))

func _on_value_changed(value: float) -> void:
	if audio_bus_id == -1:
		return
	if is_zero_approx(value):
		AudioServer.set_bus_mute(audio_bus_id, true)
		AudioServer.set_bus_volume_db(audio_bus_id, -80.0)
		return
	AudioServer.set_bus_mute(audio_bus_id, false)
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
