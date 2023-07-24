extends CharacterBody2D

@export var speed : float
@onready var animation_tree : AnimationTree = $AnimationTree

var player_chase = false
var player_vulnerable = false
var player = null
var direction : Vector2 = Vector2.ZERO

func _ready():
	$AnimationPlayer.play("appears")
	await $AnimationPlayer.animation_finished
	$AnimationLight.play("Light")
	animation_tree.active = true

func _process(delta):
	if (direction.x > -1 and direction.x < 1) and (direction.y > -1 and direction.y < 1):
		animation_tree["parameters/conditions/attack"] = true
		animation_tree["parameters/conditions/run"] = false
	else:
		animation_tree["parameters/conditions/attack"] = false
		animation_tree["parameters/conditions/run"] = true
	
	animation_tree["parameters/run/blend_position"] = Vector2(direction)

func _physics_process(delta):
	if player_chase:
		direction = (player.position - position)/speed
		position += direction

func _on_area_2d_body_entered(body):
	player = body
	player_chase = true
