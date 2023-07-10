extends StaticBody2D
class_name MagicStone_1

@onready var animation_tree : AnimationTree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
