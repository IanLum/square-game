extends Attack

var SPEED: int

func _physics_process(delta):
	position += direction * SPEED * delta


func _on_body_entered(body):
	body.marked = true
