extends Enemy

const DASH_SPEED = 600
const Attack_Time = {
	WINDUP = 0.5,
	DURATION = 0.3,
	ENDLAG = 0.8
}

@onready var dash_timer = $DashTimer
@onready var attack_box: Attack = $AttackBox

func _ready():
	super()
	attack_box.disable()


func attack():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color", Color.WHITE, Attack_Time.WINDUP)
	await tween.finished
	$ColorRect.color = Color.MAGENTA
	
	var dir = to_local(player.global_position).normalized()
	velocity = dir * DASH_SPEED
	dash_timer.start(Attack_Time.DURATION)
	attack_box.enable()
	await dash_timer.timeout
	
	endlag()


func endlag():
	attack_box.disable()
	velocity = Vector2.ZERO
	await get_tree().create_timer(Attack_Time.ENDLAG).timeout
	attacking = false


func _physics_process(delta):
	super(delta)
	if not dash_timer.is_stopped():
		move_and_collide(velocity * delta)


func _on_attack_box_hit(_body):
	dash_timer.stop()
	endlag()
