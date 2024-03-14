extends CharacterBody2D
class_name Enemy

@export var SPEED: int
@export var MAX_HEALTH: int

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var re_nav_timer: Timer = $NavigationAgent2D/Timer
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("player")
@onready var marked_attack_scene: PackedScene = preload("res://src/player/marked_attack.tscn")

## Added in every instantiation of an enemy
@onready var color_rect: ColorRect = $ColorRect
@onready var mark: ColorRect = $Mark
#@onready var attack_radius: Area2D = $AttackRadius
@onready var attack_ray: RayCast2D = $AttackRay

@onready var DEFAULT_COLOR: Color = color_rect.color
@onready var health = MAX_HEALTH
var attacking = false
var marked = false: set = _set_marked


func _set_marked(new_marked):
	marked = new_marked
	mark.visible = marked


func _ready():
	re_nav_timer.timeout.connect(find_path)
	find_path()


func _physics_process(_delta):
	if attacking:
		return
	elif check_attack_ray():
		attacking = true
		attack()
	else:
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = direction * SPEED
		move_and_slide()


func check_attack_ray():
	attack_ray.rotation = global_position.angle_to_point(player.global_position)
	var col = attack_ray.get_collider()
	if col == null: return false
	return col.is_in_group("player")


func find_path():
	nav_agent.target_position = player.global_position


func attack():
	pass


func take_damage(damage: int):
	health -= damage
	if marked: detonate_mark()
	if health <= 0: die()
	var blink = 0.05
	for i in range(3):
		color_rect.color = Color.WHITE
		await get_tree().create_timer(blink).timeout
		color_rect.color = DEFAULT_COLOR
		await get_tree().create_timer(blink).timeout


func detonate_mark():
	var instance: Attack = marked_attack_scene.instantiate()
	instance.start(
		position,
		Vector2()
	)
	instance.field_time = 0.1
	get_parent().add_child(instance)


func die():
	queue_free()
