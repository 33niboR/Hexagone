extends Control

const HexGrid = preload("res://project/scripts/grid/hex_grid.gd")
const WindowModeHelper = preload("res://project/scripts/core/window_mode.gd")
const CURSOR_DEFAULT: Texture2D = preload("res://assets/ui/cursor_default.png")
const CURSOR_INTERACT: Texture2D = preload("res://assets/ui/cursor_interact.png")
const CURSOR_DEFAULT_HOTSPOT: Vector2 = Vector2(2.0, 2.0)
const CURSOR_INTERACT_HOTSPOT: Vector2 = Vector2(14.0, 2.0)
const MENU_BUTTON_FONT: FontFile = preload("res://Hexagone_Title_Screen/Fonts/alagard/alagard.ttf")
const MENU_TITLE_FONT: FontFile = preload("res://Hexagone_Title_Screen/Fonts/thaleahfat/ThaleahFat.ttf")
const CARD_WIDTH: float = 170.0
const CARD_HEIGHT: float = 150.0
const CARD_LEFT: float = 14.0
const CARD_TOP: float = 10.0
const CARD_HORIZONTAL_GAP: float = 12.0
const CARD_VERTICAL_GAP: float = 12.0
const CARD_COLUMNS: int = 2
const ICON_SIZE: Vector2i = Vector2i(154, 108)
const PLACEMENT_TERRAIN: String = "terrain"
const PLACEMENT_OBJECT: String = "object"
const TERRAIN_LAND: String = "land"
const TERRAIN_WATER: String = "water"
const TERRAIN_ANY: String = "any"
const KIND_GRASS: String = "grass"
const KIND_ROAD: String = "road"
const KIND_WATER: String = "water"
const KIND_BUILDING: String = "building"
const KIND_NATURE: String = "nature"
const KIND_DECORATION: String = "decoration"
const KIND_WATER_DECORATION: String = "water_decoration"
const ASSET_ROOT: String = "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/"
const MENU_WIDTH: float = 633.0
const MENU_BUTTON_NORMAL := Color(0.27058825, 0.3529412, 0.39215687, 1.0)
const MENU_BUTTON_PRESSED := Color(0.14901961, 0.19607843, 0.21960784, 1.0)
const MENU_BUTTON_HOVER := Color(0.47058824, 0.5647059, 0.6117647, 1.0)
const MENU_FONT_COLOR := Color(0.9254902, 0.9372549, 0.94509804, 1.0)
const XP_PER_PLACEMENT: int = 1
const HAPPINESS_START: int = 0
const HAPPINESS_MAX: int = 100
const HAPPINESS_BUILDING_PERCENT: int = 5
const HAPPINESS_BUILDING_ROAD_BONUS_PERCENT: int = 5
const HAPPINESS_ROAD_CONNECTION_PERCENT: int = 3
const HAPPINESS_CHECK_CARDS: int = 4
const HAPPINESS_CHECK_TARGET: int = 10
const HAPPINESS_RECOVERY_CARDS: int = 3
const PLACEMENT_INDICATOR_RADIUS: float = 2.34
const PLACEMENT_INDICATOR_HEIGHT: float = 0.04
const PLACEMENT_INDICATOR_Y: float = 0.11
const MAP_SAVE_VERSION: int = 1
const DEFAULT_MAP_FILE: String = "user://hexagone_map.json"
const TERRAIN_TILE_SCALE: float = 2.0
const BASE_XP_TO_LEVEL: int = 4
const XP_GROWTH_PER_LEVEL: int = 2
const POWERUP_REWARD_MIN: int = 2
const POWERUP_REWARD_MAX: int = 3
const MAX_BIGGER_HAND_USES: int = 3
const POWERUP_POOL: Array[Dictionary] = [
	{
		"id": "redraw_hand",
		"label": "Redraw Hand",
		"description": "Discard your hand and draw replacements."
	},
	{
		"id": "search_deck",
		"label": "Search Deck",
		"description": "Pick a specific card from the deck."
	},
	{
		"id": "expand_hand",
		"label": "Bigger Hand",
		"description": "Permanently increase your hand limit by one."
	}
]
const AXIAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1)
]

const ADDITIONAL_PLACEABLES: Array[Dictionary] = [
	{
		"id": "house",
		"label": "House",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_home_A_blue.obj",
		"placement_layer": PLACEMENT_OBJECT,
		"placeable_kind": KIND_BUILDING
	},
	{
		"id": "castle",
		"label": "Castle",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_castle_blue.obj",
		"placement_layer": PLACEMENT_OBJECT,
		"placeable_kind": KIND_BUILDING
	},
	{
		"id": "market",
		"label": "Market",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_market_blue.obj",
		"placement_layer": PLACEMENT_OBJECT,
		"placeable_kind": KIND_BUILDING
	},
	{
		"id": "forest",
		"label": "Forest",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/decoration/nature/trees_A_large.obj",
		"placement_layer": PLACEMENT_OBJECT,
		"placeable_kind": KIND_NATURE
	},
	{
		"id": "mountain",
		"label": "Mountain",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/decoration/nature/mountain_A_grass_trees.obj",
		"placement_layer": PLACEMENT_OBJECT,
		"placeable_kind": KIND_NATURE
	},
	{
		"id": "road",
		"label": "Road",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/tiles/roads/hex_road_A.obj",
		"placement_layer": PLACEMENT_TERRAIN,
		"terrain_type": TERRAIN_LAND,
		"placeable_kind": KIND_ROAD
	},
	{
		"id": "coast",
		"label": "Coast",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/tiles/coast/hex_coast_A.obj",
		"placement_layer": PLACEMENT_TERRAIN,
		"terrain_type": TERRAIN_WATER,
		"placeable_kind": KIND_WATER
	}
]

@onready var preview_building: Node3D = get_node("/root/Main/BuildPreview/building")
@onready var preview_river: Node3D = get_node("/root/Main/BuildPreview/river")
@onready var preview_grass: Node3D = get_node("/root/Main/BuildPreview/grass")
@onready var building_button: Button = get_node_or_null("/root/Main/card system/Control/building")
@onready var river_button: Button = get_node_or_null("/root/Main/card system/Control/river")
@onready var grass_button: Button = get_node_or_null("/root/Main/card system/Control/grass")
@onready var build_preview_node: Node3D = get_node("/root/Main/BuildPreview")
@onready var world_node: Node3D = get_node("/root/Main/World")
@onready var hex_grid: HexGrid = HexGrid.new()


var is_placing: bool = false
var current_active_model: Node3D = null 
var current_source_card: Node2D = null
var current_rotation_steps: int = 0
var placeable_previews: Array[Node3D] = []
var card_placeable_previews: Dictionary = {}
var terrain_cells: Dictionary = {}
var object_cells: Dictionary = {}
var terrain_types: Dictionary = {}
var terrain_kinds: Dictionary = {}
var object_kinds: Dictionary = {}
var happiness_cell_scores: Dictionary = {}
var placement_indicators: Array[MeshInstance3D] = []
var placement_indicator_mesh: CylinderMesh = null
var placement_valid_material: StandardMaterial3D = null
var placement_invalid_material: StandardMaterial3D = null
var menu_layer: CanvasLayer = null
var menu_blocker: ColorRect = null
var menu_panel: PanelContainer = null
var settings_panel: VBoxContainer = null
var controls_panel: VBoxContainer = null
var menu_buttons_panel: VBoxContainer = null
var restart_confirm_dialog: ConfirmationDialog = null
var export_map_dialog: FileDialog = null
var load_map_dialog: FileDialog = null
var happiness_warning_dialog: AcceptDialog = null
var game_over_dialog: AcceptDialog = null
var win_dialog: ConfirmationDialog = null
var resolution_option: OptionButton = null
var default_land_tile_material: Material = null
var selected_object: Node3D = null
var selected_object_cell: Vector2i = Vector2i.ZERO
var selected_hint_label: Label = null
var player_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = BASE_XP_TO_LEVEL
var powerup_inventory: Array[Dictionary] = []
var progression_panel: PanelContainer = null
var level_label: Label = null
var xp_label: Label = null
var xp_bar: ProgressBar = null
var happiness_label: Label = null
var happiness_bar: ProgressBar = null
var objective_label: Label = null
var powerup_list: VBoxContainer = null
var search_panel: PanelContainer = null
var search_list: GridContainer = null
var pending_search_powerup_index: int = -1
var bigger_hand_uses: int = 0
var happiness: int = HAPPINESS_START
var objective_cards_played: int = 0
var objective_start_happiness: int = HAPPINESS_START
var recovery_active: bool = false
var recovery_target_happiness: int = 0
var game_over: bool = false
var has_won: bool = false
var endless_mode: bool = false
var cursor_interact_requests: int = 0
var cursor_over_world_interaction: bool = false

func _ready():
	add_to_group("placement_controller")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_default_cursor()
	if building_button:
		building_button.hide()
	if river_button:
		river_button.hide()
	if grass_button:
		grass_button.hide()

	_seed_existing_terrain_cells()
	default_land_tile_material = _find_default_land_tile_material()
	placeable_previews.clear()
	_register_placeable_preview(preview_building, PLACEMENT_OBJECT, TERRAIN_LAND, KIND_BUILDING)
	_register_placeable_preview(preview_river, PLACEMENT_TERRAIN, TERRAIN_WATER, KIND_WATER)
	_register_placeable_preview(preview_grass, PLACEMENT_TERRAIN, TERRAIN_LAND, KIND_GRASS)
	_create_additional_placeables()
	_hide_all_previews()
	_create_ingame_menu()
	_create_map_file_dialogs()
	_create_progression_hud()
	_create_selected_hint_label()
	_sync_progression_hud()


func _on_building_pressed():
	_start_placement(preview_building)

func _on_river_pressed():
	_start_placement(preview_river)

func _on_grass_pressed():
	_start_placement(preview_grass)


func _start_placement(target_model: Node3D):
	_hide_all_previews() 
		
	is_placing = true
	current_active_model = target_model
	current_rotation_steps = 0
	current_active_model.rotation_degrees.y = 0.0
	current_active_model.show()
	
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()
	_refresh_placement_indicators()

func start_card_placement(card: Node2D) -> void:
	if card == null:
		return
	var card_data := card.get("data") as CardData
	if card_data == null:
		return
	if is_placing:
		_cancel_placement()

	var preview := _get_or_create_card_preview(card_data)
	if preview == null:
		push_warning("No placeable mesh found for card: " + str(card_data.display_name))
		return

	current_source_card = card
	current_source_card.hide()
	_start_placement(preview)

func finish_drag_placement(card: Node2D) -> void:
	# Called when the player releases the mouse button after dragging a card.
	# If a placement is active and the hovered cell is valid, commit it;
	# otherwise cancel so the card returns to the hand.
	if not is_placing or current_active_model == null:
		return
	# Only act if this drag matches the card currently being placed.
	if card != null and current_source_card != card:
		return
	var pos: Vector3 = _get_snapped_mouse_position()
	var cell: Vector2i = hex_grid.world_to_axial(pos)
	var placement_layer: String = _get_placement_layer(current_active_model)
	if _can_place_at(cell, placement_layer):
		_place_item(pos)
	else:
		print("drag placement invalid at ", cell, " — cancelling")
		_cancel_placement()

func _process(_delta):
	if is_placing and current_active_model:
		var target_pos: Vector3 = _get_snapped_mouse_position()
		current_active_model.global_position = target_pos
		_set_world_interaction_cursor(false)
	elif menu_panel == null or not menu_panel.visible:
		_update_world_interaction_cursor()
	else:
		_set_world_interaction_cursor(false)

func _unhandled_input(event):
	if menu_panel != null and menu_panel.visible:
		return

	if is_placing and current_active_model:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
			_rotate_current_placement()
			get_viewport().set_input_as_handled()
			return

		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_place_item(current_active_model.global_position)
				get_viewport().set_input_as_handled()
				return
			if event.button_index == MOUSE_BUTTON_RIGHT:
				_cancel_placement()
				get_viewport().set_input_as_handled()
				return

		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			_delete_selected_object()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_viewport().get_mouse_position().y > get_viewport_rect().size.y - 260.0:
			return
		if _select_object_under_mouse():
			get_viewport().set_input_as_handled()
			return

func _place_item(pos: Vector3):
	if game_over:
		return
	if not current_active_model: return
	var cell: Vector2i = hex_grid.world_to_axial(pos)
	var placement_layer: String = _get_placement_layer(current_active_model)
	if not _can_place_at(cell, placement_layer):
		print("invalid placement: ", _get_invalid_placement_reason(cell, placement_layer))
		return
	
	var new_item = current_active_model.duplicate()
	world_node.add_child(new_item)
	new_item.global_position = pos
	new_item.show()
	var new_mesh := new_item as MeshInstance3D
	if new_mesh != null:
		new_mesh.create_trimesh_collision()
	new_item.set_meta("placement_layer", placement_layer)
	new_item.set_meta("placeable_kind", _get_placeable_kind(current_active_model))
	if current_active_model.has_meta("mesh_path"):
		new_item.set_meta("mesh_path", str(current_active_model.get_meta("mesh_path")))
	new_item.set_meta("map_scale", current_active_model.scale.x)
	if placement_layer == PLACEMENT_TERRAIN:
		new_item.set_meta("terrain_type", _get_terrain_type(current_active_model))
	_register_placed_item(cell, placement_layer, new_item)
	var happiness_before := happiness
	_apply_happiness_for_placement(cell, placement_layer, new_item)
	_gain_progression_xp(XP_PER_PLACEMENT)
	_register_objective_card_played(maxi(happiness - happiness_before, 0))
	
	print("placement successful: ", current_active_model.name)
	_play_place_sfx()
	_consume_source_card()
	_cancel_placement()

func _rotate_current_placement() -> void:
	current_rotation_steps = (current_rotation_steps + 1) % 6
	current_active_model.rotation_degrees.y = float(current_rotation_steps) * 60.0

func _cancel_placement():
	is_placing = false
	_hide_all_previews()
	_clear_placement_indicators()
	current_active_model = null
	current_rotation_steps = 0

	if current_source_card != null and is_instance_valid(current_source_card):
		# Stop any active drag so the card no longer follows the mouse
		if "is_dragging" in current_source_card:
			current_source_card.set("is_dragging", false)
		_clear_card_manager_selection(current_source_card)
		current_source_card.show()

		# Reposition the card back into the hand layout
		var player_hand := get_tree().get_first_node_in_group("player_hand")
		if player_hand != null and player_hand.has_method("update_hand_positions"):
			player_hand.update_hand_positions()
	current_source_card = null
	print("closed")


func _hide_all_previews():
	for preview: Node3D in placeable_previews:
		if preview:
			preview.hide()

func _create_additional_placeables() -> void:
	for index: int in ADDITIONAL_PLACEABLES.size():
		var placeable: Dictionary = ADDITIONAL_PLACEABLES[index] as Dictionary
		var id: String = str(placeable["id"])
		var label: String = str(placeable["label"])
		var mesh_path: String = str(placeable["mesh_path"])
		var placement_layer: String = str(placeable["placement_layer"])
		var terrain_type: String = str(placeable.get("terrain_type", TERRAIN_LAND))
		var placeable_kind: String = str(placeable.get("placeable_kind", _guess_placeable_kind(id, placement_layer, terrain_type)))
		var mesh_resource: Resource = load(mesh_path)

		if not (mesh_resource is Mesh):
			push_warning("Placeable mesh failed to load: " + mesh_path)
			continue

		var preview: MeshInstance3D = MeshInstance3D.new()
		preview.name = id
		preview.mesh = mesh_resource as Mesh
		preview.scale = Vector3(2.0, 2.0, 2.0)
		preview.set_meta("mesh_path", mesh_path)
		preview.set_meta("map_scale", 2.0)
		build_preview_node.add_child(preview)
		_register_placeable_preview(preview, placement_layer, terrain_type, placeable_kind)

func _register_placeable_preview(preview: Node3D, placement_layer: String, terrain_type: String = TERRAIN_LAND, placeable_kind: String = "") -> void:
	preview.set_meta("placement_layer", placement_layer)
	preview.set_meta("placeable_kind", placeable_kind if not placeable_kind.is_empty() else _guess_placeable_kind(preview.name, placement_layer, terrain_type))
	var mesh_path := _get_node_mesh_path(preview)
	if not mesh_path.is_empty():
		preview.set_meta("mesh_path", mesh_path)
	preview.set_meta("map_scale", preview.scale.x)
	if placement_layer == PLACEMENT_TERRAIN:
		preview.set_meta("terrain_type", terrain_type)
	placeable_previews.append(preview)

func _seed_existing_terrain_cells() -> void:
	terrain_cells.clear()
	object_cells.clear()
	terrain_types.clear()
	terrain_kinds.clear()
	object_kinds.clear()
	happiness_cell_scores.clear()
	for child: Node in world_node.get_children():
		var node_3d: Node3D = child as Node3D
		if node_3d == null:
			continue
		if not node_3d.name.begins_with("HexTile"):
			continue
		var cell: Vector2i = hex_grid.world_to_axial(node_3d.global_position)
		terrain_cells[cell] = node_3d
		terrain_types[cell] = TERRAIN_LAND
		terrain_kinds[cell] = KIND_GRASS
		node_3d.set_meta("placement_layer", PLACEMENT_TERRAIN)
		node_3d.set_meta("terrain_type", TERRAIN_LAND)
		node_3d.set_meta("placeable_kind", KIND_GRASS)
		node_3d.set_meta("mesh_path", ASSET_ROOT + "tiles/base/hex_grass.obj")
		node_3d.set_meta("map_scale", 2.0)

func _can_place_at(cell: Vector2i, placement_layer: String) -> bool:
	if placement_layer == PLACEMENT_TERRAIN:
		return not terrain_cells.has(cell) and _has_adjacent_terrain(cell)
	if placement_layer == PLACEMENT_OBJECT:
		return terrain_cells.has(cell) and _terrain_accepts_object(cell, current_active_model) and not object_cells.has(cell)
	return false

func _get_invalid_placement_reason(cell: Vector2i, placement_layer: String) -> String:
	if placement_layer == PLACEMENT_TERRAIN:
		if terrain_cells.has(cell):
			return "terrain already exists at " + str(cell)
		if not _has_adjacent_terrain(cell):
			return "terrain must be adjacent to an existing tile"
	if placement_layer == PLACEMENT_OBJECT:
		if not terrain_cells.has(cell):
			return "objects must be placed on an existing tile"
		if not _terrain_accepts_object(cell, current_active_model):
			return "object cannot be placed on this terrain"
		if object_cells.has(cell):
			return "tile already has an object"
	return "unknown placeable type"

func _has_adjacent_terrain(cell: Vector2i) -> bool:
	for direction: Vector2i in AXIAL_DIRECTIONS:
		if terrain_cells.has(cell + direction):
			return true
	return false

func _refresh_placement_indicators() -> void:
	_clear_placement_indicators()
	if current_active_model == null:
		return

	_ensure_placement_indicator_resources()
	var placement_layer := _get_placement_layer(current_active_model)
	var indicator_cells := _get_placement_indicator_cells(placement_layer)

	for cell_key in indicator_cells.keys():
		var cell: Vector2i = cell_key
		var is_valid := bool(indicator_cells[cell])
		_create_placement_indicator(cell, is_valid)

func _get_placement_indicator_cells(placement_layer: String) -> Dictionary:
	var indicator_cells := {}
	if placement_layer == PLACEMENT_OBJECT:
		for cell_key in terrain_cells.keys():
			var cell: Vector2i = cell_key
			indicator_cells[cell] = _can_place_at(cell, placement_layer)
		return indicator_cells

	if placement_layer == PLACEMENT_TERRAIN:
		for cell_key in terrain_cells.keys():
			var cell: Vector2i = cell_key
			indicator_cells[cell] = false
			for direction: Vector2i in AXIAL_DIRECTIONS:
				var candidate := cell + direction
				if terrain_cells.has(candidate):
					continue
				indicator_cells[candidate] = _can_place_at(candidate, placement_layer)

	return indicator_cells

func _create_placement_indicator(cell: Vector2i, is_valid: bool) -> void:
	var indicator := MeshInstance3D.new()
	indicator.name = "PlacementValid" if is_valid else "PlacementBlocked"
	indicator.mesh = placement_indicator_mesh
	indicator.material_override = placement_valid_material if is_valid else placement_invalid_material
	var world_position := hex_grid.axial_to_world(cell.x, cell.y)
	world_position.y = PLACEMENT_INDICATOR_Y
	indicator.global_position = world_position
	world_node.add_child(indicator)
	placement_indicators.append(indicator)

func _clear_placement_indicators() -> void:
	for indicator: MeshInstance3D in placement_indicators:
		if indicator != null and is_instance_valid(indicator):
			indicator.queue_free()
	placement_indicators.clear()

func _ensure_placement_indicator_resources() -> void:
	if placement_indicator_mesh == null:
		placement_indicator_mesh = CylinderMesh.new()
		placement_indicator_mesh.top_radius = PLACEMENT_INDICATOR_RADIUS
		placement_indicator_mesh.bottom_radius = PLACEMENT_INDICATOR_RADIUS
		placement_indicator_mesh.height = PLACEMENT_INDICATOR_HEIGHT
		placement_indicator_mesh.radial_segments = 6
		placement_indicator_mesh.rings = 1
	if placement_valid_material == null:
		placement_valid_material = _make_placement_indicator_material(Color(0.1, 0.95, 0.28, 0.19))
	if placement_invalid_material == null:
		placement_invalid_material = _make_placement_indicator_material(Color(1.0, 0.08, 0.08, 0.17))

func _make_placement_indicator_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.disable_receive_shadows = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func request_interact_cursor() -> void:
	cursor_interact_requests += 1
	_refresh_mouse_cursor()

func release_interact_cursor() -> void:
	cursor_interact_requests = maxi(cursor_interact_requests - 1, 0)
	_refresh_mouse_cursor()

func set_interact_cursor() -> void:
	cursor_interact_requests = maxi(cursor_interact_requests, 1)
	_refresh_mouse_cursor()

func set_default_cursor() -> void:
	cursor_interact_requests = 0
	cursor_over_world_interaction = false
	_refresh_mouse_cursor()

func _apply_default_cursor() -> void:
	Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, CURSOR_DEFAULT_HOTSPOT)
	_refresh_mouse_cursor()

func _refresh_mouse_cursor() -> void:
	var use_interact_cursor := cursor_interact_requests > 0 or cursor_over_world_interaction
	var texture := CURSOR_INTERACT if use_interact_cursor else CURSOR_DEFAULT
	var hotspot := CURSOR_INTERACT_HOTSPOT if use_interact_cursor else CURSOR_DEFAULT_HOTSPOT
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, hotspot)

func _set_world_interaction_cursor(is_interactive: bool) -> void:
	if cursor_over_world_interaction == is_interactive:
		return
	cursor_over_world_interaction = is_interactive
	_refresh_mouse_cursor()

func _update_world_interaction_cursor() -> void:
	if get_viewport().get_mouse_position().y > get_viewport_rect().size.y - 260.0:
		_set_world_interaction_cursor(false)
		return
	_set_world_interaction_cursor(_get_hovered_object() != null)

func _register_placed_item(cell: Vector2i, placement_layer: String, item: Node3D) -> void:
	if placement_layer == PLACEMENT_TERRAIN:
		terrain_cells[cell] = item
		terrain_types[cell] = _get_terrain_type(item)
		terrain_kinds[cell] = _get_placeable_kind(item)
	elif placement_layer == PLACEMENT_OBJECT:
		object_cells[cell] = item
		object_kinds[cell] = _get_placeable_kind(item)

func _apply_happiness_for_placement(cell: Vector2i, placement_layer: String, item: Node3D) -> void:
	var placeable_kind := _get_placeable_kind(item)
	var delta := 0

	if placement_layer == PLACEMENT_OBJECT:
		delta = _get_object_happiness_delta(cell, placeable_kind)
	elif placement_layer == PLACEMENT_TERRAIN and placeable_kind == KIND_ROAD:
		delta = _get_road_happiness_delta(cell)

	if delta == 0:
		return

	var score_key := _happiness_score_key(cell, placement_layer)
	happiness_cell_scores[score_key] = int(happiness_cell_scores.get(score_key, 0)) + delta
	_change_happiness(delta)

func _happiness_score_key(cell: Vector2i, placement_layer: String) -> String:
	return placement_layer + ":" + str(cell.x) + "," + str(cell.y)

func _get_object_happiness_delta(cell: Vector2i, placeable_kind: String) -> int:
	if placeable_kind == KIND_BUILDING:
		var delta := HAPPINESS_BUILDING_PERCENT
		if _has_adjacent_road(cell):
			delta += HAPPINESS_BUILDING_ROAD_BONUS_PERCENT
		return delta

	return 0

func _get_road_happiness_delta(cell: Vector2i) -> int:
	var connected_buildings := _get_adjacent_building_count(cell)
	if connected_buildings <= 0:
		return 0
	return connected_buildings * HAPPINESS_ROAD_CONNECTION_PERCENT

func _get_adjacent_building_count(cell: Vector2i) -> int:
	var building_count := 0
	for direction: Vector2i in AXIAL_DIRECTIONS:
		var neighbor := cell + direction
		if object_kinds.has(neighbor) and str(object_kinds[neighbor]) == KIND_BUILDING:
			building_count += 1
	return building_count

func _has_adjacent_road(cell: Vector2i) -> bool:
	for direction: Vector2i in AXIAL_DIRECTIONS:
		var neighbor := cell + direction
		if terrain_kinds.has(neighbor) and str(terrain_kinds[neighbor]) == KIND_ROAD:
			return true
	return false

func _change_happiness(delta: int) -> void:
	happiness = clampi(happiness + delta, 0, HAPPINESS_MAX)
	_sync_progression_hud()
	_check_win_condition()

func _register_objective_card_played(_happiness_delta: int) -> void:
	if game_over or endless_mode:
		return

	objective_cards_played += 1

	if recovery_active:
		if happiness >= recovery_target_happiness:
			_reset_happiness_objective()
		elif objective_cards_played >= HAPPINESS_RECOVERY_CARDS:
			_trigger_game_over()
		_sync_progression_hud()
		return

	if objective_cards_played >= HAPPINESS_CHECK_CARDS:
		var gained := happiness - objective_start_happiness
		if gained >= HAPPINESS_CHECK_TARGET:
			_reset_happiness_objective()
		else:
			_start_happiness_recovery(HAPPINESS_CHECK_TARGET - gained)
	_sync_progression_hud()

func _reset_happiness_objective() -> void:
	recovery_active = false
	objective_cards_played = 0
	objective_start_happiness = happiness
	recovery_target_happiness = 0

func _start_happiness_recovery(missing_happiness: int) -> void:
	recovery_active = true
	objective_cards_played = 0
	recovery_target_happiness = min(happiness + missing_happiness, HAPPINESS_MAX)

	if happiness_warning_dialog != null:
		happiness_warning_dialog.dialog_text = "Happiness only increased by " + str(HAPPINESS_CHECK_TARGET - missing_happiness) + "% in the last " + str(HAPPINESS_CHECK_CARDS) + " cards.\nGet +" + str(missing_happiness) + "% more happiness in the next " + str(HAPPINESS_RECOVERY_CARDS) + " cards."
		happiness_warning_dialog.popup_centered()

func _trigger_game_over() -> void:
	game_over = true
	if game_over_dialog != null:
		game_over_dialog.dialog_text = "Game over.\nReach " + str(recovery_target_happiness) + "% happiness before the recovery window ends."
		game_over_dialog.popup_centered()

func _check_win_condition() -> void:
	if has_won or endless_mode or happiness < HAPPINESS_MAX:
		return
	has_won = true
	if win_dialog != null:
		win_dialog.dialog_text = "You reached 100% happiness.\nRestart or continue in endless mode?"
		win_dialog.popup_centered()

func _continue_endless_mode() -> void:
	endless_mode = true
	has_won = true
	game_over = false
	recovery_active = false
	_sync_progression_hud()


func _terrain_accepts_object(cell: Vector2i, placeable: Node3D = null) -> bool:
	var required_terrain: String = TERRAIN_LAND
	if placeable != null and placeable.has_meta("terrain_requirement"):
		required_terrain = str(placeable.get_meta("terrain_requirement"))
	if required_terrain == TERRAIN_ANY:
		return true
	return str(terrain_types.get(cell, TERRAIN_WATER)) == required_terrain

func get_available_build_tile_count() -> int:
	var available_count := 0
	for cell_key in terrain_cells.keys():
		var cell: Vector2i = cell_key
		if object_cells.has(cell):
			continue
		if str(terrain_types.get(cell, TERRAIN_WATER)) != TERRAIN_LAND:
			continue
		available_count += 1
	return available_count

func get_available_water_prop_tile_count() -> int:
	var available_count := 0
	for cell_key in terrain_cells.keys():
		var cell: Vector2i = cell_key
		if object_cells.has(cell):
			continue
		if str(terrain_types.get(cell, TERRAIN_LAND)) != TERRAIN_WATER:
			continue
		available_count += 1
	return available_count

func _get_placement_layer(placeable: Node3D) -> String:
	if placeable.has_meta("placement_layer"):
		return str(placeable.get_meta("placement_layer"))
	return PLACEMENT_OBJECT

func _get_terrain_type(placeable: Node3D) -> String:
	if placeable.has_meta("terrain_type"):
		return str(placeable.get_meta("terrain_type"))
	return TERRAIN_LAND

func _get_placeable_kind(placeable: Node3D) -> String:
	if placeable.has_meta("placeable_kind"):
		return str(placeable.get_meta("placeable_kind"))
	return _guess_placeable_kind(placeable.name, _get_placement_layer(placeable), _get_terrain_type(placeable))

func _guess_placeable_kind(label: String, placement_layer: String, terrain_type: String = TERRAIN_LAND) -> String:
	var key := label.to_lower()
	if placement_layer == PLACEMENT_TERRAIN:
		if key.contains("road"):
			return KIND_ROAD
		if terrain_type == TERRAIN_WATER or key.contains("water") or key.contains("coast") or key.contains("river"):
			return KIND_WATER
		return KIND_GRASS
	if key.contains("house") or key.contains("home") or key.contains("castle") or key.contains("market") or key.contains("building") or key.contains("church") or key.contains("tavern") or key.contains("mill") or key.contains("mine") or key.contains("blacksmith") or key.contains("barracks"):
		return KIND_BUILDING
	if key.contains("tree") or key.contains("forest") or key.contains("hill") or key.contains("mountain") or key.contains("rock"):
		return KIND_NATURE
	if key.contains("waterlily") or key.contains("waterplant"):
		return KIND_WATER_DECORATION
	return KIND_DECORATION

func _consume_source_card() -> void:
	if current_source_card == null or not is_instance_valid(current_source_card):
		current_source_card = null
		return

	var player_hand := get_tree().get_first_node_in_group("player_hand")
	if player_hand != null and player_hand.has_method("remove_card"):
		player_hand.remove_card(current_source_card)

	_clear_card_manager_selection(current_source_card)
	current_source_card.queue_free()
	current_source_card = null

func _clear_card_manager_selection(card: Node2D) -> void:
	var card_manager := get_tree().get_first_node_in_group("card_manager")
	if card_manager != null and card_manager.has_method("clear_selected_card"):
		card_manager.clear_selected_card(card)

func _get_or_create_card_preview(card_data: CardData) -> Node3D:
	var definition := _get_card_placeable_definition(card_data)
	if definition.is_empty():
		return null

	var cache_key: String = str(definition["mesh_path"]) + "|" + str(definition["placement_layer"]) + "|" + str(definition.get("terrain_type", TERRAIN_LAND)) + "|" + str(definition.get("terrain_requirement", TERRAIN_ANY)) + "|" + str(definition.get("scale", 2.0)) + "|" + str(definition.get("placeable_kind", ""))
	if card_placeable_previews.has(cache_key):
		return card_placeable_previews[cache_key]

	var mesh_resource: Resource = load(str(definition["mesh_path"]))
	if not (mesh_resource is Mesh):
		push_warning("Card mesh failed to load: " + str(definition["mesh_path"]))
		return null

	var preview := MeshInstance3D.new()
	preview.name = _safe_node_name(str(card_data.display_name))
	preview.mesh = mesh_resource as Mesh
	var preview_scale := float(definition.get("scale", 2.0))
	preview.scale = Vector3(preview_scale, preview_scale, preview_scale)
	preview.set_meta("mesh_path", str(definition["mesh_path"]))
	preview.set_meta("map_scale", preview_scale)
	if str(definition["placement_layer"]) == PLACEMENT_TERRAIN and str(definition.get("terrain_type", TERRAIN_LAND)) == TERRAIN_LAND:
		_apply_default_land_tile_material(preview)
	build_preview_node.add_child(preview)
	_register_placeable_preview(preview, str(definition["placement_layer"]), str(definition.get("terrain_type", TERRAIN_LAND)), str(definition.get("placeable_kind", "")))
	if definition.has("terrain_requirement"):
		preview.set_meta("terrain_requirement", str(definition["terrain_requirement"]))
	preview.hide()
	card_placeable_previews[cache_key] = preview
	return preview

func _get_card_placeable_definition(card_data: CardData) -> Dictionary:
	var card_id: String = str(card_data.card_id).strip_edges().to_lower()
	var display_name: String = str(card_data.display_name).strip_edges().to_lower()
	var texture_path: String = ""
	if card_data.texture != null:
		texture_path = str(card_data.texture.resource_path).to_lower()
	var key: String = (card_id + " " + display_name + " " + texture_path).replace("  ", " ")

	if key.contains("mountain"):
		return _object_definition(_nature_mesh_path(key, "mountain", "mountain_A_grass_trees"), TERRAIN_LAND, 2.0, KIND_NATURE)
	if key.contains("waterlily"):
		return _object_definition(ASSET_ROOT + "decoration/nature/waterlily_A.obj", TERRAIN_WATER, 4.5, KIND_WATER_DECORATION)
	if key.contains("waterplant"):
		return _object_definition(ASSET_ROOT + "decoration/nature/waterplant_C.obj", TERRAIN_WATER, 4.5, KIND_WATER_DECORATION)
	if key.contains("grass bottom"):
		return _terrain_definition(ASSET_ROOT + "tiles/base/hex_grass.obj", TERRAIN_LAND, KIND_GRASS)
	if key.contains("grass sloped high"):
		return _terrain_definition(ASSET_ROOT + "tiles/base/hex_grass_sloped_high.obj", TERRAIN_LAND, KIND_GRASS)
	if key.contains("grass"):
		return _terrain_definition(ASSET_ROOT + "tiles/base/hex_grass.obj", TERRAIN_LAND, KIND_GRASS)
	if key.contains("water") and not key.contains("bucket") and not key.contains("watermill"):
		return _terrain_definition(ASSET_ROOT + "tiles/base/hex_water.obj", TERRAIN_WATER, KIND_WATER)
	if key.contains("coastb") or key.contains("coast b"):
		return _terrain_definition(ASSET_ROOT + "tiles/coast/hex_coast_B.obj", TERRAIN_WATER, KIND_WATER)
	if key.contains("coasta") or key.contains("coast a") or key.contains("coast"):
		return _terrain_definition(ASSET_ROOT + "tiles/coast/hex_coast_A.obj", TERRAIN_WATER, KIND_WATER)
	if key.contains("river"):
		return _terrain_definition(_lettered_tile_path(key, "river", ASSET_ROOT + "tiles/rivers/hex_river_", ".obj"), TERRAIN_WATER, KIND_WATER)
	if key.contains("road"):
		return _terrain_definition(_lettered_tile_path(key, "road", ASSET_ROOT + "tiles/roads/hex_road_", ".obj"), TERRAIN_LAND, KIND_ROAD)
	if key.contains("building"):
		return _object_definition(_building_mesh_path(key), TERRAIN_LAND, 2.0, KIND_BUILDING)
	if key.contains("hill"):
		return _object_definition(_nature_mesh_path(key, "hills", "hills_A_trees"), TERRAIN_LAND, 2.0, KIND_NATURE)
	if key.contains("tree"):
		return _object_definition(_nature_mesh_path(key, "tree", "trees_A_large"), TERRAIN_LAND, 2.0, KIND_NATURE)
	if key.contains("rock"):
		return _object_definition(ASSET_ROOT + "decoration/nature/rock_single_A.obj", TERRAIN_LAND, 4.0, KIND_NATURE)
	if key.contains("barrel"):
		return _object_definition(ASSET_ROOT + "decoration/props/barrel.obj", TERRAIN_LAND, 4.5, KIND_DECORATION)
	if key.contains("bucket"):
		return _object_definition(ASSET_ROOT + "decoration/props/bucket_water.obj", TERRAIN_LAND, 2.0, KIND_DECORATION)
	if key.contains("tent"):
		return _object_definition(ASSET_ROOT + "decoration/props/tent.obj", TERRAIN_LAND, 2.0, KIND_DECORATION)
	if key.contains("flag"):
		return _object_definition(ASSET_ROOT + "decoration/props/flag_blue.obj", TERRAIN_LAND, 2.0, KIND_DECORATION)

	return {}

func _terrain_definition(mesh_path: String, terrain_type: String, placeable_kind: String) -> Dictionary:
	return {
		"mesh_path": mesh_path,
		"placement_layer": PLACEMENT_TERRAIN,
		"terrain_type": terrain_type,
		"placeable_kind": placeable_kind
	}

func _find_default_land_tile_material() -> Material:
	for child: Node in world_node.get_children():
		var node_3d := child as Node3D
		if node_3d == null or not node_3d.name.begins_with("HexTile"):
			continue
		var mesh_instance := _find_first_mesh_instance(node_3d)
		if mesh_instance == null:
			continue
		var material := mesh_instance.get_active_material(0)
		if material != null:
			return material
	return null

func _find_first_mesh_instance(node: Node) -> MeshInstance3D:
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null:
		return mesh_instance
	for child: Node in node.get_children():
		var child_mesh := _find_first_mesh_instance(child)
		if child_mesh != null:
			return child_mesh
	return null

func _apply_default_land_tile_material(mesh_instance: MeshInstance3D) -> void:
	if default_land_tile_material == null:
		return
	mesh_instance.material_override = default_land_tile_material

func _object_definition(mesh_path: String, terrain_requirement: String, scale: float = 2.0, placeable_kind: String = KIND_DECORATION) -> Dictionary:
	return {
		"mesh_path": mesh_path,
		"placement_layer": PLACEMENT_OBJECT,
		"terrain_requirement": terrain_requirement,
		"scale": scale,
		"placeable_kind": placeable_kind
	}

func _lettered_tile_path(key: String, tile_type: String, prefix: String, suffix: String) -> String:
	var letter := "A"
	for candidate in ["a", "b", "c", "d", "e", "f"]:
		if key.contains(tile_type + " " + candidate):
			letter = candidate.to_upper()
			break
	var variant := ""
	if key.contains("curvy"):
		variant = "_curvy"
	return prefix + letter + variant + suffix

func _building_mesh_path(key: String) -> String:
	var building_name := "archeryrange"
	for candidate in ["barracks", "blacksmith", "castle", "church", "lumbermill", "market", "mine", "tavern", "watermill", "windmill"]:
		if key.contains(candidate):
			building_name = candidate
			break
	if key.contains("home") or key.contains("house"):
		building_name = "home_A"
	return ASSET_ROOT + "buildings/blue/building_" + building_name + "_blue.obj"

func _nature_mesh_path(key: String, prefix: String, fallback: String) -> String:
	var letter := "A"
	for candidate in ["a", "b", "c"]:
		if key.contains(" " + candidate + " "):
			letter = candidate.to_upper()
			break
	if prefix == "mountain":
		return ASSET_ROOT + "decoration/nature/mountain_" + letter + "_grass_trees.obj"
	return ASSET_ROOT + "decoration/nature/hills_" + letter + "_trees.obj" if prefix == "hills" else ASSET_ROOT + "decoration/nature/" + fallback + ".obj"

func _safe_node_name(label: String) -> String:
	return label.replace(" ", "").replace("/", "")

func _toggle_fullscreen() -> void:
	WindowModeHelper.toggle_fullscreen()
	_sync_resolution_option()

func _create_ingame_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "MenuLayer"
	menu_layer.layer = 100
	add_child(menu_layer)

	menu_blocker = ColorRect.new()
	menu_blocker.name = "MenuInputBlocker"
	menu_blocker.visible = false
	menu_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_blocker.color = Color(0.0, 0.0, 0.0, 0.0)
	menu_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(menu_blocker)

	var menu_button := Button.new()
	menu_button.name = "MenuButton"
	menu_button.text = "Menu"
	menu_button.tooltip_text = "Open menu"
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.anchor_left = 1.0
	menu_button.anchor_right = 1.0
	menu_button.offset_left = -118.0
	menu_button.offset_top = 18.0
	menu_button.offset_right = -18.0
	menu_button.offset_bottom = 54.0
	_apply_menu_button_style(menu_button, 26)
	_register_interactive_control(menu_button)
	menu_button.pressed.connect(_toggle_ingame_menu)
	menu_layer.add_child(menu_button)

	menu_panel = PanelContainer.new()
	menu_panel.name = "InGameMenu"
	menu_panel.visible = false
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_panel.anchor_left = 0.5
	menu_panel.anchor_top = 0.5
	menu_panel.anchor_right = 0.5
	menu_panel.anchor_bottom = 0.5
	menu_panel.offset_left = -MENU_WIDTH / 2.0
	menu_panel.offset_top = -285.0
	menu_panel.offset_right = MENU_WIDTH / 2.0
	menu_panel.offset_bottom = 285.0
	menu_panel.add_theme_stylebox_override("panel", _make_panel_style())
	menu_layer.add_child(menu_panel)
	_create_restart_confirm_dialog()

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	menu_panel.add_child(layout)

	var title := Label.new()
	title.text = "Menu"
	title.add_theme_font_override("font", MENU_TITLE_FONT)
	title.add_theme_font_size_override("font_size", 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	menu_buttons_panel = VBoxContainer.new()
	menu_buttons_panel.add_theme_constant_override("separation", 20)
	layout.add_child(menu_buttons_panel)

	var resume_button := _create_menu_button("Resume")
	resume_button.pressed.connect(_hide_ingame_menu)
	menu_buttons_panel.add_child(resume_button)

	var settings_button := _create_menu_button("Settings")
	settings_button.pressed.connect(_show_menu_section.bind("settings"))
	menu_buttons_panel.add_child(settings_button)

	var controls_button := _create_menu_button("Controls")
	controls_button.pressed.connect(_show_menu_section.bind("controls"))
	menu_buttons_panel.add_child(controls_button)

	var export_button := _create_menu_button("Export Map")
	export_button.pressed.connect(_request_export_map)
	menu_buttons_panel.add_child(export_button)

	var load_button := _create_menu_button("Load Map")
	load_button.pressed.connect(_request_load_map)
	menu_buttons_panel.add_child(load_button)
	
	var restart_button := _create_menu_button("Restart")
	restart_button.pressed.connect(_request_restart_game)
	menu_buttons_panel.add_child(restart_button)

	var exit_button := _create_menu_button("Exit Game")
	exit_button.pressed.connect(_exit_game)
	menu_buttons_panel.add_child(exit_button)

	settings_panel = _create_settings_panel()
	layout.add_child(settings_panel)

	controls_panel = _create_controls_panel()
	layout.add_child(controls_panel)

	_show_menu_section("")

func _create_menu_button(label: String) -> Button:
	var button := Button.new()
	button.text = label
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_menu_button_style(button, 35)
	_register_interactive_control(button)
	return button

func _register_interactive_control(control: Control) -> void:
	control.mouse_entered.connect(request_interact_cursor)
	control.mouse_exited.connect(release_interact_cursor)

func _create_restart_confirm_dialog() -> void:
	restart_confirm_dialog = ConfirmationDialog.new()
	restart_confirm_dialog.title = "Restart Game"
	restart_confirm_dialog.dialog_text = "Are you sure you want to restart?"
	restart_confirm_dialog.ok_button_text = "Restart"
	restart_confirm_dialog.cancel_button_text = "Cancel"
	restart_confirm_dialog.confirmed.connect(_restart_game)
	if menu_layer != null:
		menu_layer.add_child(restart_confirm_dialog)
	else:
		add_child(restart_confirm_dialog)

	happiness_warning_dialog = AcceptDialog.new()
	happiness_warning_dialog.title = "Happiness Warning"
	happiness_warning_dialog.ok_button_text = "Understood"
	if menu_layer != null:
		menu_layer.add_child(happiness_warning_dialog)
	else:
		add_child(happiness_warning_dialog)

	game_over_dialog = AcceptDialog.new()
	game_over_dialog.title = "Game Over"
	game_over_dialog.dialog_text = "The town did not recover enough happiness."
	game_over_dialog.ok_button_text = "Restart"
	game_over_dialog.confirmed.connect(_restart_game)
	if menu_layer != null:
		menu_layer.add_child(game_over_dialog)
	else:
		add_child(game_over_dialog)

	win_dialog = ConfirmationDialog.new()
	win_dialog.title = "Victory"
	win_dialog.dialog_text = "Happiness reached 100%."
	win_dialog.ok_button_text = "Restart"
	win_dialog.cancel_button_text = "Continue"
	win_dialog.confirmed.connect(_restart_game)
	win_dialog.get_cancel_button().pressed.connect(_continue_endless_mode)
	if menu_layer != null:
		menu_layer.add_child(win_dialog)
	else:
		add_child(win_dialog)

func _create_map_file_dialogs() -> void:
	export_map_dialog = FileDialog.new()
	export_map_dialog.title = "Export Map"
	export_map_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_map_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_map_dialog.filters = PackedStringArray(["*.json ; Hexagone map"])
	export_map_dialog.current_file = "hexagone_map.json"
	export_map_dialog.file_selected.connect(_export_map_to_file)
	if menu_layer != null:
		menu_layer.add_child(export_map_dialog)
	else:
		add_child(export_map_dialog)

	load_map_dialog = FileDialog.new()
	load_map_dialog.title = "Load Map"
	load_map_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_map_dialog.access = FileDialog.ACCESS_FILESYSTEM
	load_map_dialog.filters = PackedStringArray(["*.json ; Hexagone map"])
	load_map_dialog.file_selected.connect(_load_map_from_file)
	if menu_layer != null:
		menu_layer.add_child(load_map_dialog)
	else:
		add_child(load_map_dialog)

func _request_export_map() -> void:
	if export_map_dialog == null:
		_export_map_to_file(DEFAULT_MAP_FILE)
		return
	export_map_dialog.popup_centered_ratio(0.72)

func _request_load_map() -> void:
	if load_map_dialog == null:
		_load_map_from_file(DEFAULT_MAP_FILE)
		return
	load_map_dialog.popup_centered_ratio(0.72)

func _export_map_to_file(path: String) -> void:
	var export_path := path
	if export_path.get_extension().is_empty():
		export_path += ".json"

	var file := FileAccess.open(export_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not export map to " + export_path + ": " + error_string(FileAccess.get_open_error()))
		return

	var map_data := _create_map_export_data()
	file.store_string(JSON.stringify(map_data, "\t"))
	file.close()
	print("Map exported to ", export_path)

func _load_map_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("Map file does not exist: " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not load map from " + path + ": " + error_string(FileAccess.get_open_error()))
		return

	var text := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Map file is not valid JSON: " + path)
		return

	var map_data: Dictionary = parsed as Dictionary
	_apply_map_data(map_data)
	print("Map loaded from ", path)

func _create_map_export_data() -> Dictionary:
	var terrain_entries: Array[Dictionary] = []
	var object_entries: Array[Dictionary] = []

	for cell_key in terrain_cells.keys():
		var cell: Vector2i = cell_key
		var terrain_node := terrain_cells[cell] as Node3D
		if terrain_node == null or not is_instance_valid(terrain_node):
			continue
		terrain_entries.append(_serialize_map_item(cell, PLACEMENT_TERRAIN, terrain_node))

	for cell_key in object_cells.keys():
		var cell: Vector2i = cell_key
		var object_node := object_cells[cell] as Node3D
		if object_node == null or not is_instance_valid(object_node):
			continue
		object_entries.append(_serialize_map_item(cell, PLACEMENT_OBJECT, object_node))

	return {
		"version": MAP_SAVE_VERSION,
		"terrain": terrain_entries,
		"objects": object_entries,
		"state": {
			"happiness": happiness,
			"level": player_level,
			"xp": current_xp,
			"xp_to_next_level": xp_to_next_level,
			"bigger_hand_uses": bigger_hand_uses,
			"objective_cards_played": objective_cards_played,
			"objective_start_happiness": objective_start_happiness,
			"recovery_active": recovery_active,
			"recovery_target_happiness": recovery_target_happiness,
			"game_over": game_over,
			"has_won": has_won,
			"endless_mode": endless_mode
		}
	}

func _serialize_map_item(cell: Vector2i, placement_layer: String, item: Node3D) -> Dictionary:
	var mesh_path := ""
	if item.has_meta("mesh_path"):
		mesh_path = str(item.get_meta("mesh_path"))
	if mesh_path.is_empty():
		mesh_path = _get_node_mesh_path(item)

	return {
		"q": cell.x,
		"r": cell.y,
		"y": item.global_position.y,
		"rotation_y": item.rotation_degrees.y,
		"scale": _get_map_item_scale(item),
		"mesh_path": mesh_path,
		"placement_layer": placement_layer,
		"terrain_type": str(item.get_meta("terrain_type")) if item.has_meta("terrain_type") else TERRAIN_LAND,
		"placeable_kind": _get_placeable_kind(item),
		"terrain_requirement": str(item.get_meta("terrain_requirement")) if item.has_meta("terrain_requirement") else TERRAIN_LAND
	}

func _apply_map_data(map_data: Dictionary) -> void:
	_cancel_placement()
	_clear_selected_object()
	_clear_map_nodes()
	terrain_cells.clear()
	object_cells.clear()
	terrain_types.clear()
	terrain_kinds.clear()
	object_kinds.clear()
	happiness_cell_scores.clear()

	var terrain_variant: Variant = map_data.get("terrain", [])
	if typeof(terrain_variant) == TYPE_ARRAY:
		var terrain_entries: Array = terrain_variant as Array
		for entry_variant: Variant in terrain_entries:
			if typeof(entry_variant) == TYPE_DICTIONARY:
				_instantiate_map_item(entry_variant as Dictionary, PLACEMENT_TERRAIN)

	var object_variant: Variant = map_data.get("objects", [])
	if typeof(object_variant) == TYPE_ARRAY:
		var object_entries: Array = object_variant as Array
		for entry_variant: Variant in object_entries:
			if typeof(entry_variant) == TYPE_DICTIONARY:
				_instantiate_map_item(entry_variant as Dictionary, PLACEMENT_OBJECT)

	var state_variant: Variant = map_data.get("state", {})
	if typeof(state_variant) == TYPE_DICTIONARY:
		_apply_loaded_game_state(state_variant as Dictionary)
	else:
		_reset_loaded_game_state()

	_sync_progression_hud()
	_hide_ingame_menu()

func _instantiate_map_item(entry: Dictionary, placement_layer: String) -> void:
	var mesh_path := str(entry.get("mesh_path", ""))
	if mesh_path.is_empty():
		push_warning("Skipped map item without mesh path")
		return

	var mesh_resource := load(mesh_path)
	if not (mesh_resource is Mesh):
		push_warning("Skipped map item with missing mesh: " + mesh_path)
		return

	var cell := Vector2i(int(entry.get("q", 0)), int(entry.get("r", 0)))
	var item := MeshInstance3D.new()
	item.name = "MapTerrain" if placement_layer == PLACEMENT_TERRAIN else "MapObject"
	item.mesh = mesh_resource as Mesh
	var logical_scale := _get_loaded_map_item_scale(entry, placement_layer, mesh_path)
	var position := hex_grid.axial_to_world(cell.x, cell.y)
	position.y = float(entry.get("y", 0.0))
	item.set_meta("mesh_path", mesh_path)
	item.set_meta("map_scale", logical_scale)
	item.set_meta("placement_layer", placement_layer)
	item.set_meta("placeable_kind", str(entry.get("placeable_kind", KIND_GRASS)))

	if placement_layer == PLACEMENT_TERRAIN:
		var terrain_type := str(entry.get("terrain_type", TERRAIN_LAND))
		item.set_meta("terrain_type", terrain_type)
		if terrain_type == TERRAIN_LAND:
			_apply_default_land_tile_material(item)
	else:
		item.set_meta("terrain_requirement", str(entry.get("terrain_requirement", TERRAIN_LAND)))

	world_node.add_child(item)
	item.scale = Vector3(logical_scale, logical_scale, logical_scale)
	item.global_position = position
	item.rotation_degrees = Vector3(0.0, float(entry.get("rotation_y", 0.0)), 0.0)
	item.create_trimesh_collision()
	_register_placed_item(cell, placement_layer, item)

func _clear_map_nodes() -> void:
	for child: Node in world_node.get_children():
		var node_3d := child as Node3D
		if node_3d == null:
			continue
		if node_3d.has_meta("placement_layer") or node_3d.name.begins_with("HexTile") or node_3d.name.begins_with("MapTerrain") or node_3d.name.begins_with("MapObject"):
			world_node.remove_child(node_3d)
			node_3d.queue_free()

func _apply_loaded_game_state(state: Dictionary) -> void:
	happiness = clampi(int(state.get("happiness", HAPPINESS_START)), 0, HAPPINESS_MAX)
	player_level = maxi(int(state.get("level", 1)), 1)
	current_xp = maxi(int(state.get("xp", 0)), 0)
	xp_to_next_level = maxi(int(state.get("xp_to_next_level", BASE_XP_TO_LEVEL)), 1)
	bigger_hand_uses = clampi(int(state.get("bigger_hand_uses", 0)), 0, MAX_BIGGER_HAND_USES)
	objective_cards_played = maxi(int(state.get("objective_cards_played", 0)), 0)
	objective_start_happiness = clampi(int(state.get("objective_start_happiness", happiness)), 0, HAPPINESS_MAX)
	recovery_active = bool(state.get("recovery_active", false))
	recovery_target_happiness = clampi(int(state.get("recovery_target_happiness", 0)), 0, HAPPINESS_MAX)
	game_over = bool(state.get("game_over", false))
	has_won = bool(state.get("has_won", false))
	endless_mode = bool(state.get("endless_mode", false))

func _reset_loaded_game_state() -> void:
	happiness = HAPPINESS_START
	player_level = 1
	current_xp = 0
	xp_to_next_level = BASE_XP_TO_LEVEL
	bigger_hand_uses = 0
	game_over = false
	has_won = false
	endless_mode = false
	_reset_happiness_objective()

func _get_node_mesh_path(node: Node3D) -> String:
	var mesh_instance := _find_first_mesh_instance(node)
	if mesh_instance == null or mesh_instance.mesh == null:
		return ""
	return mesh_instance.mesh.resource_path

func _get_map_item_scale(item: Node3D) -> float:
	if item.has_meta("map_scale"):
		return float(item.get_meta("map_scale"))
	var mesh_instance := _find_first_mesh_instance(item)
	if mesh_instance != null:
		return mesh_instance.scale.x
	return item.scale.x

func _get_loaded_map_item_scale(entry: Dictionary, placement_layer: String, mesh_path: String) -> float:
	if placement_layer == PLACEMENT_TERRAIN:
		return TERRAIN_TILE_SCALE

	var saved_scale := float(entry.get("scale", 0.0))
	var expected_scale := _get_default_object_scale(mesh_path, str(entry.get("placeable_kind", "")))
	return maxf(saved_scale, expected_scale)

func _get_default_object_scale(mesh_path: String, placeable_kind: String) -> float:
	var key := (mesh_path + " " + placeable_kind).to_lower()
	if key.contains("waterlily") or key.contains("waterplant") or key.contains("barrel"):
		return 4.5
	if key.contains("rock_single"):
		return 4.0
	return 2.0

func _create_settings_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 20)

	var screen_label := Label.new()
	screen_label.text = "Screen:"
	_apply_menu_label_style(screen_label, 50)
	panel.add_child(screen_label)

	resolution_option = OptionButton.new()
	resolution_option.add_item("Windowed", 0)
	resolution_option.add_item("Fullscreen", 1)
	_apply_menu_button_style(resolution_option, 30)
	_register_interactive_control(resolution_option)
	resolution_option.item_selected.connect(_on_resolution_selected)
	panel.add_child(resolution_option)
	_sync_resolution_option()
	
	

	var music_label := Label.new()
	music_label.text = "Music:"
	_apply_menu_label_style(music_label, 50)
	panel.add_child(music_label)
	panel.add_child(_create_volume_slider("Music"))

	var sfx_label := Label.new()
	sfx_label.text = "Soundeffects:"
	_apply_menu_label_style(sfx_label, 50)
	panel.add_child(sfx_label)
	panel.add_child(_create_volume_slider("SFX"))

	var back_button := _create_menu_button("Back")
	back_button.pressed.connect(_show_menu_section.bind(""))
	panel.add_child(back_button)

	return panel

func _create_controls_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override("separation", 0)

	var controls_text := Label.new()
	controls_text.text = "WASD - Move camera\nMouse wheel - Zoom\nQ/E - Rotate\nR/F - Tilt\nX - Reset camera\nLeft click - Place selected card or select object\nSpace - Rotate selected card\nRight click - Cancel placement\nDelete - Remove selected object\nPower-up buttons - Use level rewards\nF11 - Toggle fullscreen\nEsc - Toggle menu"
	controls_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_menu_label_style(controls_text, 28)
	panel.add_child(controls_text)

	var back_button := _create_menu_button("Back")
	back_button.pressed.connect(_show_menu_section.bind(""))
	panel.add_child(back_button)

	return panel

func _create_progression_hud() -> void:
	progression_panel = PanelContainer.new()
	progression_panel.name = "ProgressionHUD"
	progression_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	progression_panel.offset_left = 18.0
	progression_panel.offset_top = 18.0
	progression_panel.offset_right = 326.0
	progression_panel.offset_bottom = 430.0
	progression_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(progression_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	progression_panel.add_child(layout)

	level_label = Label.new()
	level_label.text = "Level 1"
	level_label.add_theme_font_override("font", MENU_TITLE_FONT)
	level_label.add_theme_font_size_override("font_size", 34)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(level_label)

	xp_label = Label.new()
	xp_label.text = "XP 0 / 4"
	_apply_menu_label_style(xp_label, 20)
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(xp_label)

	xp_bar = ProgressBar.new()
	xp_bar.min_value = 0.0
	xp_bar.max_value = float(xp_to_next_level)
	xp_bar.value = 0.0
	xp_bar.show_percentage = false
	xp_bar.custom_minimum_size = Vector2(0.0, 20.0)
	layout.add_child(xp_bar)

	happiness_label = Label.new()
	happiness_label.text = "Happiness 0%"
	_apply_menu_label_style(happiness_label, 20)
	happiness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(happiness_label)

	happiness_bar = ProgressBar.new()
	happiness_bar.min_value = 0.0
	happiness_bar.max_value = float(HAPPINESS_MAX)
	happiness_bar.value = float(happiness)
	happiness_bar.show_percentage = false
	happiness_bar.custom_minimum_size = Vector2(0.0, 20.0)
	layout.add_child(happiness_bar)

	objective_label = Label.new()
	objective_label.text = ""
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_menu_label_style(objective_label, 18)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(objective_label)

	var powerup_title := Label.new()
	powerup_title.text = "Power Ups"
	powerup_title.add_theme_font_override("font", MENU_TITLE_FONT)
	powerup_title.add_theme_font_size_override("font_size", 28)
	powerup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(powerup_title)

	powerup_list = VBoxContainer.new()
	powerup_list.add_theme_constant_override("separation", 6)
	layout.add_child(powerup_list)

	_create_search_panel()

func _create_search_panel() -> void:
	search_panel = PanelContainer.new()
	search_panel.name = "SearchDeckPanel"
	search_panel.visible = false
	search_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	search_panel.anchor_left = 0.5
	search_panel.anchor_top = 0.5
	search_panel.anchor_right = 0.5
	search_panel.anchor_bottom = 0.5
	search_panel.offset_left = -330.0
	search_panel.offset_top = -285.0
	search_panel.offset_right = 330.0
	search_panel.offset_bottom = 285.0
	search_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(search_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	search_panel.add_child(layout)

	var title := Label.new()
	title.text = "Search Deck"
	title.add_theme_font_override("font", MENU_TITLE_FONT)
	title.add_theme_font_size_override("font_size", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 390.0)
	layout.add_child(scroll)

	search_list = GridContainer.new()
	search_list.columns = 3
	search_list.add_theme_constant_override("h_separation", 8)
	search_list.add_theme_constant_override("v_separation", 8)
	scroll.add_child(search_list)

	var cancel_button := _create_menu_button("Cancel")
	cancel_button.pressed.connect(_hide_search_panel)
	layout.add_child(cancel_button)

func _gain_progression_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = BASE_XP_TO_LEVEL + (player_level - 1) * XP_GROWTH_PER_LEVEL
		_award_random_powerups()
		print("Level up: ", player_level)
	_sync_progression_hud()

func _award_random_powerups() -> void:
	var reward_count := randi_range(POWERUP_REWARD_MIN, POWERUP_REWARD_MAX)
	for i: int in range(reward_count):
		var available_powerups := _get_available_powerups()
		if available_powerups.is_empty():
			return
		var reward: Dictionary = available_powerups.pick_random().duplicate()
		powerup_inventory.append(reward)

func _get_available_powerups() -> Array[Dictionary]:
	var available_powerups: Array[Dictionary] = []
	for powerup: Dictionary in POWERUP_POOL:
		var powerup_id := str(powerup.get("id", ""))
		if powerup_id == "expand_hand" and bigger_hand_uses + _get_inventory_powerup_count("expand_hand") >= MAX_BIGGER_HAND_USES:
			continue
		available_powerups.append(powerup)
	return available_powerups

func _get_inventory_powerup_count(powerup_id: String) -> int:
	var count := 0
	for powerup: Dictionary in powerup_inventory:
		if str(powerup.get("id", "")) == powerup_id:
			count += 1
	return count

func _sync_progression_hud() -> void:
	if level_label != null:
		level_label.text = "Level " + str(player_level)
	if xp_label != null:
		xp_label.text = "XP " + str(current_xp) + " / " + str(xp_to_next_level)
	if xp_bar != null:
		xp_bar.max_value = float(xp_to_next_level)
		xp_bar.value = float(current_xp)
	if happiness_label != null:
		happiness_label.text = "Happiness " + str(happiness) + "%"
	if happiness_bar != null:
		happiness_bar.value = float(happiness)
	if objective_label != null:
		objective_label.text = _get_objective_text()
	_sync_powerup_buttons()

func _get_objective_text() -> String:
	if endless_mode:
		return "Endless mode"
	if game_over:
		return "Game over"
	if recovery_active:
		var remaining_cards: int = maxi(HAPPINESS_RECOVERY_CARDS - objective_cards_played, 0)
		var missing: int = maxi(recovery_target_happiness - happiness, 0)
		return "Recovery: +" + str(missing) + "% in " + str(remaining_cards) + " cards"
	var remaining_normal_cards: int = maxi(HAPPINESS_CHECK_CARDS - objective_cards_played, 0)
	var gained: int = happiness - objective_start_happiness
	var remaining_gain: int = maxi(HAPPINESS_CHECK_TARGET - gained, 0)
	return "Goal: +" + str(remaining_gain) + "% happiness in " + str(remaining_normal_cards) + " cards"

func _sync_powerup_buttons() -> void:
	if powerup_list == null:
		return
	for child: Node in powerup_list.get_children():
		child.queue_free()

	if powerup_inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Place cards to level up"
		_apply_menu_label_style(empty_label, 18)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		powerup_list.add_child(empty_label)
		return

	for index: int in range(powerup_inventory.size()):
		var powerup: Dictionary = powerup_inventory[index]
		var button := Button.new()
		button.text = str(powerup.get("label", "Power Up"))
		button.tooltip_text = str(powerup.get("description", ""))
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.custom_minimum_size = Vector2(0.0, 38.0)
		_apply_menu_button_style(button, 20)
		_register_interactive_control(button)
		button.pressed.connect(_activate_powerup.bind(index))
		powerup_list.add_child(button)

func _activate_powerup(index: int) -> void:
	if index < 0 or index >= powerup_inventory.size():
		return
	if is_placing:
		_cancel_placement()

	var powerup: Dictionary = powerup_inventory[index]
	var powerup_id := str(powerup.get("id", ""))
	var player_hand := _get_player_hand()
	var deck := _get_deck()
	var consumed := false

	match powerup_id:
		"redraw_hand":
			if player_hand != null and player_hand.has_method("discard_hand"):
				consumed = int(player_hand.discard_hand(true, deck)) > 0
		"search_deck":
			_show_search_panel(index)
			return
		"expand_hand":
			if player_hand != null and player_hand.has_method("increase_hand_limit"):
				player_hand.increase_hand_limit(1)
				bigger_hand_uses += 1
				consumed = true

	if consumed:
		_remove_powerup(index)

func _show_search_panel(powerup_index: int) -> void:
	var player_hand := _get_player_hand()
	if player_hand != null and player_hand.has_method("get_available_slots") and int(player_hand.get_available_slots()) <= 0:
		if player_hand.has_method("_show_hand_full_message"):
			player_hand.call("_show_hand_full_message")
		return

	var deck := _get_deck()
	if deck == null:
		return

	pending_search_powerup_index = powerup_index
	for child: Node in search_list.get_children():
		child.queue_free()

	for card_data: CardData in _get_unique_deck_cards(deck):
		var card_button := Button.new()
		card_button.text = _get_card_display_name(card_data)
		card_button.tooltip_text = "Add this card to your hand"
		card_button.mouse_filter = Control.MOUSE_FILTER_STOP
		card_button.custom_minimum_size = Vector2(190.0, 42.0)
		_apply_menu_button_style(card_button, 18)
		_register_interactive_control(card_button)
		card_button.pressed.connect(_finish_search_powerup.bind(card_data))
		search_list.add_child(card_button)

	search_panel.visible = true

func _finish_search_powerup(card_data: CardData) -> void:
	var player_hand := _get_player_hand()
	var deck := _get_deck()
	if player_hand == null or deck == null or not player_hand.has_method("add_card_data"):
		return

	if player_hand.add_card_data(card_data, deck.get_deck_position()):
		var used_powerup_index := pending_search_powerup_index
		_hide_search_panel()
		_remove_powerup(used_powerup_index)

func _hide_search_panel() -> void:
	if search_panel != null:
		search_panel.visible = false
	pending_search_powerup_index = -1

func _remove_powerup(index: int) -> void:
	if index < 0 or index >= powerup_inventory.size():
		return
	powerup_inventory.remove_at(index)
	_sync_progression_hud()

func _get_unique_deck_cards(deck: Node) -> Array[CardData]:
	var cards: Array[CardData] = []
	var seen := {}
	var raw_cards: Array = deck.get("deck_data")
	for raw_card: Variant in raw_cards:
		var card_data := raw_card as CardData
		if card_data == null:
			continue
		var key := _get_card_dedupe_key(card_data)
		if seen.has(key):
			continue
		seen[key] = true
		cards.append(card_data)
	return cards

func _get_card_dedupe_key(card_data: CardData) -> String:
	var texture_path := ""
	if card_data.texture != null:
		texture_path = str(card_data.texture.resource_path)
	return (str(card_data.card_id) + "|" + str(card_data.display_name) + "|" + texture_path).to_lower()

func _get_card_display_name(card_data: CardData) -> String:
	if card_data == null:
		return "Unknown Card"
	if not card_data.display_name.is_empty():
		return card_data.display_name
	if not card_data.card_id.is_empty():
		return card_data.card_id.capitalize()
	return "Card"

func _get_player_hand() -> Node:
	return get_tree().get_first_node_in_group("player_hand")

func _get_deck() -> Node:
	return get_tree().get_first_node_in_group("deck")

func _create_volume_slider(bus_name: String) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = _get_bus_volume_linear(bus_name)
	slider.value_changed.connect(_set_bus_volume.bind(bus_name))
	_register_interactive_control(slider)
	return slider

func _toggle_ingame_menu() -> void:
	if menu_panel == null:
		return
	menu_panel.visible = not menu_panel.visible
	if menu_blocker != null:
		menu_blocker.visible = menu_panel.visible
	if menu_panel.visible:
		_sync_resolution_option()

func _hide_ingame_menu() -> void:
	if menu_panel != null:
		menu_panel.visible = false
	if menu_blocker != null:
		menu_blocker.visible = false

func _show_menu_section(section: String) -> void:
	if menu_buttons_panel != null:
		menu_buttons_panel.visible = section == ""
	if settings_panel != null:
		settings_panel.visible = section == "settings"
	if controls_panel != null:
		controls_panel.visible = section == "controls"

func _on_resolution_selected(index: int) -> void:
	if index == 0:
		WindowModeHelper.set_fullscreen(false)
	elif index == 1:
		WindowModeHelper.set_fullscreen(true)
	_sync_resolution_option()

func _sync_resolution_option() -> void:
	if resolution_option == null:
		return
	resolution_option.select(1 if WindowModeHelper.is_fullscreen() else 0)

func _apply_menu_button_style(button: BaseButton, font_size: int) -> void:
	button.add_theme_color_override("font_color", MENU_FONT_COLOR)
	button.add_theme_font_override("font", MENU_BUTTON_FONT)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_stylebox_override("normal", _make_button_style(MENU_BUTTON_NORMAL))
	button.add_theme_stylebox_override("pressed", _make_button_style(MENU_BUTTON_PRESSED))
	button.add_theme_stylebox_override("hover", _make_button_style(MENU_BUTTON_HOVER))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _apply_menu_label_style(label: Label, font_size: int = 24) -> void:
	label.add_theme_color_override("font_color", MENU_FONT_COLOR)
	label.add_theme_font_override("font", MENU_BUTTON_FONT)
	label.add_theme_font_size_override("font_size", font_size)

func _make_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_right = 15
	style.corner_radius_bottom_left = 15
	style.shadow_color = MENU_BUTTON_HOVER
	style.shadow_size = 5
	return style

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.065, 0.075, 0.78)
	style.content_margin_left = 22.0
	style.content_margin_top = 18.0
	style.content_margin_right = 22.0
	style.content_margin_bottom = 18.0
	return style

func _get_bus_volume_linear(bus_name: String) -> float:
	var bus_id := AudioServer.get_bus_index(bus_name)
	if bus_id == -1 or AudioServer.is_bus_mute(bus_id):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_id))

func _set_bus_volume(value: float, bus_name: String) -> void:
	var bus_id := AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		return
	if is_zero_approx(value):
		AudioServer.set_bus_mute(bus_id, true)
		AudioServer.set_bus_volume_db(bus_id, -80.0)
		return
	AudioServer.set_bus_mute(bus_id, false)
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))

func _exit_game() -> void:
	get_tree().quit()

func _request_restart_game() -> void:
	if restart_confirm_dialog == null:
		_restart_game()
		return
	restart_confirm_dialog.popup_centered()

func _restart_game() -> void:
	_hide_ingame_menu()
	get_tree().reload_current_scene()

func _play_place_sfx() -> void:
	var music_manager: Node = get_node_or_null("/root/MusicManager")
	if music_manager:
		music_manager.call("play_place_sfx")

func _create_placeable_card(label: String, preview: Node3D, index: int) -> void:
	var column: int = index % CARD_COLUMNS
	var row: int = floori(float(index) / float(CARD_COLUMNS))
	var left: float = CARD_LEFT + column * (CARD_WIDTH + CARD_HORIZONTAL_GAP)
	var top: float = CARD_TOP + row * (CARD_HEIGHT + CARD_VERTICAL_GAP)

	var card: PanelContainer = PanelContainer.new()
	card.name = label.replace(" ", "") + "Card"
	card.offset_left = left
	card.offset_top = top
	card.offset_right = left + CARD_WIDTH
	card.offset_bottom = top + CARD_HEIGHT
	add_child(card)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 4)
	card.add_child(layout)

	var title: Label = Label.new()
	title.text = label
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	layout.add_child(title)

	var viewport_container: SubViewportContainer = SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(float(ICON_SIZE.x), float(ICON_SIZE.y))
	viewport_container.stretch = true
	layout.add_child(viewport_container)

	var viewport: SubViewport = SubViewport.new()
	viewport.size = ICON_SIZE
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)

	_add_mesh_icon_scene(viewport, preview)

	var click_target: Button = Button.new()
	click_target.name = label.replace(" ", "") + "Button"
	click_target.text = ""
	click_target.tooltip_text = "Place " + label
	click_target.flat = true
	click_target.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_target.pressed.connect(_start_placement.bind(preview))
	card.add_child(click_target)

func _add_mesh_icon_scene(viewport: SubViewport, preview: Node3D) -> void:
	var source_mesh_instance: MeshInstance3D = preview as MeshInstance3D
	if source_mesh_instance == null or source_mesh_instance.mesh == null:
		return

	var root: Node3D = Node3D.new()
	viewport.add_child(root)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = source_mesh_instance.mesh
	mesh_instance.material_override = source_mesh_instance.material_override
	mesh_instance.rotation_degrees = Vector3(-18.0, 35.0, 0.0)
	root.add_child(mesh_instance)

	var bounds: AABB = source_mesh_instance.mesh.get_aabb()
	var longest_axis: float = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	var icon_scale: float = 2.7 / maxf(longest_axis, 0.01)
	mesh_instance.scale = Vector3(icon_scale, icon_scale, icon_scale)
	mesh_instance.position = -bounds.get_center() * icon_scale

	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
	root.add_child(light)

	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0.0, 2.0, 4.2)
	camera.rotation_degrees = Vector3(-25.0, 0.0, 0.0)
	camera.fov = 34.0
	camera.current = true
	viewport.add_child(camera)

func get_mouse_3d_position() -> Vector3:
	var v = get_viewport()
	var cam = v.get_camera_3d()
	if not cam: return Vector3.ZERO
	
	var m_pos = v.get_mouse_position()
	var ray_o = cam.project_ray_origin(m_pos)
	var ray_d = cam.project_ray_normal(m_pos)
	var p = Plane(Vector3.UP, 0)
	var inter = p.intersects_ray(ray_o, ray_d)
	
	return inter if inter != null else Vector3.ZERO

func _get_snapped_mouse_position() -> Vector3:
	return hex_grid.snap_world_to_hex(get_mouse_3d_position())

func _select_object_under_mouse() -> bool:
	var clicked_object := _get_clicked_object()
	if clicked_object == null:
		_clear_selected_object()
		return false

	var cell: Vector2i = hex_grid.world_to_axial(clicked_object.global_position)
	if object_cells.has(cell):
		selected_object = object_cells[cell]
		selected_object_cell = cell
		_show_selected_hint(selected_object.name)
		print("object selected: ", selected_object.name)
		return true

	_clear_selected_object()
	return false

func _clear_selected_object() -> void:
	selected_object = null
	selected_object_cell = Vector2i.ZERO
	_hide_selected_hint()

func _delete_selected_object() -> void:
	if selected_object == null or not is_instance_valid(selected_object):
		print("no selected object to delete")
		return

	var cell: Vector2i = hex_grid.world_to_axial(selected_object.global_position)
	if object_cells.has(cell):
		object_cells.erase(cell)
	if object_kinds.has(cell):
		object_kinds.erase(cell)
	var happiness_key := _happiness_score_key(cell, PLACEMENT_OBJECT)
	if happiness_cell_scores.has(happiness_key):
		_change_happiness(-int(happiness_cell_scores[happiness_key]))
		happiness_cell_scores.erase(happiness_key)

	print("deleting: ", selected_object.name)
	selected_object.queue_free()
	selected_object = null
	print("selected object deleted")
	_hide_selected_hint()

func _get_clicked_object() -> Node3D:
	return _get_hovered_object()

func _get_hovered_object() -> Node3D:
	var viewport := get_viewport()
	var camera := viewport.get_camera_3d()
	if camera == null:
		return null

	var mouse_pos := viewport.get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var collider := result["collider"] as Node
	if collider == null:
		return null
	return _get_world_child_from_node(collider)

func _get_world_child_from_node(node: Node) -> Node3D:
	var current := node
	while current != null and current.get_parent() != world_node:
		current = current.get_parent()
	return current as Node3D

func _create_selected_hint_label() -> void:
	selected_hint_label = Label.new()
	selected_hint_label.text = ""
	selected_hint_label.visible = false
	selected_hint_label.position = Vector2(20, 390)
	selected_hint_label.add_theme_font_size_override("font_size", 24)
	add_child(selected_hint_label)

func _show_selected_hint(object_name: String) -> void:
	if selected_hint_label == null:
		return

	selected_hint_label.text = "Selected: " + object_name + "\nPress Delete to remove"
	selected_hint_label.visible = true

func _hide_selected_hint() -> void:
	if selected_hint_label != null:
		selected_hint_label.visible = false
