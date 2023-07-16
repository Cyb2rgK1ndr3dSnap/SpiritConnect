class_name SpiritConnectUtils


const UNCERTAINTY := 0.01


static func get_rng_point_in_circle(rng: RandomNumberGenerator, radius: float) -> Vector2:
	return get_rng_point_in_ellipse(rng, radius, radius)


static func get_rng_point_in_ellipse(rng: RandomNumberGenerator, width: float, height: float) -> Vector2:
	# Get a random number in [0, 2PI].
	var t := 2 * PI * rng.randf()
	# Adding two random numbers allows us to get a uniform distribution of points in the ellipse.
	var u := rng.randf() + rng.randf()
	# Calculate a random factor in [0, 1].
	var r := 2 - u if u > 1 else u
	# Calculate the coordinates of the point in the ellipse.
	return r * Vector2(width * cos(t), height * sin(t))


# Tests for approximate equality between two `Vector2`, allowing you to specify an absolute
# error margin.
static func is_approx_equal(v1: Vector2, v2: Vector2, error: float = UNCERTAINTY) -> bool:
	return abs(v1.x - v2.x) < error and abs(v1.y - v2.y) < error


# Calculates the Minimum Spanning Tree (MST) for given points and returns an `AStar2D` graph
# using Prim's algorithm.
static func mst(points: Array) -> AStar2D:
	var out := AStar2D.new()
	# Start from an arbitrary point in the list of points
	out.add_point(out.get_available_point_id(), points.pop_back())

	# Loop through all points, erasing them as we connect them.
	while not points.is_empty():
		var current_position := Vector2.ZERO
		var min_position := Vector2.ZERO
		var min_distance := INF

		for point1_id in out.get_point_ids():
			# Compare each point added to the `Astar2D` graph
			# to each remaining point to find the closest one.
			var point1_position = out.get_point_position(point1_id)
			for point2_position in points:
				var distance: float = point1_position.distance_to(point2_position)
				if min_distance > distance:
					# We use the variables to store the coordinates of the closest point.
					# We have to loop over all points to ensure it's the closest.
					current_position = point1_position
					min_position = point2_position
					min_distance = distance

		# Connect the point closest to `current_position` with our new point.
		var point_id := out.get_available_point_id()
		out.add_point(point_id, min_position)
		out.connect_points(out.get_closest_point(current_position), point_id)
		points.erase(min_position)

	return out


static func index_to_xy(width: int, index: int) -> Vector2:
	return Vector2(index % width, index / width)

#######!!!!!!!!!!FUNCTION DE POSICIONAR JUGADOR EN MAPA
static func choose(choices):
	randomize()

	var rand_index = randi() % choices.size()
	return choices[rand_index]
	

static func add_variable_to_dict(key, value, my_dict):
	if key not in my_dict:
		my_dict[key] = value
	#	print("Variable added successfully.")
	#else:
	#	print("Value already exists. Not adding.")
		
static func connect_nodes(my_dict):
	var dict_connect: Dictionary
	for node in my_dict:
		var points = []
		var p1
		var p2
		points.resize(4)
		for nodes2 in my_dict:
			if(node != nodes2):
				p1 = Vector2(node).distance_to(Vector2(nodes2))
				if nodes2.x > node.x and nodes2.y > node.y:
					if points[3] == null or p1 < Vector2(node).distance_to(Vector2(points[3].keys()[0])) :
						points[3] = nodes2
						##################
						if(node != nodes2):
							if points[3] != null:
								points[3] = {nodes2:randi() % 1000}
				if nodes2.x < node.x and nodes2.y > node.y:
					if points[2] == null or p1 < Vector2(node).distance_to(Vector2(points[2].keys()[0])):
						points[2] = nodes2 
						##################
						if(node != nodes2):
							if points[2] != null:
								points[2] = {nodes2:randi() % 1000}
				if nodes2.y < node.y and nodes2.x < node.x:
					if points[1] == null or p1 < Vector2(node).distance_to(Vector2(points[1].keys()[0])):
						points[1] = nodes2 
						##################
						if(node != nodes2):
							if points[1] != null:
								points[1] = {nodes2:randi() % 1000}
				if nodes2.y < node.y and nodes2.x > node.x:
					if points[0] == null or p1 < Vector2(node).distance_to(Vector2(points[0].keys()[0])):
						points[0] = nodes2
						##################
						if(node != nodes2):
							if points[0] != null:
								points[0] = {nodes2:randi() % 1000}
			dict_connect[node]=points
	return dict_connect
	
	"""	
	for node in dict_connect:
		var nodesSearch = dict_connect.get(node)
		for search in nodesSearch:
			if search != null:
				print(node,"search",dict_connect.get(search.keys()[0]))
	"""
