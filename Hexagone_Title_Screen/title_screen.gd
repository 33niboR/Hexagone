extends Control

const WindowModeHelper = preload("res://project/scripts/core/window_mode.gd")

@onready var main_button: VBoxContainer = $Main_Button
@onready var options_button: Panel = $Options_Button
@onready var help_panel: Control = $Help_Panel
@onready var resolution_option: OptionButton = $Options_Button/VBoxContainer/Resolution



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_button.visible = true
	options_button.visible = false
	help_panel.visible = false
	MusicManager.play_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		_toggle_fullscreen()
		get_viewport().set_input_as_handled()


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://project/scenes/main/main.tscn")
	print("Start pressed")
	
func _on_option_pressed() -> void:
	print("Setting pressed")
	main_button.visible = false
	options_button.visible = true
	_sync_resolution_option()
	
func _on_help_pressed() -> void:
	print("Help pressed")
	main_button.visible = false
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
