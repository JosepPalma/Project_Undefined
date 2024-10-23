extends Node

signal score_incremented

var gem_arr
var gem_position_arr = []


func _ready():
	randomize()
	get_gems()
	connect_signals()
	set_positions_array()


func get_gems():
	gem_arr = get_tree().get_nodes_in_group("Gems")


func connect_signals():
	for gem in gem_arr:
		gem.gem_scanned.connect(_on_gem_scanned)


func set_positions_array():
	for i in gem_arr.size():
		gem_position_arr.append(gem_arr[i].global_position)


# Selects a random gem and sends its position
# Avoids repeating the previous gem position storing its position as non selectable
func get_random_gem_position():
	var rand_gem_pos: int = randi() % (gem_position_arr.size())
	var aux = gem_position_arr[rand_gem_pos]
	#gem_position_arr[rand_gem_pos] = gem_position_arr[gem_position_arr.size() - 1]
	#gem_position_arr[gem_position_arr.size() - 1] = aux
	return aux


func _on_gem_scanned():
	print("Communicating scan")
	score_incremented.emit()
