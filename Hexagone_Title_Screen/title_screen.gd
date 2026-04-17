extends Control

@onready var main_button: VBoxContainer = $Main_Button
@onready var options_button: Panel = $Options_Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_button.visible = true
	options_button.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://project/scenes/main/main.tscn")
	print("Start pressed")
	
func _on_option_pressed() -> void:
	print("Setting pressed")
	main_button.visible = false
	options_button.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_options_pressed() -> void:
	_ready()
