extends Node2D

signal deck_clicked

@export var deck_data: Array[CardData] = []

var draw_pile: Array[CardData] = []

func _ready() -> void:
	initialize_deck()

func initialize_deck() -> void:
	draw_pile = deck_data.duplicate()
	draw_pile.shuffle()

func draw_card() -> CardData:
	if draw_pile.is_empty():
		push_warning("Deck is empty")
		return null
	return draw_pile.pop_back()

func get_deck_position() -> Vector2:
	return global_position

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		# Only react to LEFT CLICK press (ignore scroll + right click)
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			print("Deck Clicked")
			deck_clicked.emit()
