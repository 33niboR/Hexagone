extends Node2D

const CARD_SCENE_PATH := "res://Draw_Cards/Scenes/card.tscn"
const HAND_COUNT := 6
const MEDIEVAL_FONT: FontFile = preload("res://Hexagone_Title_Screen/Fonts/alagard/alagard.ttf")

var hand: Array[Node2D] = []
var hand_limit: int = HAND_COUNT
var center_screen_x: float
var _hand_full_canvas: CanvasLayer = null
var _hand_full_panel: PanelContainer = null
var _hand_full_tween: Tween = null

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	_create_hand_full_notification()

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


# ---------- Medieval Hand-Full Notification ----------

func _create_hand_full_notification() -> void:
	_hand_full_canvas = CanvasLayer.new()
	_hand_full_canvas.name = "HandFullNotificationLayer"
	_hand_full_canvas.layer = 90
	add_child(_hand_full_canvas)

	# -- Outer panel --
	_hand_full_panel = PanelContainer.new()
	_hand_full_panel.name = "HandFullPanel"
	_hand_full_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hand_full_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)  # start invisible

	# Center horizontally, near top of viewport
	_hand_full_panel.anchor_left = 0.5
	_hand_full_panel.anchor_right = 0.5
	_hand_full_panel.anchor_top = 0.0
	_hand_full_panel.anchor_bottom = 0.0
	_hand_full_panel.offset_left = -220.0
	_hand_full_panel.offset_right = 220.0
	_hand_full_panel.offset_top = 40.0
	_hand_full_panel.offset_bottom = 130.0

	# Parchment-style panel background
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.18, 0.12, 0.08, 0.92)         # dark leather brown
	panel_style.border_color = Color(0.72, 0.58, 0.36, 1.0)      # warm gold trim
	panel_style.set_border_width_all(3)
	panel_style.border_blend = true
	panel_style.set_corner_radius_all(6)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	panel_style.shadow_size = 8
	panel_style.shadow_offset = Vector2(0.0, 4.0)
	panel_style.set_content_margin_all(16.0)
	_hand_full_panel.add_theme_stylebox_override("panel", panel_style)

	_hand_full_canvas.add_child(_hand_full_panel)

	# -- Inner layout --
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hand_full_panel.add_child(vbox)

	# Decorative top separator (gold line)
	var top_sep := HSeparator.new()
	top_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = Color(0.72, 0.58, 0.36, 0.6)
	sep_style.set_content_margin_all(0.0)
	sep_style.content_margin_top = 1.0
	sep_style.content_margin_bottom = 1.0
	top_sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(top_sep)

	# Shield emblem + title row
	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(title_row)

	# Shield unicode emblem
	var shield_label := Label.new()
	shield_label.text = "\u26e8"  # shield emoji
	shield_label.add_theme_font_size_override("font_size", 26)
	shield_label.add_theme_color_override("font_color", Color(0.85, 0.68, 0.35, 1.0))
	shield_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(shield_label)

	# Warning title
	var title_label := Label.new()
	title_label.text = "Hand is Full!"
	title_label.add_theme_font_override("font", MEDIEVAL_FONT)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(title_label)

	# Second shield on the right
	var shield_right := Label.new()
	shield_right.text = "\u26e8"
	shield_right.add_theme_font_size_override("font_size", 26)
	shield_right.add_theme_color_override("font_color", Color(0.85, 0.68, 0.35, 1.0))
	shield_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(shield_right)

	# Subtitle / explanation
	var subtitle := Label.new()
	subtitle.text = "You must place a card before drawing another."
	subtitle.add_theme_font_override("font", MEDIEVAL_FONT)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.78, 0.72, 0.6, 0.9))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(subtitle)

	# Bottom decorative separator
	var bottom_sep := HSeparator.new()
	bottom_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_sep.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(bottom_sep)


func _show_hand_full_message() -> void:
	if _hand_full_panel == null:
		return

	# Kill any existing fade tween so multiple clicks don't conflict
	if _hand_full_tween != null and _hand_full_tween.is_valid():
		_hand_full_tween.kill()

	_hand_full_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)

	_hand_full_tween = create_tween()
	_hand_full_tween.set_ease(Tween.EASE_OUT)
	_hand_full_tween.set_trans(Tween.TRANS_CUBIC)

	# Fade in over 0.35s
	_hand_full_tween.tween_property(_hand_full_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)
	# Hold for 2 seconds
	_hand_full_tween.tween_interval(2.0)
	# Fade out over 0.5s
	_hand_full_tween.set_ease(Tween.EASE_IN)
	_hand_full_tween.set_trans(Tween.TRANS_CUBIC)
	_hand_full_tween.tween_property(_hand_full_panel, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
