extends Node3D
class_name HexGrid

const HEX_SIZE: float = 4.0 / sqrt(3.0)

func axial_to_world(q: int, r: int) -> Vector3:
	var x: float = HEX_SIZE * sqrt(3.0) * (q + r / 2.0)
	var z: float = HEX_SIZE * 1.5 * r
	return Vector3(x, 0.0, z)

func world_to_axial(world_position: Vector3) -> Vector2i:
	var q: float = ((sqrt(3.0) / 3.0) * world_position.x - (1.0 / 3.0) * world_position.z) / HEX_SIZE
	var r: float = ((2.0 / 3.0) * world_position.z) / HEX_SIZE
	return _round_axial(q, r)

func snap_world_to_hex(world_position: Vector3) -> Vector3:
	var axial: Vector2i = world_to_axial(world_position)
	return axial_to_world(axial.x, axial.y)

func _round_axial(q: float, r: float) -> Vector2i:
	var cube_x: float = q
	var cube_z: float = r
	var cube_y: float = -cube_x - cube_z

	var rounded_x: int = roundi(cube_x)
	var rounded_y: int = roundi(cube_y)
	var rounded_z: int = roundi(cube_z)

	var x_diff: float = absf(float(rounded_x) - cube_x)
	var y_diff: float = absf(float(rounded_y) - cube_y)
	var z_diff: float = absf(float(rounded_z) - cube_z)

	if x_diff > y_diff and x_diff > z_diff:
		rounded_x = -rounded_y - rounded_z
	elif y_diff > z_diff:
		rounded_y = -rounded_x - rounded_z
	else:
		rounded_z = -rounded_x - rounded_y

	return Vector2i(rounded_x, rounded_z)
