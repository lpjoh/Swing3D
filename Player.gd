extends KinematicBody

var motion = Vector3()

const accel = 50
const gravity = 40

var ground_max_speed = 20
var air_max_speed = 70

var swing_point = null
var swing_radius = null

func _physics_process(delta):
	motion.y -= gravity * delta
	
	var motion_2d = Vector2(motion.x, motion.z).rotated($Camera.rotation.y)
	
	var movement_normal = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up"))
	
	motion_2d += movement_normal * accel * delta

	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			motion.y = 20
		
		if movement_normal.x == 0:
			motion_2d.x = decel(motion_2d.x, delta)
		if movement_normal.y == 0:
			motion_2d.y = decel(motion_2d.y, delta)
	
	var max_speed
	if is_on_floor():
		max_speed = ground_max_speed
	else:
		max_speed = air_max_speed
	
	var max_speed_squared = max_speed * max_speed
	
	if motion_2d.length_squared() > max_speed_squared:
		motion_2d = motion_2d.normalized() * max_speed
	
	motion_2d = motion_2d.rotated(-$Camera.rotation.y)
	motion = Vector3(motion_2d.x, motion.y, motion_2d.y)
	motion = move_and_slide(motion, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("swing"):
		if $Camera/RayCast.is_colliding():
			swing_point = $Camera/RayCast.get_collision_point()
			swing_radius = global_transform.origin.distance_to(swing_point)
	elif Input.is_action_just_released("swing"):
		swing_point = null
	
	if swing_point == null:
		$Camera/SwingLine.hide()
		$Camera.target_rotation.z = 0
	else:
		var point_difference = global_transform.origin - swing_point
		var point_distance = point_difference.length()
		
		var point_normal = point_difference.normalized()
		
		if point_distance > swing_radius:
			global_transform.origin = swing_point + point_normal * swing_radius
			motion = motion.slide(point_normal)
		
		$Camera/SwingLine.scale.z = $Camera/SwingLine.global_transform.origin.distance_to(swing_point)
		$Camera/SwingLine.look_at(swing_point, Vector3(0, 1, 0))
		$Camera/SwingLine.show()
		
		var tilt_scale = point_normal.dot(Vector3(1, 0, 0).rotated(Vector3(1, 0, 0), $Camera.rotation.x).rotated(Vector3(0, 1, 0), $Camera.rotation.y))
		$Camera.target_rotation.z = tilt_scale * PI / 8
	
	if $Camera/RayCast.is_colliding():
		$MeshInstance.global_transform.origin = $Camera/RayCast.get_collision_point()
		$MeshInstance.show()
	else:
		$MeshInstance.hide()

func decel(value, delta):
	return lerp(value, 0, 1 - pow(0.00001, delta))
