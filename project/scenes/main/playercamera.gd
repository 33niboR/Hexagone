extends Node3D

@export var move_speed: float = 20.0
@export var zoom_speed: float = 3.0
@export var rotate_speed: float = 2.0
@export var angle_speed: float = 1.0
@export var smooth_weight: float = 0.1


var default_pos: Vector3
var default_zoom: float
var default_rotation: float
var default_tilt: float

var target_pos: Vector3
var target_zoom: float
var target_rotation: float
var target_tilt: float

func _ready():

	default_pos = global_position
	default_zoom = global_position.y
	default_rotation = rotation.y
	default_tilt = rotation.x
	
	# 设置当前目标
	target_pos = default_pos
	target_zoom = default_zoom
	target_rotation = default_rotation
	target_tilt = default_tilt

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Block zoom when a UI panel is open (search deck, menu, game over)
			var controller := get_tree().get_first_node_in_group("placement_controller")
			if controller != null:
				var search_panel: Control = controller.get("search_panel")
				var menu_panel: Control = controller.get("menu_panel")
				var game_over_overlay: Control = controller.get("game_over_overlay")
				if (search_panel != null and search_panel.visible) \
					or (menu_panel != null and menu_panel.visible) \
					or (game_over_overlay != null and game_over_overlay.visible):
					return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += zoom_speed
		target_zoom = clamp(target_zoom, 5.0, 50.0)

func _process(delta):
	
	if Input.is_key_pressed(KEY_X):
		target_pos = default_pos
		target_zoom = default_zoom
		target_rotation = default_rotation
		target_tilt = default_tilt

	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1
	if Input.is_key_pressed(KEY_S): input_dir.z += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		target_pos += input_dir.rotated(Vector3.UP, rotation.y).normalized() * move_speed * delta

	if Input.is_key_pressed(KEY_Q):
		target_rotation += rotate_speed * delta
	if Input.is_key_pressed(KEY_E):
		target_rotation -= rotate_speed * delta
		
	if Input.is_key_pressed(KEY_R):
		target_tilt -= angle_speed * delta
	if Input.is_key_pressed(KEY_F):
		target_tilt += angle_speed * delta
	

	target_tilt = clamp(target_tilt, deg_to_rad(-85), deg_to_rad(35))

	global_position.x = lerp(global_position.x, target_pos.x, smooth_weight)
	global_position.z = lerp(global_position.z, target_pos.z, smooth_weight)
	global_position.y = lerp(global_position.y, target_zoom, smooth_weight)
	
	rotation.y = lerp_angle(rotation.y, target_rotation, smooth_weight)
	rotation.x = lerp_angle(rotation.x, target_tilt, smooth_weight)
