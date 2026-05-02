extends OptionButton

const WindowModeHelper = preload("res://project/scripts/core/window_mode.gd")

func _ready():
	# 1. Add your options via code (or do this in the Inspector)
	clear()
	add_item("Windowed", 0)
	add_item("Fullscreen", 1)
	
	# 2. Set the button's visual state to match your current window mode
	selected = 1 if WindowModeHelper.is_fullscreen() else 0

func _on_item_selected(index: int):
	match index:
		0: # Windowed Mode
			WindowModeHelper.set_fullscreen(false)
			
		1: # Fullscreen Mode
			WindowModeHelper.set_fullscreen(true)

	selected = 1 if WindowModeHelper.is_fullscreen() else 0
