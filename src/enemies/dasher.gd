extends Enemy

const DASH_SPEED = 600
const Attack_Time = {
	WINDUP = 0.5,
	DURATION = 0.3,
	ENDLAG = 0.8
}

@onready var dash_timer = $DashTimer

func attack():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.WHITE, Attack_Time.WINDUP)
	await tween.finished
	$ColorRect.color = Color.MAGENTA
	
	var dir = to_local(player.global_position).normalized()
	velocity = dir * DASH_SPEED
	dash_timer.start(Attack_Time.DURATION)
	await dash_timer.timeout
	
	endlag()


func endlag():
	velocity = Vector2.ZERO
	await get_tree().create_timer(Attack_Time.ENDLAG).timeout
	attacking = false


func _physics_process(delta):
	super(delta)
	if not dash_timer.is_stopped():
		move_and_collide(velocity * delta)


func _on_attack_box_body_entered(body: Player):
	dash_timer.stop()
	endlag()
	body.take_damage()
