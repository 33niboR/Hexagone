extends Node2D

const CARD_SCENE_PATH := "res://Draw_Cards/Scenes/card.tscn"
const HAND_COUNT := 6

var hand: Array[Node2D] = []
var hand_limit: int = HAND_COUNT
var center_screen_x: float
var hand_full_label: Label = null

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	_create_hand_full_label()
	
	var deck = get_tree().get_first_node_in_group("deck")
	
	print("Deck found", deck)
	
	if deck != null:
		deck.deck_clicked.connect(_on_deck_clicked)
		

func _on_deck_clicked() -> void:
	var deck = get_tree().get_first_node_in_group("deck")
	if deck == null:
		return
	request_draw_from_deck(deck)
	print("PlayerHand received deck click")



func request_draw_from_deck(deck: Node) -> void:
	if hand.size() >= hand_limit:
		print("Hand full")
		_show_hand_full_message()
		return

	var data: CardData = deck.draw_card()
	print("Draw result:", data)
	if data == null:
		return
	add_card_data(data, deck.get_deck_position())

func add_card_data(data: CardData, start_position: Vector2 = Vector2.ZERO) -> bool:
	if data == null:
		return false
	if hand.size() >= hand_limit:
		print("Hand full")
		_show_hand_full_message()
		return false

	print("Instantiating card...")
	var card_scene: PackedScene = preload(CARD_SCENE_PATH)
	var new_card: Node2D = card_scene.instantiate()
	
	var card_manager := get_tree().get_first_node_in_group("card_manager")
	if card_manager == null:
		push_error("CardManager not found")
		return false
	print("CardManager found:", card_manager)
	
	card_manager.add_child(new_card)

	new_card.global_position = start_position
	
	new_card.setup(data)
	
	add_card_to_hand(new_card)
	return true

func draw_cards_from_deck(deck: Node, count: int) -> int:
	if deck == null:
		return 0
	var drawn := 0
	for i: int in range(count):
		if hand.size() >= hand_limit:
			break
		var data: CardData = deck.draw_card()
		if data == null:
			break
		if add_card_data(data, deck.get_deck_position()):
			drawn += 1
	return drawn

func discard_hand(redraw: bool = false, deck: Node = null) -> int:
	var discarded_count := hand.size()
	for card: Node2D in hand:
		if card != null and is_instance_valid(card):
			card.queue_free()
	hand.clear()
	update_hand_positions()

	if redraw and deck != null:
		draw_cards_from_deck(deck, min(discarded_count, hand_limit))

	return discarded_count

func increase_hand_limit(amount: int = 1) -> void:
	hand_limit = max(hand_limit + amount, HAND_COUNT)
	update_hand_positions()

func get_hand_limit() -> int:
	return hand_limit

func get_available_slots() -> int:
	return max(hand_limit - hand.size(), 0)

func add_card_to_hand(card: Node2D) -> void:
	hand.append(card)
	update_hand_positions()

func remove_card(card: Node2D) -> void:
	hand.erase(card)
	update_hand_positions()

func update_hand_positions() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	
	var spacing: float = 120.0
	var total_width: float = (hand.size() - 1) * spacing
	var center_screen_x: float = viewport_size.x / 2.0
	var y: float = viewport_size.y * 0.85 + _get_hand_card_height() * 0.04   # 85% down screen, then a small card-relative nudge
	
	for i in range(hand.size()):
		var x: float = center_screen_x + i * spacing - total_width / 2.0
		hand[i].global_position = Vector2(x, y)

func _get_hand_card_height() -> float:
	for card: Node2D in hand:
		if card == null or not is_instance_valid(card):
			continue
		var card_image := card.get_node_or_null("CardImage") as Sprite2D
		if card_image == null or card_image.texture == null:
			continue
		return card_image.texture.get_size().y * card.scale.y
	return 0.0

func _create_hand_full_label() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)

	hand_full_label = Label.new()
	hand_full_label.text = "Your hand is full!"
	hand_full_label.visible = false
	hand_full_label.position = Vector2(500, 300)
	hand_full_label.add_theme_font_size_override("font_size", 36)
	canvas.add_child(hand_full_label)

func _show_hand_full_message() -> void:
	if hand_full_label == null:
		return

	hand_full_label.visible = true
	await get_tree().create_timer(2.5).timeout

	if hand_full_label != null:
		hand_full_label.visible = false
