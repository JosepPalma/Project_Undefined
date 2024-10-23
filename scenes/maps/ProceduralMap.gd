extends NavigationRegion3D

signal map_created

const TOP_WALL = 0
const RIGHT_WALL = 1
const LEFT_WALL = 2
const BOTTOM_WALL = 3
const GRID_SIZE = 5
const ROOM_SIZE = 10

@export var numRooms = 15
@export var numGems = 4

var positionGrid = [] # Grid of all possible positions
var openRooms = {} # Dictionary with every position next to an open room
var placedRooms = {} # Dictionary with every room placed

var spawnRoomScn = preload("res://scenes/maps/rooms/spawnRoom.tscn")
var roomScn = preload("res://scenes/maps/rooms/room.tscn")

var spawn
var firstRoom


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_grid()
	add_spawn()
	generate_map()
	add_gems()
	bake_navigation_mesh()
	add_monster()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Generates grid of size GRID_SIZE * Grid_SIZE with the room positons.
func generate_grid():
	var coordValue = (GRID_SIZE * (ROOM_SIZE / 2)) - (ROOM_SIZE / 2)
	var position = Vector3(-coordValue, 0, -coordValue)
	for z in GRID_SIZE:
		for x in GRID_SIZE:
			positionGrid.append(position)
			position.x += ROOM_SIZE
		position = Vector3(-coordValue, 0, position.z + ROOM_SIZE)


# Adds spawn scene to the map
func add_spawn():
	spawn = spawnRoomScn.instantiate()
	add_child(spawn)


# Generates map 
func generate_map():
	# Place spawn inside the gridmap
	var randPos = prepare_spawn()
	
	for i in numRooms:
		# Add new room
		var newRoom = roomScn.instantiate()
		add_child(newRoom)
		
		# Place new room
		var newRoomPos = openRooms.keys().pick_random()
		newRoom.position = positionGrid[newRoomPos]
		open_walls(newRoomPos, newRoom)
		
		# Prepare next iteration
		positionGrid[newRoomPos].y = -1 # Mark as occupied
		randPos = newRoomPos
		openRooms.erase(newRoomPos)
		check_room_boundaries(randPos)
		placedRooms[newRoomPos] = newRoom


# Spawn gems
func add_gems():
	placedRooms.erase(firstRoom)
	for i in numGems:
		var randRoom = placedRooms.keys().pick_random()
		placedRooms[randRoom].spawn_gem()
		placedRooms.erase(randRoom)


func add_monster():
	var randRoom = placedRooms.keys().pick_random()
	placedRooms[randRoom].spawn_monster()
	placedRooms.erase(randRoom)


# Selects next room's position and faces spawn room to the next room
func prepare_spawn():
	var spawnPos = get_randi(positionGrid.size())
	spawn.position = positionGrid[spawnPos]
	positionGrid[spawnPos].y = -1
	
	# Select next position and rotate spawn
	var newRoomPos = rotate_spawn(spawnPos)
	
	# Add new room
	var newRoom = roomScn.instantiate()
	add_child(newRoom)
	
	# Place new room
	newRoom.position = positionGrid[newRoomPos]
	newRoom.open_wall(openRooms[newRoomPos])
	positionGrid[newRoomPos].y = -1
	openRooms.clear()
	check_room_boundaries(newRoomPos)
	placedRooms[newRoomPos] = newRoom
	firstRoom = newRoomPos
	
	return newRoomPos


func rotate_spawn(spawnPos):
	check_room_boundaries(spawnPos) 
	var newRoomPos = openRooms.keys().pick_random()
	spawn.look_at(positionGrid[newRoomPos])
	
	return newRoomPos


func check_room_boundaries(roomPosition):
	# Top position
	var top = roomPosition - GRID_SIZE
	if roomPosition >= 5:
		if positionGrid[top].y != -1:
			openRooms[top] = BOTTOM_WALL
	# Right position
	var right = roomPosition + 1
	if roomPosition % GRID_SIZE != GRID_SIZE-1:
		if positionGrid[right].y != -1:
			openRooms[right] = LEFT_WALL
	# Left position
	var left = roomPosition - 1
	if roomPosition % GRID_SIZE != 0:
		if positionGrid[left].y != -1:
			openRooms[left] = RIGHT_WALL
	# Bottom position
	var bottom = roomPosition + GRID_SIZE
	if roomPosition <= 19:
		if positionGrid[bottom].y != -1:
			openRooms[bottom] = TOP_WALL


func open_walls(roomPos, room):
	room.open_wall(openRooms[roomPos])
	match openRooms[roomPos]:
		TOP_WALL:
			placedRooms[roomPos - GRID_SIZE].open_wall(BOTTOM_WALL)
		RIGHT_WALL:
			placedRooms[roomPos + 1].open_wall(LEFT_WALL)
		LEFT_WALL:
			placedRooms[roomPos - 1].open_wall(RIGHT_WALL)
		BOTTOM_WALL:
			placedRooms[roomPos + GRID_SIZE].open_wall(TOP_WALL)


func get_map_createion_check():
	print("pre-map_created")
	map_created.emit()
	print("map_created")


# Returns a random number within a range
func get_randi(range):
	return randi() % range
