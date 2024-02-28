extends Area2D
class_name Attack

@export var DURATION: float

func _ready():
	await get_tree().create_timer(DURATION).timeout
	queue_free()


func start(pos: Vector2, dir: Vector2):
	position = pos
	look_at(dir)
