extends Area2D
class_name Attack

func _ready():
	await get_tree().create_timer(0.2).timeout
	queue_free()


func start(pos: Vector2, dir: Vector2, charge: float):
	position = pos
	look_at(dir)
	scale.x = charge
	
