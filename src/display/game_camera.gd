extends Camera2D
class_name GameCamera

var shake_amount

@onready var timer: Timer = $ShakeTimer
var default_offset: Vector2 = offset

func _ready():
	Global.camera = self


func _process(_delta):
	offset = default_offset
	handle_shake()


func handle_shake():
	if not timer.is_stopped():
		var shake_offset = Vector2(randf_range(-1, 1) * shake_amount, randf_range(-1, 1) * shake_amount)
		offset += shake_offset


func shake(duration: float, amount: float):
	timer.start(duration)
	shake_amount = amount
