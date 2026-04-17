extends Control

const HexGrid = preload("res://project/scripts/grid/hex_grid.gd")
const CARD_WIDTH: float = 170.0
const CARD_HEIGHT: float = 150.0
const CARD_LEFT: float = 14.0
const CARD_TOP: float = 10.0
const CARD_HORIZONTAL_GAP: float = 12.0
const CARD_VERTICAL_GAP: float = 12.0
const CARD_COLUMNS: int = 2
const ICON_SIZE: Vector2i = Vector2i(154, 108)

const ADDITIONAL_PLACEABLES: Array[Dictionary] = [
	{
		"id": "house",
		"label": "House",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_home_A_blue.obj"
	},
	{
		"id": "castle",
		"label": "Castle",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_castle_blue.obj"
	},
	{
		"id": "market",
		"label": "Market",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/buildings/blue/building_market_blue.obj"
	},
	{
		"id": "forest",
		"label": "Forest",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/decoration/nature/trees_A_large.obj"
	},
	{
		"id": "mountain",
		"label": "Mountain",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/decoration/nature/mountain_A_grass_trees.obj"
	},
	{
		"id": "road",
		"label": "Road",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/tiles/roads/hex_road_A.obj"
	},
	{
		"id": "coast",
		"label": "Coast",
		"mesh_path": "res://KayKit_Medieval_Hexagon_Pack_1.0_FREE/Assets/obj/tiles/coast/hex_coast_A.obj"
	}
]

@onready var preview_building: Node3D = get_node("/root/Main/BuildPreview/building")
@onready var preview_river: Node3D = get_node("/root/Main/BuildPreview/river")
@onready var preview_grass: Node3D = get_node("/root/Main/BuildPreview/grass")
@onready var building_button: Button = get_node("/root/Main/card system/Control/building")
@onready var river_button: Button = get_node("/root/Main/card system/Control/river")
@onready var grass_button: Button = get_node("/root/Main/card system/Control/grass")
@onready var build_preview_node: Node3D = get_node("/root/Main/BuildPreview")
@onready var world_node: Node3D = get_node("/root/Main/World")
@onready var hex_grid: HexGrid = HexGrid.new()

var is_placing: bool = false
var current_active_model: Node3D = null 
var placeable_previews: Array[Node3D] = []

func _ready():
	building_button.hide()
	river_button.hide()
	grass_button.hide()

	placeable_previews.clear()
	placeable_previews.append(preview_building)
	placeable_previews.append(preview_river)
	placeable_previews.append(preview_grass)
	_create_placeable_card("Archery Range", preview_building, 0)
	_create_placeable_card("River Tile", preview_river, 1)
	_create_placeable_card("Grass Tile", preview_grass, 2)
	_create_additional_placeables()
	_hide_all_previews()


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
	current_active_model.show()
	
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()

func _process(_delta):
	if is_placing and current_active_model:
		var target_pos: Vector3 = _get_snapped_mouse_position()
		current_active_model.global_position = target_pos

func _unhandled_input(event):
	if not is_placing or not current_active_model:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_item(current_active_model.global_position)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
			get_viewport().set_input_as_handled()

func _place_item(pos: Vector3):
	if not current_active_model: return
	
	var new_item = current_active_model.duplicate()
	world_node.add_child(new_item)
	new_item.global_position = pos
	new_item.show()
	
	print("placement successful: ", current_active_model.name)
	_cancel_placement()

func _cancel_placement():
	is_placing = false
	_hide_all_previews() 
	current_active_model = null
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
		var mesh_resource: Resource = load(mesh_path)

		if not (mesh_resource is Mesh):
			push_warning("Placeable mesh failed to load: " + mesh_path)
			continue

		var preview: MeshInstance3D = MeshInstance3D.new()
		preview.name = id
		preview.mesh = mesh_resource as Mesh
		preview.scale = Vector3(2.0, 2.0, 2.0)
		build_preview_node.add_child(preview)
		placeable_previews.append(preview)

		_create_placeable_card(label, preview, index + 3)

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
