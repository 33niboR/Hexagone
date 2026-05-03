extends Node2D

signal deck_clicked

@export var deck_data: Array[CardData] = []
@export var terrain_card_weight: int = 2
@export var low_space_terrain_card_weight: int = 5
@export var low_build_space_threshold: int = 4

var draw_pile: Array[CardData] = []

func _ready() -> void:
	initialize_deck()

func initialize_deck() -> void:
	draw_pile = deck_data.duplicate()
	draw_pile.shuffle()

func draw_card() -> CardData:
	if draw_pile.is_empty():
		initialize_deck()

	if draw_pile.is_empty():
		push_warning("Deck data is empty")
		return null

	var card_index := _pick_weighted_card_index()
	return draw_pile[card_index]

func _pick_weighted_card_index() -> int:
	var total_weight := 0
	var weights: Array[int] = []

	for card_data: CardData in draw_pile:
		var weight := _get_card_weight(card_data)
		weights.append(weight)
		total_weight += weight

	if total_weight <= 0:
		return draw_pile.size() - 1

	var roll := randi_range(1, total_weight)
	var running_weight := 0
	for index: int in range(weights.size()):
		running_weight += weights[index]
		if roll <= running_weight:
			return index

	return draw_pile.size() - 1

func _get_card_weight(card_data: CardData) -> int:
	if not _is_terrain_card(card_data):
		return 1

	if _has_low_build_space() and _is_land_terrain_card(card_data):
		return maxi(low_space_terrain_card_weight, 1)

	return maxi(terrain_card_weight, 1)

func _has_low_build_space() -> bool:
	var placement_controller := get_tree().get_first_node_in_group("placement_controller")
	if placement_controller == null or not placement_controller.has_method("get_available_build_tile_count"):
		return false

	return int(placement_controller.get_available_build_tile_count()) <= low_build_space_threshold

func _is_terrain_card(card_data: CardData) -> bool:
	if card_data == null:
		return false

	var texture_path := ""
	if card_data.texture != null:
		texture_path = str(card_data.texture.resource_path).to_lower()
	var key := (str(card_data.card_id) + " " + str(card_data.display_name) + " " + texture_path).to_lower()

	if key.contains("building") or key.contains("mountain") or key.contains("hill") or key.contains("tree") or key.contains("rock"):
		return false
	if key.contains("waterlily") or key.contains("waterplant") or key.contains("barrel") or key.contains("bucket") or key.contains("tent") or key.contains("flag"):
		return false

	return key.contains("hex_") or key.contains("grass") or key.contains("water") or key.contains("coast") or key.contains("river") or key.contains("road")

func _is_land_terrain_card(card_data: CardData) -> bool:
	if card_data == null:
		return false

	var texture_path := ""
	if card_data.texture != null:
		texture_path = str(card_data.texture.resource_path).to_lower()
	var key := (str(card_data.card_id) + " " + str(card_data.display_name) + " " + texture_path).to_lower()

	if key.contains("water") or key.contains("coast") or key.contains("river"):
		return false

	return key.contains("grass") or key.contains("road")

func get_deck_position() -> Vector2:
	return global_position

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		# Only react to LEFT CLICK press (ignore scroll + right click)
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			print("Deck Clicked")
			deck_clicked.emit()
