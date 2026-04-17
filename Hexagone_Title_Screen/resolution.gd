extends OptionButton

func _ready():
	# 1. Add your options via code (or do this in the Inspector)
	clear()
	add_item("Windowed", 0)
	add_item("Fullscreen", 1)
	
	# 2. Set the button's visual state to match your current window mode
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		selected = 0
	else:
		selected = 1

func _on_item_selected(index: int):
	# SAFETY CHECK: If we are running inside the Godot 4.4 'Game' tab, 
	# we cannot switch to Fullscreen.
	if Engine.is_embedded_in_editor() and index == 1:
		print("Cannot go Fullscreen while 'Embed Game' is enabled in the Editor.")
		# Reset the button to Windowed so it doesn't look like it's stuck
		selected = 0 
		return

	match index:
		0: # Windowed Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			# Ensure the border (title bar) is visible so you can move the window
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			
		1: # Fullscreen Mode
			# For the best compatibility on Windows 11, use WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
