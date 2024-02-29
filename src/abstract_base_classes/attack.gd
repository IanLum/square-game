extends Area2D
class_name Attack

@export var DAMAGE: int
var field_time = 0

func _ready():
	body_entered.connect(_on_body_entered)
	if field_time:
		await get_tree().create_timer(field_time).timeout
		queue_free()


func start(pos: Vector2, dir: Vector2):
	position = pos
	look_at(dir)


func _on_body_entered(body):
	body.take_damage(DAMAGE)
