# Generates a dungeon using RigidBody2D physics and Minimum Spanning Tree (MST).
#
# The algorithm works like so:
#
# 1. Spawns and spreads collision shapes around the game world using the physics engine.
# 2. Waits for the rooms to be in a more or less resting state.
# 3. Selects some main rooms for the level based on the average room size.
# 4. Creates a Minimum Spanning Tree graph that connects the rooms.
# 5. Adds back some connections after calculating the MST so the player doesn't need to backtrack.
extends Node2D

# Emitted when all the rooms stabilized.
signal rooms_placed

const Room := preload("Room.tscn")
const Enemy_scene := preload("res://Characters/enemies/Ghost.tscn")

var nodes: Dictionary
var nodesPosition : Dictionary
var nodeStone
var selectNode
var startNode
var endNode
var teleportNode
var route: Array = []
var i: int = 1
var enemieSpawn : Array = [Vector2(5000,5000),Vector2(-5000,5000),Vector2(-5000,-5000),Vector2(5000,-5000)]
# Maximum number of generated rooms.
@export var max_rooms : int#= 60
# Controls the number of paths we add to the dungeon after generating it,
# limiting player backtracking.
@export var reconnection_factor := 0.037 #0.025
@export var map_w := 200
@export var map_h := 200

var _rng := RandomNumberGenerator.new()
var _data := {}
var _path: AStar2D = null
var _sleeping_rooms := 0
var _mean_room_size := Vector2.ZERO
var _draw_extra := []

@onready var rooms: Node2D = $Rooms
@onready var level: TileMap = $Level
@onready var player: CharacterBody2D = $Player
@onready var rayCast: RayCast2D = $Player/RayCast2D
@onready var prompt: Label = $Player/Label
@onready var prompt2: Label = $Player/Label2
@onready var playerLight_1: PointLight2D = $Player/LightArea_1
@onready var playerLight_2: PointLight2D = $Player/LightArea_2
@onready var playerLight_3: PointLight2D = $Player/LightArea_3

@onready var line: Line2D = $ConnectionParticles
@onready var lineRoute: Line2D = $ConnectRoute

func _ready():
	_rng.randomize()
	await _generate()
	place_player()
	if GLOBAL.actualLevel == 1:
		$AspectMap.visible = true
		SceneTransition.hudPlayerLamp.visible = true
	
func _on_timer_timeout():
	print("ENEMY")
	var enemy = Enemy_scene.instantiate()
	enemy.position = SpiritConnectUtils.choose(enemieSpawn)
	add_child(enemy)
	
# Calld every time stabilizes (mode changes to RigidBody2D.FREEZE_MODE_STATIC).
#
# Once all rooms have stabilized it calcualtes a playable dungeon `_path` using the MST
# algorithm. Based on the calculated `_path`, it populates `_data` with room and corridor tile
# positions.
#
# It emits the "rooms_placed" signal when it finishes so we can begin the tileset placement.
func _on_Room_sleeping_state_changed(room: SpiritConnectRoom) -> void:
	room.modulate = Color.YELLOW
	_sleeping_rooms += 1
	if _sleeping_rooms < max_rooms:
		return

	var main_rooms := []
	var main_rooms_positions := []
	for child_room in rooms.get_children():
		if _is_main_room(child_room):
			main_rooms.push_back(child_room)
			main_rooms_positions.push_back(child_room.position)
			child_room.modulate = Color.RED

	_path = SpiritConnectUtils.mst(main_rooms_positions)

	queue_redraw()
	await get_tree().create_timer(1).timeout
	for point1_id in _path.get_point_ids():
		for point2_id in _path.get_point_ids():
			if (
				point1_id != point2_id
				and not _path.are_points_connected(point1_id, point2_id)
				and _rng.randf() < reconnection_factor
			):
				_path.connect_points(point1_id, point2_id)
				_draw_extra.push_back(
					[_path.get_point_position(point1_id), _path.get_point_position(point2_id)]
				)
#
	queue_redraw()
	for child_room in main_rooms:
		_add_room(child_room)
	_add_corridors()
#
	set_process(false)
	rooms_placed.emit()


# This is for visual feedback. We just re-render the rooms every frame.
func _process(_delta: float) -> void:
	level.clear()
	for room in rooms.get_children():
		for offset in room as SpiritConnectRoom:
			#level.set_cell(0, offset, 1, Vector2i.ZERO, 1)
			level.set_cell(0, offset, 0, Vector2i.ZERO, 0)
			###!!!!!!THE ARGUMENT 3 AND 5 IS THE TILE WHAT SET BE THE TILESET ID DEFINED

# This is for visual feedback. We draw red lines for the MST path, and green lines for
# the extra edges we re-add.
func _draw() -> void:
	if _path == null:
		return
	#print("ROUTE",route)
	#print(nodesPosition)
	if selectNode != null:
		line.clear_points()
		lineRoute.add_point(nodesPosition.get(selectNode))
		if GLOBAL.actualLevel != 1:
			for nconnect in nodes.get(selectNode):
				line.add_point(nodesPosition.get(selectNode))
				if (nconnect != null and nconnect.keys()[0] != route[i-2].keys()[0]):
					line.add_point(nodesPosition.get(nconnect.keys()[0]))
					#draw_line(nodesPosition.get(selectNode), nodesPosition.get(nconnect.keys()[0]), Color.ALICE_BLUE, 5)
		
	##!!PARTE PARA GENERAR NODO EN EL ROOM	
	var tilemap_transform := level.get_global_transform().affine_inverse()
	for point1_id in _path.get_point_ids():
		var point1_position := _path.get_point_position(point1_id)
		for point2_id in _path.get_point_connections(point1_id):
			var point2_position := _path.get_point_position(point2_id)
			###!!SET THE NODES IN THE MAP
			var tilemap_point1 := level.local_to_map(tilemap_transform.basis_xform(Vector2i(point1_position)))
			var tilemap_point2 := level.local_to_map(tilemap_transform.basis_xform(Vector2i(point2_position)))
			level.set_cell(2, tilemap_point1, 5, Vector2i.ZERO, 5)
			level.set_cell(2, tilemap_point2, 5, Vector2i.ZERO, 5)
			SpiritConnectUtils.add_variable_to_dict(tilemap_point1,point1_position,nodesPosition)
			SpiritConnectUtils.add_variable_to_dict(tilemap_point2,point2_position,nodesPosition)
			SpiritConnectUtils.add_variable_to_dict(tilemap_point1,[tilemap_point2,point1_position.distance_to(point2_position)],nodes)
			SpiritConnectUtils.add_variable_to_dict(tilemap_point2,[tilemap_point1,point2_position.distance_to(point1_position)],nodes)
	"""
	if not _draw_extra.is_empty():
		for pair in _draw_extra:
			draw_line(pair[0], pair[1], Color.GREEN, 20)
	"""
	


# Places the rooms and starts the physics simulation. Once the simulation is done
# ("rooms_placed" gets emitted), it continues by assigning tiles in the Level node.
func _generate() -> void:
	for _i in range(max_rooms):
		# Generate `max_rooms` rooms and set them up
		var room := Room.instantiate()
		room.sleeping_state_changed.connect(_on_Room_sleeping_state_changed.bind(room))
		room.setup(_rng, level)
		rooms.add_child(room)
		_mean_room_size += room.size
	_mean_room_size /= rooms.get_child_count()

	# Wait for all rooms to be positioned in the game world.
	await rooms_placed

	rooms.queue_free()
	# Draws the tiles on the `level` tilemap.
	level.clear()
	###!!!!!!
	
	
	for x in range(-100, map_w):
		for y in range(-100, map_h):
			#level.set_cell(1, Vector2i(x,y), 0, Vector2i.ZERO, 0)
			level.set_cell(0, Vector2i(x,y), 0, Vector2i.ZERO, 0)
	
	
	for point in _data:
		level.set_cell(1, point, randi_range(0, 3), Vector2i.ZERO, 1)
		###!!!IN THIS PART DRAW THE WALLS OR LIMITS OF THE ROOMS
		if level.get_cell_alternative_tile(1, Vector2i(point.x+1,point.y))!=1:
			level.set_cell(1, Vector2i(point.x+1,point.y), randi_range(6, 13), Vector2i.ZERO, 2)
			#if level.get_cell_alternative_tile(0, Vector2i(point.x+2,point.y))!=2:
			#	level.set_cell(0, Vector2i(point.x+2,point.y), 0, Vector2i.ZERO, 0)
					
		if level.get_cell_alternative_tile(1, Vector2i(point.x-1,point.y))!=1:
			level.set_cell(1, Vector2i(point.x-1,point.y), randi_range(6, 13), Vector2i.ZERO, 2)
			#if level.get_cell_alternative_tile(0, Vector2i(point.x-2,point.y))!=2:
			#	level.set_cell(0, Vector2i(point.x-2,point.y), 0, Vector2i.ZERO, 0)
			
		if level.get_cell_alternative_tile(1, Vector2i(point.x,point.y+1))!=1:
			level.set_cell(1, Vector2i(point.x,point.y+1), randi_range(6, 13), Vector2i.ZERO, 2)
			#if level.get_cell_alternative_tile(0, Vector2i(point.x,point.y+2))!=2:
			#	level.set_cell(0, Vector2i(point.x,point.y+2), 0, Vector2i.ZERO, 0)
			
		if level.get_cell_alternative_tile(1, Vector2i(point.x,point.y-1))!=1:
			level.set_cell(1, Vector2i(point.x,point.y-1), randi_range(6, 13), Vector2i.ZERO, 2)
			#if level.get_cell_alternative_tile(0, Vector2i(point.x,point.y-2))!=2:
			#	level.set_cell(0, Vector2i(point.x,point.y-2), 0, Vector2i.ZERO, 0)
# Adds room tile positions to `_data`.
func _add_room(room: SpiritConnectRoom) -> void:
	for offset in room:
		_data[offset] = null
	# FIXME: There's a weird bug: without the `print()` statement the project
	#        closes without warning.
	print()


# Adds both secondary room and corridor tile positions to `_data`. Secondary rooms are the ones
# intersecting the corridors.
func _add_corridors():
	# Stores existing connections in its keys.
	var connected := {}

	# Checks if points are connected by a corridor. If not, adds a corridor.
	for point1_id in _path.get_point_ids():
		for point2_id in _path.get_point_connections(point1_id):
			var point1 := _path.get_point_position(point1_id)
			var point2 := _path.get_point_position(point2_id)
			if Vector2(point1_id, point2_id) in connected:
				continue
			point1 = level.local_to_map(point1)
			point2 = level.local_to_map(point2)
			_add_corridor(point1.x, point2.x, point1.y, Vector2.AXIS_X)
			_add_corridor(point1.y, point2.y, point2.x, Vector2.AXIS_Y)

			# Stores the connection between point 1 and 2.
			connected[Vector2(point1_id, point2_id)] = null
			connected[Vector2(point2_id, point1_id)] = null

# Adds a specific corridor (defined by the input parameters) to `_data`. It also adds all
# secondary rooms intersecting the corridor path.
func _add_corridor(start: int, end: int, constant: int, axis: int) -> void:
	# mini / maxi seems to be crucial here
	var t = mini(start, end)
	while t <= maxi(start, end):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X:
				point = Vector2(t, constant)
			Vector2.AXIS_Y:
				point = Vector2(constant, t)

		t += 1
		for room in rooms.get_children():
			if _is_main_room(room):
				continue

			# you cannot mix Vector2i and Vector2 math anymore
			var top_left: Vector2 = level.local_to_map(room.position) as Vector2 - room.size / 2
			var bottom_right: Vector2 = level.local_to_map(room.position) as Vector2 + room.size / 2
			if (
				top_left.x <= point.x
				and point.x < bottom_right.x
				and top_left.y <= point.y
				and point.y < bottom_right.y
			):
				_add_room(room)
				t = bottom_right[axis]
		_data[point] = null


func _is_main_room(room: SpiritConnectRoom) -> bool:
	return room.size.x > _mean_room_size.x and room.size.y > _mean_room_size.y

###!!!!!CAMBIAR POSICIÓN DE PLAYER	
func place_player():
	#var roomsPos =  SpiritConnectUtils.choose(nodesPosition.keys())
	#var startPos = roomsPos
	var roomsPos =  SpiritConnectUtils.choose(nodesPosition.keys())
	teleportNode = roomsPos
	print("TELEPORT NODE",teleportNode)
	var flagResetExit = false
	for nm in nodes.keys():
		#if startNode == null or (nm.x >= startNode.x and (nm.y >= startNode.y or nm.y <= startNode.y)):
		if startNode == null or (nm.x >= startNode.x and nm.y >= startNode.y):
			startNode = nm
			#print("Inicio",startNode)	
	for nm in nodes.keys():
		#if endNode == null or (nm.x < endNode.x and (nm.y <= endNode.y or nm.y >= endNode.y)):
		if endNode == null or (nm.x <= endNode.x and nm.y <= endNode.y):
			endNode = nm
			#print("Final",endNode)
			
	#!!!!!CONEXIÓN DE TODOS LOS NODOS Y SUS DISTANCIAS ALEATORIAS
	nodes = SpiritConnectUtils.connect_nodes(nodes)
	for nodeA in nodes: #ITERAR EN LOS NODOS PRINCIPALES
		var nodesSearch = nodes.get(nodeA) #TOMAR LA ITERACION Y TRAER LOS CUATRO PARTES DEL PLANO
		for search in nodesSearch:
			if search != null:
				var nodesCatch = nodes.get(search.keys()[0])
				var change = nodesCatch.map(
					func(x):
						if(x != null): 
							if(x.keys()[0] == nodeA):
								return {x.keys()[0]:search.values()[0]}
							return x
						return null
						)
				nodes.merge({search.keys()[0]:change},true)
	print(nodes)
	queue_redraw()
	route.append({startNode:true})
	while route.find(endNode) != 1:
		var iteration = route[route.size()-1].keys()[0]
		var minor
		var keyAdd
		var found = false
		print(route)
		print(iteration)
		for next in nodes.get(iteration):
			found = false
			if next != null:
				if minor == null or next.values() <= minor:
					for k in route:
						if next.keys()[0] in k.keys():
							found = true
					if found == false:
						minor = next.values()
						keyAdd = next.keys()[0]
				if next.keys()[0] == endNode:
					keyAdd = next.keys()[0]
		###!!! keyAdd es null, es porque no hay caminos para conectar el inicio y final
		flagResetExit = false
		if keyAdd == null:
			break
		route.append({keyAdd:false})
		###!!!flagResetExit es para saber si ya existe el nodo se encuentra en el array, si es asi sale del loop
		###------------------
		for k in route:
			if endNode in k.keys():
				flagResetExit = true
		if flagResetExit == true:
			break
		###------------------
	if flagResetExit == false:
		print(get_tree().current_scene)
		SceneTransition.reload_scene()
		print("RESET")
	###------------------
	player.position = nodesPosition.get(startNode)
	selectNode = startNode
	await get_tree().create_timer(4).timeout
	player.speed = 350
	
func _physics_process(delta):
	nodeStone = Character_Player_RayCast.rotate_pointer(level,rayCast)
	if nodeStone in nodes:
		prompt.text = "Press E for connect magic stone, %s" %nodeStone
		for nconnect in nodes.get(route[i-1].keys()[0]):
			if nconnect != null and nconnect.keys()[0] == nodeStone:
				prompt2.text = "the power of conecction is %s" %nconnect.values()[0]
		if Input.is_action_just_pressed("Interact"):
			selectNode = nodeStone
			if i < route.size() and selectNode == route[i].keys()[0]:
				route[i] = {route[i].keys()[0]:true}
				i += 1
				queue_redraw()
				#randi() % 1000 WHEN INTERACT CONNECT THE NODE IF IS CORRECT, IF NOT IS CORRECT SHOW A MESSAGE AND SET A PENALTY
		elif route != null and i >= route.size():
			line.clear_points()
			SceneTransition.hudPlayerMessage.text = "Teleport node is %s" %teleportNode
			#prompt.text = "Press E for teleport"
			if selectNode == teleportNode:
				var packed_scene = preload("res://Levels/ConnectGenerator/SpiritConnectGenerator.tscn")
				SceneTransition.change_scene(packed_scene)
				print("NEW LEVEL")
	else:
		prompt.text=""
		prompt2.text=""

func _input(event)->void:
	pass
