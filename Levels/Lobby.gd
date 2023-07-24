extends Node2D

@onready var magic_circle_tp_1: Area2D = $magic_circle_tp_1/Area2D
@onready var magic_circle_tp_2: Area2D = $magic_circle_tp_2/Area2D
@onready var prompt: Label = $Player/Label
var flag_1
var flag_2

# Called when the node enters the scene tree for the first time.
func _ready():
	SceneTransition.hudPlayerLamp.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	flag_1 = magic_circle_tp_1.get_overlapping_bodies()
	flag_2 = magic_circle_tp_2.get_overlapping_bodies()
	if flag_1:
		prompt.text = "Interact for go to forest"
		GLOBAL.actualLevel = GLOBAL.levelType.NORMAL
	elif flag_2:
		prompt.text = "Interact for go to dark forest"
		GLOBAL.actualLevel = GLOBAL.levelType.DARK
	else:
		prompt.text = ""
	
	if flag_1 || flag_2:
		if Input.is_action_just_pressed("Interact"):
			var packed_scene = preload("res://Levels/ConnectGenerator/SpiritConnectGenerator.tscn")
			SceneTransition.change_scene(packed_scene)
