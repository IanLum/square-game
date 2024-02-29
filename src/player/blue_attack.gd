extends Attack

var SPEED: int

func _physics_process(delta):
	position += direction * SPEED * delta
