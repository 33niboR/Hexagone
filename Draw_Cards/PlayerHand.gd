extends Node2D

const CARD_SCENE_PATH := "res://Draw_Cards/Scenes/card.tscn"
const HAND_COUNT := 6

var hand: Array[Node2D] = []
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
	if hand.size() >= HAND_COUNT:
		print("Hand full")
		_show_hand_full_message()
		return

	var data: CardData = deck.draw_card()
	print("Draw result:", data)
	print("Instantiating card...")
	if data == null:
		return
	var card_scene: PackedScene = preload(CARD_SCENE_PATH)
	var new_card: Node2D = card_scene.instantiate()
	
	var card_manager := get_tree().get_first_node_in_group("card_manager")
	if card_manager == null:
		push_error("CardManager not found")
		return
	print("CardManager found:", card_manager)
	
	card_manager.add_child(new_card)

	new_card.global_position = deck.get_deck_position()
	
	new_card.setup(data)
	
	add_card_to_hand(new_card)

func add_card_to_hand(card: Node2D) -> void:
	hand.append(card)
	update_hand_positions()

func remove_card(card: Node2D) -> void:
	hand.erase(card)
	update_hand_positions()

func update_hand_positions() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	
	var spacing: float = 150.0
	var total_width: float = (hand.size() - 1) * spacing
	var center_screen_x: float = viewport_size.x / 2.0
	var y: float = viewport_size.y * 0.85   # 85% down screen
	
	for i in range(hand.size()):
		var x: float = center_screen_x + i * spacing - total_width / 2.0
		hand[i].global_position = Vector2(x, y)
		
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
