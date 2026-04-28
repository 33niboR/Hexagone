extends Node
class_name GameManager

var current_level: int = 1
var placed_tile_count: int = 0

func register_tile_placed() -> void:
	placed_tile_count += 1
	_check_milestone()

func _check_milestone() -> void:
	if placed_tile_count == 10:
		current_level = 2
		print("Milestone reached: Level 2 unlocked")

func start_placement(card_data):
	print("Starting placement for: ", card_data)
	# This is where the system will hook in
