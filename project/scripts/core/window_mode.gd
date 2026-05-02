extends RefCounted
class_name WindowMode

const WINDOWED_SIZE := Vector2i(1920, 1080)

static func set_fullscreen(enabled: bool) -> void:
	if enabled:
		_apply_fullscreen()
	else:
		_apply_windowed()

static func toggle_fullscreen() -> void:
	set_fullscreen(not is_fullscreen())

static func is_fullscreen() -> bool:
	var mode := DisplayServer.window_get_mode()
	return mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


static func _apply_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	if not is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

static func _apply_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
