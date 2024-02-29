extends CharacterBody2D
class_name Player

const MAX_HEALTH = 5
const SPEED = 300
const ATTACK_SLOW = 0.3
const ATTACK_TIME = 0.2

const MAX_CHARGE = 1.5
const CHARGE_TIME = 1
const CHARGE_SLOW = 0.5

const DASH_SPEEDUP = 2
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.4

@onready var red_attack = preload("res://src/player/red_attack.tscn")
@onready var attack_lag = $Timers/AttackLag
@onready var dash_cd = $Timers/DashCooldown
@onready var dash_timer = $Timers/DashTimer
@onready var charge_bar = $AttackCharge

@onready var health = MAX_HEALTH: set = _set_health
var blue_mode: bool = false: set = _set_mode
var charge = 0: set = _set_charge


## --- SETTERS ---


func _set_health(new_health):
	health = clamp(new_health, 0, MAX_HEALTH)
	var hbox = $ui/ColorRect/HBoxContainer
	for i in hbox.get_child_count():
		hbox.get_child(i).visible = health > i


func _set_mode(mode):
	blue_mode = mode
	$ColorRect.color = Color.BLUE if blue_mode else Color.RED
	charge_bar.visible = !blue_mode


func _set_charge(new_charge):
	charge = clamp(new_charge, 0, MAX_CHARGE)
	charge_bar.value = charge


## --- CORE FUNCTIONS ---


func _ready():
	attack_lag.wait_time = ATTACK_TIME
	charge_bar.max_value = MAX_CHARGE


func _physics_process(delta):
	var charging = handle_charge(delta)
	handle_movement(charging)


## --- INPUT HANDLING ---


func handle_charge(delta) -> bool:
	if blue_mode: return false
	if Input.is_action_pressed("utility") and charge != MAX_CHARGE:
		charge += MAX_CHARGE / CHARGE_TIME * delta
		return true
	return false


func calculate_speed(charging: bool) -> float:
	var speed = SPEED
	if charging:
		speed *= CHARGE_SLOW
	if !attack_lag.is_stopped():
		speed *= ATTACK_SLOW
	if !dash_timer.is_stopped():
		speed *= DASH_SPEEDUP
	return speed


func handle_movement(charging: bool):
	var direction = Vector2(
		Input.get_axis("left", "right"), Input.get_axis("up", "down")
	).normalized()
	velocity = direction * calculate_speed(charging)
	move_and_slide()


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("swap_mode"):
		blue_mode = !blue_mode
	elif event.is_action_pressed("utility") and blue_mode:
		dash()


## --- ACTION FUNCTIONS ---


func attack():
	if !attack_lag.is_stopped(): return
	attack_lag.start()
	var instance: Attack = red_attack.instantiate()
	instance.start(
		position,
		(get_global_mouse_position() - global_position).normalized()
	)
	instance.resize(1 + charge)
	instance.field_time = 0.1
	charge = 0
	get_parent().add_child(instance)


func dash():
	if !dash_cd.is_stopped(): return
	set_collision_mask_value(3, false)
	modulate = Color(1,1,1,0.2)
	dash_timer.start(DASH_DURATION)
	dash_cd.start(DASH_DURATION + DASH_COOLDOWN)
	
	await dash_timer.timeout
	set_collision_mask_value(3, true)
	modulate = Color(1,1,1,1)


func take_damage(damage: int):
	if !dash_timer.is_stopped(): return
	health -= damage
	if health <= 0: die()
	
	Global.camera.shake(0.2, 5)
	var tween = create_tween()
	$ui/ScreenColor.color = Color(Color.RED, 0.3)
	tween.tween_property($ui/ScreenColor, "color", Color.TRANSPARENT, 0.3)


func die():
	get_tree().reload_current_scene()
