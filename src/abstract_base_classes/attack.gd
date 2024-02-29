extends Area2D
class_name Attack

@export var DURATION: float
@export var DAMAGE: int

func _ready():
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(DURATION).timeout
	queue_free()


func start(pos: Vector2, dir: Vector2):
	position = pos
	look_at(dir)


func _on_body_entered(body):
	body.take_damage(DAMAGE)
