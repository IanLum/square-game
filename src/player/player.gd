extends CharacterBody2D


const SPEED = 300

func _physics_process(_delta):
	var direction = Vector2(
		Input.get_axis("left", "right"), Input.get_axis("up", "down")
	).normalized()
	velocity = direction * SPEED
	move_and_slide()
