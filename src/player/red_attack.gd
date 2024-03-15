extends Attack

const SIZE = 50


func resize(charge: float):
	scale.x = charge * SIZE


func _on_body_entered(body):
	super(body)
	body.knockback(
		global_position.direction_to(body.global_position),
		600,
		0.05
	)
