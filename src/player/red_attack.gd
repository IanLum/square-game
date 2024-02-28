extends Area2D


func _ready():
	await get_tree().create_timer(0.2).timeout
	queue_free()


func start(pos: Vector2, dir: Vector2):
	position = pos
	look_at(dir)
