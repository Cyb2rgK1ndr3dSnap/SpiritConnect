extends Node

@export var radius: float #= 25.0
@export var speed: float #= 5.1

var rotation_vector = Vector2.ZERO
var parent_pos = Vector2.ZERO

func _ready():
	var parent = get_parent() as Sprite2D
	parent_pos = parent.position
	rotation_vector.x = radius
	
func _process(delta):
	rotation_vector = rotation_vector.rotated( delta * speed)
	get_parent().position = parent_pos + rotation_vector
