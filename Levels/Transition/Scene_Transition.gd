extends CanvasLayer

func change_scene(packed_scene: PackedScene)->void:
	$AnimationPlayer.play('dissolve')
	self.get_tree().current_scene.queue_free()
	#var packed_scene = preload(target)
	await $AnimationPlayer.animation_finished
	var instance = packed_scene.instantiate()
	get_tree().change_scene_to_packed(packed_scene)
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play_backwards('dissolve')
	
	
