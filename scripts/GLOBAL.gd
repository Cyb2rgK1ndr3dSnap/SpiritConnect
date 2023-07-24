extends Node

var actualLevel
var direction : Vector2
enum levelType {
	NORMAL,
	DARK}

func get_axis() -> Vector2:
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	return direction
