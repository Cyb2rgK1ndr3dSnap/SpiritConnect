extends RayCast2D
class_name Character_Player_RayCast

#@onready var level = get_node("/root/Levels/ConnectGenerator/SpiritConnectGenerator/Level")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_exception(owner)

func _physics_process(delta):
	if(Input.is_action_pressed("left") or 
		Input.is_action_pressed("right") or 
			Input.is_action_pressed("up") or
				Input.is_action_pressed("down")):
					target_position = Input.get_vector("left", "right", "up", "down").normalized() * 25

static func rotate_pointer(level: TileMap,raycast: RayCast2D):
	if(raycast.is_colliding()):
		var detected = raycast.get_collider()
		#print("AREA2D",level.local_to_map(level.get_global_transform().affine_inverse().basis_xform(detected.get_global_position())))
		#if detected is MagicStone_1:
		#	print(detected.name)
		return level.local_to_map(level.get_global_transform().affine_inverse().basis_xform(detected.get_global_position()))
		#return level.local_to_map(level.get_global_transform().affine_inverse().basis_xform(raycast.get_collision_point()))
