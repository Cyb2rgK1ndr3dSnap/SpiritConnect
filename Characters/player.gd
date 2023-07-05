extends CharacterBody2D


@export var speed : float

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var collisionShape: CollisionShape2D = $CollisionShape2D

var direction : Vector2 = Vector2.ZERO
	
func _ready():
	animation_tree.active = true
	#await get_tree().create_timer(3).timeout
	collisionShape.disabled = false
	
func _process(delta):
	update_animation_parameters()
	
func _physics_process(delta):
	#velocity.x = MOVEMENT.get_axis().x * speed
	#velocity.y = MOVEMENT.get_axis().y * -speed
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
