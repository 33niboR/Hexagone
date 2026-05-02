extends Node2D

var card_being_dragged: Node2D = null
var current_hovered: Node2D = null

func connect_card_signals(card):
	card.hovered.connect(on_card_hovered)
	card.hovered_off.connect(on_card_unhovered)
	card.card_selected.connect(on_card_selected)

func on_card_hovered(card: Node2D) -> void:
	# Unhover previous card
	if current_hovered != null and current_hovered != card:
		current_hovered.scale = current_hovered.base_scale
	
	current_hovered = card
	
	# Apply hover scale ONLY if not dragging
	if card != card_being_dragged:
		card.scale = card.base_scale * card.hover_scale_multiplier

func on_card_unhovered(card: Node2D) -> void:
	if card == card_being_dragged:
		return

	if current_hovered == card:
		card.scale = card.base_scale
		current_hovered = null

func on_card_selected(card):
	card_being_dragged = card
	# Drag scale (slightly bigger than hover)
	card.scale = card.base_scale * 1.3
	
	var placement_controller := get_tree().get_first_node_in_group("placement_controller")
	if placement_controller != null and placement_controller.has_method("start_card_placement"):
		placement_controller.start_card_placement(card)

func clear_selected_card(card: Node2D = null) -> void:
	if card == null or card_being_dragged == card:
		card_being_dragged = null
	if card == null or current_hovered == card:
		current_hovered = null
	if card != null and is_instance_valid(card):
		card.scale = card.base_scale
