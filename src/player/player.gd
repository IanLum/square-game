extends CharacterBody2D

const SPEED = 300
const ATTACK_SLOW = 0.3
const ATTACK_TIME = 0.2

@onready var red_attack = preload("res://src/player/red_attack.tscn")
@onready var attack_lag = $AttackLag

func _ready():
	attack_lag.wait_time = ATTACK_TIME

func _physics_process(_delta):
	var direction = Vector2(
		Input.get_axis("left", "right"), Input.get_axis("up", "down")
	).normalized()
	velocity = direction * SPEED
	if !attack_lag.is_stopped(): velocity *= ATTACK_SLOW
	move_and_slide()

func attack():
	if !attack_lag.is_stopped(): return
	attack_lag.start()
	var instance = red_attack.instantiate()
	instance.start(
		position,
		(get_global_mouse_position() - global_position).normalized()
	)
	get_parent().add_child(instance)

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()
