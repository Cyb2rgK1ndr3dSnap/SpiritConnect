extends CharacterBody2D
class_name Character_Player

#var AttackTimer = preload("/root/World/TimerAttack").instance()
var level = preload("res://Levels/ConnectGenerator/SpiritConnectGenerator.tscn")
@export var speed : float
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var raycast: RayCast2D = $RayCast2D
var node = Node2D.new()

var direction : Vector2 = Vector2.ZERO
	
func _ready():
	animation_tree.active = true
	await get_tree().create_timer(3).timeout
	collisionShape.disabled = false
	
func _process(delta):
	update_animation_parameters()
	#rotate_pointer()
	
func _physics_process(delta):
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	animation_tree["parameters/idle/blend_position"] = direction
	animation_tree["parameters/run/blend_position"] = direction

"""	
func rotate_pointer():
	if(Input.is_action_pressed("left") or 
		Input.is_action_pressed("right") or 
			Input.is_action_pressed("up") or
				Input.is_action_pressed("down")):
					raycast.target_position = direction * 50
					if(raycast.is_colliding()):
						var target = raycast.get_collider()
						print("OBJECT",target.local_to_map(target.get_global_transform().affine_inverse().basis_xform(raycast.get_collision_point())))
						#print(raycast.get_collision_point())
						#print(level.pack(node))
						#print("OBJECT",level.local_to_map(level.get_global_transform().affine_inverse().basis_xform(raycast.get_collision_point())))
"""
