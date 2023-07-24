extends CanvasLayer

@onready var playButton = $Menu_principal/VBoxContainer/Play
@onready var exitButton = $Menu_principal/VBoxContainer/Exit
@onready var hudPlayerLamp : TextureRect = $Player_HUD/TextureRect3
@onready var hudPlayerMessage : Label = $Player_HUD/Message

func main_scene()->void:
	$Menu_principal/VBoxContainer/Play.grab_focus()
	$Menu_principal.visible = true
	playButton.disabled = false
	playButton.connect("pressed",_onButtonPressedPlay)

func change_scene(packed_scene: PackedScene)->void:
	SceneTransition.hudPlayerMessage.text = ""
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
	#if error != OK:
	#	printerr("Failure!",error)
	#else:
	#	print("GOOD!",error)

func _onButtonPressedPlay():
	$Menu_principal.visible = false
	playButton.disabled = true
	var packed_scene = preload("res://Levels/Lobby.tscn")
	SceneTransition.change_scene(packed_scene)
