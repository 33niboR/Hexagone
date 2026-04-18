extends Node3D

@export var move_speed: float = 20.0
@export var zoom_speed: float = 3.0
@export var smooth_weight: float = 0.1

var target_pos: Vector3
var target_zoom: float

func _ready():
	target_pos = global_position
	target_zoom = global_position.y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += zoom_speed
		target_zoom = clamp(target_zoom, 5.0, 40.0)

func _process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1
	if Input.is_key_pressed(KEY_S): input_dir.z += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		target_pos += input_dir.normalized() * move_speed * delta

	global_position.x = lerp(global_position.x, target_pos.x, smooth_weight)
	global_position.z = lerp(global_position.z, target_pos.z, smooth_weight)
	global_position.y = lerp(global_position.y, target_zoom, smooth_weight)
