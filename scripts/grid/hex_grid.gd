extends Node3D
class_name HexGrid

const HEX_SIZE: float = 1.0

func axial_to_world(q: int, r: int) -> Vector3:
	var x := HEX_SIZE * sqrt(3.0) * (q + r / 2.0)
	var z := HEX_SIZE * 1.5 * r
	return Vector3(x, 0.0, z)
