extends Node2D

@onready var magic_circle_tp: Area2D = $magic_circle_tp_1/Area2D
var flag

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	flag = magic_circle_tp.get_overlapping_bodies()
	if flag:
		#self.get_tree().current_scene.queue_free()
		var packed_scene = preload("res://Levels/ConnectGenerator/SpiritConnectGenerator.tscn")
		SceneTransition.change_scene(packed_scene)
		#var instance = packed_scene.instantiate()
		#self.get_tree().root.add_child(instance)
		#get_tree().change_scene_to_packed(packed_scene)
	pass
