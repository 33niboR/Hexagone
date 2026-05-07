extends Node2D

signal hovered(card)
signal hovered_off(card)
signal card_selected(card)

@export var target_width: float = 800.0 #This is where you can adjust the card size by increasing or decreasing the number
@onready var card_image: Sprite2D = $CardImage

var data: CardData
var base_scale: Vector2 = Vector2.ONE
var hover_scale_multiplier: float = 1.2

const TARGET_WIDTH: float = 150.0
	
func _ready() -> void:
	var parent = get_parent()
	if parent != null and parent.has_method("connect_card_signals"):
		parent.connect_card_signals(self)
	z_index = 100

func setup(card_data: CardData) -> void:
	if card_data == null:
		push_error("CardData is null")
		return
	
	data = card_data
	# Set texture once
	card_image.texture = data.texture
	print("Card texture set:", data.texture)
	# Scale card based on texture size
	if data.texture != null:
		var tex_size: Vector2 = data.texture.get_size()
		if tex_size.x > 0:
			var scale_factor: float = target_width / tex_size.x
			base_scale = Vector2(scale_factor, scale_factor)
			scale = base_scale

func _on_area_2d_mouse_entered() -> void:
	scale = base_scale * hover_scale_multiplier
	hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	scale = base_scale
	hovered_off.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_selected.emit(self)
		viewport.set_input_as_handled()
