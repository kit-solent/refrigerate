extends Node2D

@export var point_a:Vector2 = 32 * Vector2.UP
@export var point_b:Vector2 = 32 * Vector2.DOWN

func _ready():
	print(rad_to_deg(Vector2.ZERO.angle_to_point(Vector2(1,-1))))
	print(rad_to_deg(Vector2.ZERO.angle_to_point(Vector2(1, 1))))
	print(rad_to_deg(Vector2.ZERO.angle_to_point(Vector2(-1, 1))))
	print(rad_to_deg(Vector2.ZERO.angle_to_point(Vector2(-1, -1))))

func _process(delta: float):
	if Input.is_action_just_pressed("debug key"):
		$marker_2d.global_position = get_global_mouse_position()
		set_view($marker_2d)

func set_view(target:Node):
	var target_pos = to_local(target.global_position)
	var viewport_rect = get_viewport_rect()
	
	# the coordinates of the corners of the viewport rectangle relative to our origin.
	var viewport_top_left = to_local(viewport_rect.position)
	var viewport_top_right = viewport_top_left + Vector2.RIGHT * viewport_rect.size.x
	var viewport_bottom_left = viewport_top_left + Vector2.DOWN * viewport_rect.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN * viewport_rect.size.y
	
	# if the target is to the left of the portal
	if target_pos.x < point_a.x:
		if -target_pos.angle_to_point(point_a) > point_a.angle_to_point(viewport_top_left):
			print("adding extra point")
	
	# if the target is to the right of the portal
	elif target_pos.x > point_a.x:
		pass
	
	# if the target is vertically aligned with the portal
	else:
		pass
	
	#
	#var points = [
		#Vector2(0,  height/2),
		#Vector2(0, -height/2)
	#]
	#
#
	#var theta_a = atan((target_pos.y + height/2) / -target_pos.x)
	#var theta_b = atan((target_pos.y - height/2) / -target_pos.x)
	#
	#var Ax = target_pos.x + distance * cos(theta_a)
	#var Ay = target_pos.y - distance * sin(theta_a)
	#
	#var Bx = target_pos.x + distance * cos(theta_b)
	#var By = target_pos.y - distance * sin(theta_b)
	#
	#points.append(Vector2(Ax, Ay) if Ay < By else Vector2(Bx, By))
	#points.append(Vector2(Bx, By) if Ay < By else Vector2(Ax, Ay))
	#
	#$view.polygon = points
	#$line_2d2.points = points

func get_cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	if not (bounds.has_point(target) and bounds.has_point(cast_point)):
		printerr("Invalid arguments to get_cast_point, both points must be inside the given bounds.")
		return ERR_INVALID_PARAMETER
	
	var angle = target.angle_to_point(cast_point)
	
	if angle:pass

func is_between(value:float, a:float, b:float):
	"""
	Returns true if `value` is between a and b inclusive of both a and b.
	"""
	pass
