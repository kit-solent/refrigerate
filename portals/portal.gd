class_name Portal extends Node2D

@export var pair:Portal
@export var point_a:Vector2 = 32 * Vector2.UP
@export var point_b:Vector2 = 32 * Vector2.DOWN

func _ready():
	#$line.points = [point_a, point_b]
	#$line.show()
	pass
	#pair
	#$sub_viewport.world_2d

func _process(delta: float):
	if Input.is_action_just_pressed("debug key"):
		$marker_2d.global_position = get_global_mouse_position()
		set_view($marker_2d)

func fix_angle(angle:float):
	"""
	Forces angle to be positive.
	"""
	if angle < 0:
		angle += TAU
	
	return float(angle)

func is_between(angle:float, a:float, b:float):
	"""
	Returns true if `angle` is between the angles `a` and `b`.
	"""
	var big_angle = max(a, b)
	var small_angle = min(a, b)
	var diff = big_angle - small_angle
	if diff < TAU:pass
	

func set_view(target:Node):
	var global_bounds = get_viewport_rect()
	var bounds = Rect2(to_local(global_bounds.position), global_bounds.size)
	
	var viewport_top_left     = bounds.position
	var viewport_top_right    = viewport_top_left  + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = viewport_top_left  + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN  * bounds.size.y
	
	var target_pos = to_local(target.global_position)
	
	@warning_ignore("shadowed_variable")
	var point_a = $line.points[0] + $line.position
	@warning_ignore("shadowed_variable")
	var point_b = $line.points[1] + $line.position
	
	var cast_a = get_cast_point(target_pos, point_a, bounds)
	var cast_b = get_cast_point(target_pos, point_b, bounds)
	
	# the angles from the cast_point to the corners of the screen.
	var angle_tl = fix_angle(target_pos.angle_to_point(viewport_top_left))
	var angle_tr = fix_angle(target_pos.angle_to_point(viewport_top_right))
	var angle_bl = fix_angle(target_pos.angle_to_point(viewport_bottom_left))
	var angle_br = fix_angle(target_pos.angle_to_point(viewport_bottom_right))
	
	var angle_a = fix_angle(target_pos.angle_to_point(point_a))
	var angle_b = fix_angle(target_pos.angle_to_point(point_b))
	
	# find and record the larger and smaller of the angles and points.
	var angle1 # smaller
	var cast1
	var point1
	var angle2 # larger
	var cast2
	var point2
	if angle_a < angle_b:
		angle1 = angle_a
		cast1  = cast_a
		point1 = point_a
		
		angle2 = angle_b
		cast2  = cast_b
		point2 = point_b
	else:
		angle1 = angle_b
		cast1  = cast_b
		point1 = point_b
		
		angle2 = angle_a
		cast2  = cast_a
		point2 = point_a
		
	var points = [point1, cast1]
	
	var angles = {
		angle_br:viewport_bottom_right,
		angle_bl:viewport_bottom_left,
		angle_tl:viewport_top_left,
		angle_tr:viewport_top_right
	}
	
	# this is the angles from smallest to largest
	for a in angles:
		if angle1 < a and a < angle2:
			# if i is between angle1 and angle2
			points.append(angles[a])
			
	points.append_array([cast2, point2])
	
	$view.polygon = points

func get_cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	"""
	NOTE: target, cast_point, and bounds are all in local coords.
	target is the position from which the line is cast.
	cast_point is the point towards which the line is cast.
	"""
	if not (bounds.has_point(target) and bounds.has_point(cast_point)):
		printerr("Invalid arguments to get_cast_point, both points must be inside the given bounds.")
		return ERR_INVALID_PARAMETER
	
	# the coordinates of the corners of the viewport rectangle relative to our origin.
	var viewport_top_left     = bounds.position
	var viewport_top_right    = bounds.position  + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = bounds.position  + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = bounds.position  + Vector2.DOWN  * bounds.size.y + Vector2.RIGHT * bounds.size.x
	
	# the angles from the cast_point to the corners of the screen.
	var angle_tl = fix_angle(target.angle_to_point(viewport_top_left))
	var angle_tr = fix_angle(target.angle_to_point(viewport_top_right))
	var angle_bl = fix_angle(target.angle_to_point(viewport_bottom_left))
	var angle_br = fix_angle(target.angle_to_point(viewport_bottom_right))
	
	# the angles pointing directly up, down, left, and right.
	var angle_right = 0
	var angle_down  = 1 * TAU/4
	var angle_left  = 2 * TAU/4
	var angle_up    = 3 * TAU/4
	
	# the angle from the target to the cast point.
	var angle = fix_angle(target.angle_to_point(cast_point))
	
	# the edge which the line will intersect as a Vector2.
	# Vector2.UP reperesents the top edge, Vector2.RIGHT reperesents the right edge etc.
	var edge:Vector2
	
	# the point at which the line intersects the edge of the view.
	var intersect:Vector2
	
	# the distance from the target to the edge towards which it point.
	var dist:float
	# a variable used for internal right angle triangle calculations
	var theta:float
	# the distance from the target to the intersect point along the other angle to dist
	var distance:float
	# this reperesents the sign on distance. true is positive and false is negative.
	var dsign:bool
	
	# calculate which edge the line points towards based on the angle.
	# also calculate the point of intersection.
	if angle_br < angle and angle < angle_bl:
		edge = Vector2.DOWN
		
		# calculate the vertical distance from the target to the bottom edge.
		dist = viewport_bottom_left.y - target.y
		if angle < angle_down:
			# the angle is to the right of straight down.
			theta = TAU/4 - angle
			dsign = true
		elif angle >= angle_down:
			# the angle is to the left of or is straight down.
			theta = angle - TAU/4
			dsign = false
		
		distance = abs(dist) * tan(theta)
		
		intersect = Vector2((1 if dsign else -1) * distance, dist)
		
	elif angle_bl < angle and angle < angle_tl:
		edge = Vector2.LEFT
		
		# calculate the horrisontal distance from the target to the left edge.
		dist = viewport_top_left.x - target.x
		
		if angle < angle_left:
			# the angle is below straight left.
			theta = TAU/2 - angle
			dsign = true
		elif angle >= angle_left:
			# the angle is above or is straight left.
			theta = angle - TAU/2
			dsign = false
		
		distance = abs(dist) * tan(theta)
		
		intersect = Vector2(dist, (1 if dsign else -1) * distance)
		
	elif angle_tl < angle and angle < angle_tr:
		edge = Vector2.UP
		
		# calculate the vertical distance from the target to the top edge.
		dist = viewport_top_left.y - target.y
		
		if angle < angle_up:
			# the angle is to the left of straight up.
			theta = angle - TAU/2
			dsign = false
		elif angle >= angle_up:
			# the angle is to the right of or is straight up.
			theta = TAU - angle
			dsign = true
		
		## NOTE: interesting point some of the other theta calculations are just
		## the negative of their pair. This is actually the case here but TAU - angle
		## is equivalent and prevents negative results.
		
		distance = abs(dist)/tan(theta)
		
		intersect = Vector2((1 if dsign else -1) * distance, dist)
		
	elif (angle > angle_tr) or (angle < angle_br):
		edge = Vector2.RIGHT
		
		# calculate the horrisontal distance from the target to the right edge.
		dist = viewport_top_right.x - target.x
		
		## NOTE: This angle calculation is slightly different due to the 0 angle being in the middle of the range.
		if angle < angle_left:
			# the angle is below or is straight right.
			theta = angle
			dsign = true
		elif angle > angle_left:
			# the angle is above straight right.
			theta = TAU - angle
			dsign = false

		distance = abs(dist) * tan(theta)

		intersect = Vector2(dist, (1 if dsign else -1) * distance)
	
	# currently the intersect is relative to the target point so convert to local coords by adding the target point.
	intersect += target
	
	return intersect
