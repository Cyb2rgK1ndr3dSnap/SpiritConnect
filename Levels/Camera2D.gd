extends Camera2D

@export var target : Character_Player
@export var followSpeed : float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Aquí puedes realizar la inicialización o configuración adicional de la cámara si es necesario.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		position = lerp(position, target.position, followSpeed * delta)
		# Aquí puedes agregar cualquier otro código que desees ejecutar en cada cuadro.
