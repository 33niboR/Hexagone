extends Control

# 1. 这里用 $ 符号直接指向你的 3D 节点路径
@onready var preview_building = get_node("/root/Main/BuildPreview/building")
@onready var preview_water = get_node("/root/Main/BuildPreview/water")
@onready var preview_grass = get_node("/root/Main/BuildPreview/grasss")
@onready var world_node = get_node("/root/Main/World")

var is_placing: bool = false
var current_active_preview: Node3D = null 
var current_button: Button = null

# --- 按钮点这里 ---
func _on_building_pressed():
	print("--- Clicked Building! ---") # 如果没打印这行，说明信号断了
	start_placement(preview_building)

func _on_river_sea_pressed():
	print("--- Clicked Water! ---")
	start_placement(preview_water)

func _on_ground_pressed():
	print("--- Clicked Grass! ---")
	start_placement(preview_grass)

# --- 核心逻辑 ---
func start_placement(target_preview: Node3D):
	# 强制让父节点显示，子节点只显示选中的那个
	get_node("/root/Main/BuildPreview").show() 
	preview_building.hide()
	preview_water.hide()
	preview_grass.hide()
	
	is_placing = true
	current_active_preview = target_preview 
	current_active_preview.show() 
	
	current_button = get_viewport().gui_get_focus_owner()
	if current_button:
		current_button.hide()

func _process(_delta: float) -> void:
	if is_placing and current_active_preview:
		var target_pos = get_mouse_3d_position()
		current_active_preview.global_position = target_pos
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			place_it(target_pos)

func place_it(pos: Vector3):
	var new_obj = current_active_preview.duplicate()
	world_node.add_child(new_obj)
	new_obj.global_position = pos
	new_obj.show()
	
	is_placing = false
	current_active_preview.hide()
	if current_button:
		current_button.show()

func get_mouse_3d_position() -> Vector3:
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	if not camera: return Vector3.ZERO
	var mouse_pos = viewport.get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, 0)
	var intersection = plane.intersects_ray(ray_origin, ray_direction)
	return intersection if intersection != null else Vector3.ZERO
