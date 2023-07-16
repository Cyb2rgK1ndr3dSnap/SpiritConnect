extends CanvasLayer

func change_scene(packed_scene: PackedScene)->void:
	$AnimationPlayer.play('dissolve')
	print(get_tree().current_scene)
	self.get_tree().current_scene.queue_free()
	await $AnimationPlayer.animation_finished
	var instance = packed_scene.instantiate()
	#self.get_tree().current_scene.add_child(instance)
	#self.get_tree().get_root().add_child(instance)
	get_tree().change_scene_to_packed(packed_scene)
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play_backwards('dissolve')
	
func reload_scene():
	var error = get_tree().reload_current_scene()
	if error != OK:
		printerr("Failure!",error)
	else:
		print("GOOD!",error)

