extends Area2D
class_name Attack

@export var DAMAGE: int
var field_time = 0

signal hit(body)

func _ready():
	body_entered.connect(_on_body_entered)
	if field_time:
		await get_tree().create_timer(field_time).timeout
		queue_free()


func start(pos: Vector2, dir: Vector2):
	position = pos
	look_at(dir)


func enable():
	set_deferred("monitoring", true)


func disable():
	set_deferred("monitoring", false)


func _on_body_entered(body):
	hit.emit(body)
	body.take_damage(DAMAGE)
