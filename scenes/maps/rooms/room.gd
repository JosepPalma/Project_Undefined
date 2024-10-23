extends Node3D

const TOP_WALL = 0
const RIGHT_WALL = 1
const LEFT_WALL = 2
const BOTTOM_WALL = 3

var gemScn = preload("res://scenes/items/gem.tscn")
var monsterScn = preload("res://scenes/entities/enemy/monster.tscn")

@onready var topWall = $TopWall
@onready var rightWall = $RightWall
@onready var leftWall = $LeftWall
@onready var bottomWall = $BottomWall

func spawn_monster():
	var monster = monsterScn.instantiate()
	add_child(monster)


func spawn_gem():
	var gem = gemScn.instantiate()
	add_child(gem)


func open_wall(wallId):
	match wallId:
		TOP_WALL:
			remove_child(topWall)
			topWall.queue_free()
		RIGHT_WALL:
			remove_child(rightWall)
			rightWall.queue_free()
		LEFT_WALL:
			remove_child(leftWall)
			leftWall.queue_free()
		BOTTOM_WALL:
			remove_child(bottomWall)
			bottomWall.queue_free()
