extends Camera

const mouse_sensitivity = 0.005
const max_turn_speed = 0.3

onready var target_rotation = rotation

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _process(delta):
	target_rotation.x = clamp(target_rotation.x, -PI / 2, PI / 2)
	
	var prev_tilt = rotation.z
	rotation = rotation.linear_interpolate(target_rotation, 1 - pow(0.00000000000001, delta))
	rotation.z = lerp(prev_tilt, target_rotation.z, 1 - pow(0.001, delta))

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		target_rotation.x -= clamp(event.relative.y * mouse_sensitivity, -max_turn_speed, max_turn_speed)
		target_rotation.y -= clamp(event.relative.x * mouse_sensitivity, -max_turn_speed, max_turn_speed)
