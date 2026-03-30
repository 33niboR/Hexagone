extends Control


@onready var preview_building = get_node("/root/Main/BuildPreview/building")
@onready var preview_river = get_node("/root/Main/BuildPreview/river")
@onready var preview_grass = get_node("/root/Main/BuildPreview/grass")
@onready var world_node = get_node("/root/Main/World")

var is_placing: bool = false
var current_active_model: Node3D = null 

func _ready():
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
		var target_pos = get_mouse_3d_position()
		current_active_model.global_position = target_pos
		
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_place_item(target_pos)
		
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_cancel_placement()

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

	if preview_building: preview_building.hide()
	if preview_river: preview_river.hide()
	if preview_grass: preview_grass.hide()

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
