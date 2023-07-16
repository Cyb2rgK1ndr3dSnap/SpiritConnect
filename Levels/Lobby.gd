extends Node2D

@onready var magic_circle_tp: Area2D = $magic_circle_tp_1/Area2D
@onready var prompt: Label = $Player/Label
var flag

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	flag = magic_circle_tp.get_overlapping_bodies()
	if flag:
		prompt.text = "Press E for go to forest"
		if Input.is_action_just_pressed("Interact"):
			var packed_scene = preload("res://Levels/ConnectGenerator/SpiritConnectGenerator.tscn")
			SceneTransition.change_scene(packed_scene)
	else:
		prompt.text = ""
	pass
