extends CharacterBody2D
class_name Enemy

@export var SPEED = 200

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var re_nav_timer: Timer = $NavigationAgent2D/Timer
@onready var attack_radius: Area2D = $AttackRadius
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("player")

func _ready():
	re_nav_timer.timeout.connect(find_path)
	find_path()


func _physics_process(_delta):
	if !attack_radius.get_overlapping_bodies().is_empty():
		attack()
	else:
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = direction * SPEED
		move_and_slide()


func find_path():
	nav_agent.target_position = player.global_position


func attack():
	pass
