extends CharacterBody2D
class_name Player

const MAX_HEALTH = 5
const SPEED = 300

const RED_ATTACK = {
	SLOWDOWN = 0.3,
	DURATION = 0.2,
	FIELD_TIME = 0.1
}

const BLUE_ATTACK = {
	SLOWDOWN = 0.3,
	DURATION = 0.4,
	SPEED = 300,
	FIELD_TIME = 0.5
}

const CHARGE = {
	MAX = 1.5,
	SLOWDOWN = 0.5,
	DURATION = 1.0
}

const DASH = {
	SPEEDUP = 2,
	DURATION = 0.2,
	COOLDOWN = 0.4
}

@onready var red_attack_scene = preload("res://src/player/red_attack.tscn")
@onready var blue_attack_scene = preload("res://src/player/blue_attack.tscn")
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
	charge = clamp(new_charge, 0, CHARGE.MAX)
	charge_bar.value = charge


## --- CORE FUNCTIONS ---


func _ready():
	attack_lag.wait_time = RED_ATTACK.DURATION
	charge_bar.max_value = CHARGE.MAX


func _physics_process(delta):
	var charging = handle_charge(delta)
	handle_movement(charging)


## --- INPUT HANDLING ---


func handle_charge(delta) -> bool:
	if blue_mode: return false
	if Input.is_action_pressed("utility") and charge != CHARGE.MAX:
		charge += CHARGE.MAX / CHARGE.DURATION * delta
		return true
	return false


func calculate_speed(charging: bool) -> float:
	var speed = SPEED
	if charging:
		speed *= CHARGE.SLOWDOWN
	if !attack_lag.is_stopped():
		speed *= RED_ATTACK.SLOWDOWN
	if !dash_timer.is_stopped():
		speed *= DASH.SPEEDUP
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
	if blue_mode: blue_attack()
	else: red_attack()


func red_attack():
	attack_lag.start(RED_ATTACK.DURATION)
	var instance = spawn_attack(
		red_attack_scene,
		RED_ATTACK.FIELD_TIME
	)
	print(instance)
	instance.resize(1 + charge)
	charge = 0
	get_parent().add_child(instance)


func blue_attack():
	attack_lag.start(BLUE_ATTACK.DURATION)
	var instance = spawn_attack(
		blue_attack_scene,
		BLUE_ATTACK.FIELD_TIME
	)
	instance.SPEED = BLUE_ATTACK.SPEED
	get_parent().add_child(instance)


func spawn_attack(scene: PackedScene, field_time: float) -> Attack:
	var instance: Attack = scene.instantiate()
	instance.start(
		position,
		(get_global_mouse_position() - global_position).normalized()
	)
	instance.field_time = field_time
	return instance


func dash():
	if !dash_cd.is_stopped(): return
	set_collision_mask_value(3, false)
	modulate = Color(1,1,1,0.2)
	dash_timer.start(DASH.DURATION)
	dash_cd.start(DASH.DURATION + DASH.COOLDOWN)
	
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
