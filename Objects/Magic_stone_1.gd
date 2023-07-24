extends StaticBody2D
class_name MagicStone_1

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var stone_light: PointLight2D = $PointLight2D
@onready var stone_area: Area2D = $Area2D
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_light_body_entered(body):
	if (GLOBAL.actualLevel == 1):
		$StoneLight.enabled = true
		$AnimationPlayer.play("light")
		pass # Replace with function body.


func _on_area_light_body_exited(body):
	if (GLOBAL.actualLevel == 1):
		$AnimationPlayer.play_backwards("light")
		await $AnimationPlayer.animation_finished
		$StoneLight.enabled = false
		pass # Replace with function body.
