extends Node

var direction : Vector2

func get_axis() -> Vector2:
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	return direction
