extends Node2D

@export var SPAWN_TIME: int
@export var MONSTER: PackedScene

@onready var timer: Timer = $Timer

func _ready():
	timer.wait_time = SPAWN_TIME


func _on_timer_timeout():
	var instance = MONSTER.instantiate()
	add_child(instance)
