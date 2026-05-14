extends Control

const WindowModeHelper = preload("res://project/scripts/core/window_mode.gd")
const CURSOR_DEFAULT: Texture2D = preload("res://assets/ui/cursor_default.png")
const CURSOR_INTERACT: Texture2D = preload("res://assets/ui/cursor_interact.png")
const CURSOR_DEFAULT_HOTSPOT: Vector2 = Vector2(2.0, 2.0)
const CURSOR_INTERACT_HOTSPOT: Vector2 = Vector2(14.0, 2.0)

@onready var main_button: VBoxContainer = $Main_Button
@onready var options_button: Panel = $Options_Button
@onready var help_panel: Panel = $Control
@onready var resolution_option: OptionButton = $Options_Button/VBoxContainer/Resolution
@onready var title_label: Label = $Label

var cursor_controls_registered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_button.visible = true
	options_button.visible = false
	if help_panel != null:
		help_panel.visible = false
	if title_label != null:
		title_label.visible = true
	_apply_default_cursor()
	_register_interactive_controls()
	MusicManager.play_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()


func _on_start_game_pressed() -> void:
	_apply_default_cursor()
	get_tree().change_scene_to_file("res://project/scenes/main/main.tscn")
	print("Start pressed")
	
func _on_option_pressed() -> void:
	print("Setting pressed")
	main_button.visible = false
	options_button.visible = true
	if title_label != null:
		title_label.visible = false
	_sync_resolution_option()
	
func _on_help_pressed() -> void:
	print("Control pressed")
	main_button.visible = false
	if title_label != null:
		title_label.visible = false
	if help_panel != null:
		help_panel.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	_ready()

func _toggle_fullscreen() -> void:
	WindowModeHelper.toggle_fullscreen()
	_sync_resolution_option()

func _sync_resolution_option() -> void:
	if resolution_option != null and resolution_option.has_method("sync_to_window_mode"):
		resolution_option.call("sync_to_window_mode")

func _apply_default_cursor() -> void:
	Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, CURSOR_DEFAULT_HOTSPOT)

func _set_interact_cursor() -> void:
	Input.set_custom_mouse_cursor(CURSOR_INTERACT, Input.CURSOR_ARROW, CURSOR_INTERACT_HOTSPOT)

func _register_interactive_controls() -> void:
	if cursor_controls_registered:
		return

	var controls: Array[Control] = [
		get_node_or_null("Main_Button/Start Game") as Control,
		get_node_or_null("Main_Button/Option") as Control,
		get_node_or_null("Main_Button/Help") as Control,
		get_node_or_null("Main_Button/Exit") as Control,
		get_node_or_null("Options_Button/Back") as Control,
		get_node_or_null("Control/Back") as Control,
		get_node_or_null("Options_Button/VBoxContainer/Resolution") as Control,
		get_node_or_null("Options_Button/VBoxContainer/Music_Control") as Control,
		get_node_or_null("Options_Button/VBoxContainer/SFX_Control") as Control,
	]

	for control in controls:
		if control == null:
			continue
		control.mouse_entered.connect(_set_interact_cursor)
		control.mouse_exited.connect(_apply_default_cursor)

	cursor_controls_registered = true
