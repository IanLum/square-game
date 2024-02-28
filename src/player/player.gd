extends CharacterBody2D

const SPEED = 300
const ATTACK_SLOW = 0.3
const ATTACK_TIME = 0.2

const MAX_CHARGE = 1.5
const CHARGE_TIME = 1
const CHARGE_SLOW = 0.5


@onready var red_attack = preload("res://src/player/red_attack.tscn")
@onready var attack_lag = $AttackLag
@onready var charge_bar = $AttackCharge

var charge = 0: set = _set_charge

func _set_charge(new_charge):
	charge = clamp(new_charge, 0, MAX_CHARGE)
	charge_bar.value = charge


func _ready():
	attack_lag.wait_time = ATTACK_TIME
	charge_bar.max_value = MAX_CHARGE


func _physics_process(delta):
	var speed_mod = 1
	
	if Input.is_action_pressed("utility") and charge != MAX_CHARGE:
		charge += MAX_CHARGE / CHARGE_TIME * delta
		speed_mod *= CHARGE_SLOW
	
	if !attack_lag.is_stopped():
		speed_mod *= ATTACK_SLOW
	
	var direction = Vector2(
		Input.get_axis("left", "right"), Input.get_axis("up", "down")
	).normalized()
	velocity = direction * SPEED * speed_mod
	move_and_slide()


func attack():
	if !attack_lag.is_stopped(): return
	attack_lag.start()
	var instance = red_attack.instantiate()
	instance.start(
		position,
		(get_global_mouse_position() - global_position).normalized(),
		1 + charge
	)
	charge = 0
	get_parent().add_child(instance)


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()
