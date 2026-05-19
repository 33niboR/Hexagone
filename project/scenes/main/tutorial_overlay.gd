extends CanvasLayer
## Interactive Tutorial Overlay
##
## A step-by-step tutorial that dims the game and walks the player through
## core mechanics: drawing cards, managing the hand, and placing tiles.
## Attach this script to a CanvasLayer node (layer 95) added at runtime.

# ─────────────────────────────────────────────
#  Constants
# ─────────────────────────────────────────────

const MEDIEVAL_FONT: FontFile = preload("res://Hexagone_Title_Screen/Fonts/alagard/alagard.ttf")
const TUTORIAL_IMAGE_PATH := "res://assets/ui/tutorial_drag_card.png"

const GOLD           := Color(0.95, 0.85, 0.55, 1.0)
const GOLD_DIM       := Color(0.85, 0.68, 0.35, 1.0)
const GOLD_BORDER    := Color(0.72, 0.58, 0.36, 1.0)
const PARCHMENT      := Color(0.82, 0.75, 0.62, 0.95)
const DARK_BG        := Color(0.14, 0.08, 0.05, 0.96)
const SHADOW_COLOR   := Color(0.0, 0.0, 0.0, 0.7)

## Rect2 regions are set at runtime based on viewport size.
## Each entry: { "text": String, "highlight": Rect2 or Rect2(), "show_image": bool }
var steps: Array[Dictionary] = []

# ─────────────────────────────────────────────
#  Node references (built in _ready)
# ─────────────────────────────────────────────

var dim_backdrop: ColorRect
var highlight_box: Control
var instruction_panel: PanelContainer
var step_label: Label
var step_image: TextureRect
var next_button: Button
var back_button: Button
var skip_button: Button
var step_counter_label: Label

var current_step: int = 0

# ─────────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────────

func _ready() -> void:
	layer = 95
	name = "TutorialOverlay"

	_build_steps()
	_build_ui()
	_show_step(0)


func _unhandled_input(event: InputEvent) -> void:
	# Block ALL game input while the tutorial is open
	get_viewport().set_input_as_handled()

# ─────────────────────────────────────────────
#  Step definitions
# ─────────────────────────────────────────────

func _build_steps() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size

	# ── Step 1: Deck ──
	# Deck Node2D is at (1800, 920), collision shape 238×339, centered.
	var deck_node := get_tree().get_first_node_in_group("deck") as Node2D
	var deck_rect := Rect2(1800.0 - 130.0, 920.0 - 180.0, 260.0, 360.0)
	if deck_node != null:
		var dp := deck_node.global_position
		deck_rect = Rect2(dp.x - 130.0, dp.y - 180.0, 260.0, 360.0)

	steps.append({
		"text": "Press the deck to draw cards.",
		"highlight": deck_rect,
		"show_image": false,
	})

	# ── Step 2: Hand area ──
	# Cards are laid out centered at 85% of viewport height, spanning ~60% width.
	var hand_left: float = vp_size.x * 0.25
	var hand_top: float = vp_size.y * 0.78
	var hand_width: float = vp_size.x * 0.50
	var hand_height: float = vp_size.y * 0.22

	steps.append({
		"text": "Your hand holds up to 6 cards.\nPlan your city wisely!",
		"highlight": Rect2(hand_left, hand_top, hand_width, hand_height),
		"show_image": false,
	})

	# ── Step 3: HUD panel ──
	# The progression HUD is at offset (18, 18) to (340, 460) — top-left corner.
	var hud_rect := Rect2(10.0, 10.0, 340.0, 460.0)

	steps.append({
		"text": "Check your island progress through\nlevel, power ups, and happiness.",
		"highlight": hud_rect,
		"show_image": false,
	})

	# ── Step 4: Drag to place ──
	steps.append({
		"text": "Drag a card down onto the highlighted\nhex grid to expand your realm!",
		"highlight": Rect2(),   # no highlight
		"show_image": true,
	})


# ─────────────────────────────────────────────
#  UI construction
# ─────────────────────────────────────────────

func _build_ui() -> void:
	# ── Dark backdrop ──
	dim_backdrop = ColorRect.new()
	dim_backdrop.name = "DimBackdrop"
	dim_backdrop.color = Color(0.0, 0.0, 0.0, 0.6)
	dim_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	dim_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim_backdrop)

	# ── Highlight box ──
	highlight_box = Control.new()
	highlight_box.name = "HighlightBox"
	highlight_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight_box.visible = false
	add_child(highlight_box)
	highlight_box.draw.connect(_draw_highlight_box)

	# ── Instruction panel (centered upper area) ──
	instruction_panel = PanelContainer.new()
	instruction_panel.name = "InstructionPanel"
	instruction_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	instruction_panel.anchor_left = 0.5
	instruction_panel.anchor_right = 0.5
	instruction_panel.anchor_top = 0.0
	instruction_panel.anchor_bottom = 0.0
	instruction_panel.offset_left = -280.0
	instruction_panel.offset_top = 60.0
	instruction_panel.offset_right = 280.0
	instruction_panel.offset_bottom = 380.0

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = DARK_BG
	panel_style.border_color = GOLD_BORDER
	panel_style.set_border_width_all(3)
	panel_style.border_blend = true
	panel_style.set_corner_radius_all(8)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.65)
	panel_style.shadow_size = 14
	panel_style.shadow_offset = Vector2(0.0, 5.0)
	panel_style.content_margin_left = 22.0
	panel_style.content_margin_top = 16.0
	panel_style.content_margin_right = 22.0
	panel_style.content_margin_bottom = 16.0
	instruction_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(instruction_panel)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 8)
	instruction_panel.add_child(layout)

	# Top separator
	layout.add_child(_make_separator())

	# Title row with emblems
	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	layout.add_child(title_row)

	title_row.add_child(_make_emblem("\u2727", 24))

	var title := Label.new()
	title.text = "Tutorial"
	title.add_theme_font_override("font", MEDIEVAL_FONT)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", GOLD)
	title.add_theme_color_override("font_shadow_color", SHADOW_COLOR)
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_row.add_child(title)

	title_row.add_child(_make_emblem("\u2727", 24))

	# Separator
	layout.add_child(_make_separator())

	# Step counter (e.g. "Step 1 / 3")
	step_counter_label = Label.new()
	step_counter_label.add_theme_font_override("font", MEDIEVAL_FONT)
	step_counter_label.add_theme_font_size_override("font_size", 16)
	step_counter_label.add_theme_color_override("font_color", GOLD_DIM)
	step_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(step_counter_label)

	# Instruction text
	step_label = Label.new()
	step_label.text = ""
	step_label.add_theme_font_override("font", MEDIEVAL_FONT)
	step_label.add_theme_font_size_override("font_size", 22)
	step_label.add_theme_color_override("font_color", PARCHMENT)
	step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(step_label)

	# Screenshot image (hidden by default)
	step_image = TextureRect.new()
	step_image.name = "StepImage"
	step_image.visible = false
	step_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	step_image.custom_minimum_size = Vector2(480.0, 250.0)
	step_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	# Try to load the screenshot
	if ResourceLoader.exists(TUTORIAL_IMAGE_PATH):
		step_image.texture = load(TUTORIAL_IMAGE_PATH)
	layout.add_child(step_image)

	# Separator
	layout.add_child(_make_separator())

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	layout.add_child(btn_row)

	back_button = _make_button("Back")
	back_button.custom_minimum_size = Vector2(130.0, 44.0)
	back_button.pressed.connect(_on_back_pressed)
	back_button.visible = false  # hidden on step 1
	btn_row.add_child(back_button)

	next_button = _make_button("Next")
	next_button.custom_minimum_size = Vector2(130.0, 44.0)
	next_button.pressed.connect(_on_next_pressed)
	btn_row.add_child(next_button)

	skip_button = _make_button("Skip")
	skip_button.custom_minimum_size = Vector2(130.0, 44.0)
	skip_button.pressed.connect(_close_tutorial)
	btn_row.add_child(skip_button)

	# Bottom separator
	layout.add_child(_make_separator())


# ─────────────────────────────────────────────
#  Step navigation
# ─────────────────────────────────────────────

func _on_next_pressed() -> void:
	current_step += 1
	if current_step >= steps.size():
		_close_tutorial()
		return
	_show_step(current_step)

func _on_back_pressed() -> void:
	if current_step > 0:
		current_step -= 1
		_show_step(current_step)


func _show_step(index: int) -> void:
	if index < 0 or index >= steps.size():
		return

	# Show/hide Back button (hidden on first step)
	if back_button != null:
		back_button.visible = index > 0

	var step: Dictionary = steps[index]

	# Update step counter
	step_counter_label.text = "Step " + str(index + 1) + " / " + str(steps.size())

	# Update instruction text
	step_label.text = str(step.get("text", ""))

	# Show or hide the screenshot image
	var show_img: bool = step.get("show_image", false)
	step_image.visible = show_img

	# Update the panel size to accommodate the image
	if show_img:
		instruction_panel.offset_left = -320.0
		instruction_panel.offset_right = 320.0
		instruction_panel.offset_bottom = 480.0
	else:
		instruction_panel.offset_left = -280.0
		instruction_panel.offset_right = 280.0
		instruction_panel.offset_bottom = 380.0

	# Show or hide the highlight box
	var rect: Rect2 = step.get("highlight", Rect2())
	if rect.size.x > 0.0 and rect.size.y > 0.0:
		highlight_box.visible = true
		highlight_box.position = rect.position
		highlight_box.size = rect.size
		highlight_box.queue_redraw()
	else:
		highlight_box.visible = false

	# Update button text on last step
	if index == steps.size() - 1:
		next_button.text = "Got it!"
	else:
		next_button.text = "Next"


func _close_tutorial() -> void:
	# Fade out, then free
	var tween := create_tween()
	tween.tween_property(dim_backdrop, "color:a", 0.0, 0.25)
	tween.parallel().tween_property(instruction_panel, "modulate:a", 0.0, 0.25)
	tween.parallel().tween_property(highlight_box, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)


# ─────────────────────────────────────────────
#  Highlight box drawing
# ─────────────────────────────────────────────

func _draw_highlight_box() -> void:
	var size: Vector2 = highlight_box.size
	var border_width := 3.0
	var glow_width := 6.0

	# Light inner fill so the highlighted element stands out
	var fill_color := Color(1.0, 1.0, 1.0, 0.12)
	highlight_box.draw_rect(Rect2(Vector2.ZERO, size), fill_color, true)

	# Outer glow
	var glow_color := Color(GOLD_BORDER.r, GOLD_BORDER.g, GOLD_BORDER.b, 0.35)
	highlight_box.draw_rect(Rect2(-glow_width, -glow_width, size.x + glow_width * 2, size.y + glow_width * 2), glow_color, false, glow_width)

	# Main border
	highlight_box.draw_rect(Rect2(Vector2.ZERO, size), GOLD_BORDER, false, border_width)

	# Corner accents (small gold squares at each corner)
	var corner_size := 10.0
	highlight_box.draw_rect(Rect2(-corner_size * 0.5, -corner_size * 0.5, corner_size, corner_size), GOLD, true)
	highlight_box.draw_rect(Rect2(size.x - corner_size * 0.5, -corner_size * 0.5, corner_size, corner_size), GOLD, true)
	highlight_box.draw_rect(Rect2(-corner_size * 0.5, size.y - corner_size * 0.5, corner_size, corner_size), GOLD, true)
	highlight_box.draw_rect(Rect2(size.x - corner_size * 0.5, size.y - corner_size * 0.5, corner_size, corner_size), GOLD, true)


# ─────────────────────────────────────────────
#  UI helpers
# ─────────────────────────────────────────────

func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(GOLD_BORDER.r, GOLD_BORDER.g, GOLD_BORDER.b, 0.5)
	style.set_content_margin_all(0.0)
	style.content_margin_top = 1.0
	style.content_margin_bottom = 1.0
	sep.add_theme_stylebox_override("separator", style)
	return sep


func _make_emblem(symbol: String, size: int) -> Label:
	var lbl := Label.new()
	lbl.text = symbol
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", GOLD_DIM)
	return lbl


func _make_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.custom_minimum_size = Vector2(0.0, 44.0)

	button.add_theme_font_override("font", MEDIEVAL_FONT)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", GOLD)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.75, 1.0))
	button.add_theme_color_override("font_pressed_color", GOLD_BORDER)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.22, 0.15, 0.1, 0.85)
	normal_style.border_color = Color(0.55, 0.44, 0.28, 0.7)
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", normal_style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.2, 0.13, 0.92)
	hover_style.border_color = GOLD_BORDER
	hover_style.set_border_width_all(2)
	hover_style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.12, 0.08, 0.05, 0.95)
	pressed_style.border_color = Color(GOLD_BORDER.r, GOLD_BORDER.g, GOLD_BORDER.b, 0.9)
	pressed_style.set_border_width_all(2)
	pressed_style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("pressed", pressed_style)

	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button
