extends TileMap

# Called when the node enters the scene tree for the first time.

func _unhandled_input(event):
	"""
	var mouse_pos = get_viewport().get_mouse_position()
	print(mouse_pos)
	var tile_pos = local_to_map(local_to_map(mouse_pos))
	print(tile_pos)
	"""
	#print(get_canvas_transform().origin + global_position)
	#print(local_to_map(get_global_transform().affine_inverse().basis_xform(get_canvas_transform().origin + global_position)))
	#set_cell(0, Vector2i(0,0), 1, Vector2i.ZERO, 1)
