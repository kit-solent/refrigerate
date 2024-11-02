class_name Portal extends Node2D

@export var pair:Portal

func _ready():
	#print(is_between(0, TAU/8, 7*TAU/8))
	#$line.points = [point_a, point_b]
	#$line.show()
	pass
	#pair
	#$sub_viewport.world_2d

func _process(delta: float):
	$marker_2d.global_position = get_global_mouse_position()
	set_view($marker_2d)
	pass

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
	print(big_angle)
	print(small_angle)
	print(diff)
	# this is the acute direction from small to big
	var direction = diff < TAU # true is clockwise and false is anticlockwise
	# this is the absolute angle between a and b
	var abs_diff = diff if direction else TAU - diff
	
	print("direction is")
	print(direction)
	if direction:
		# clockwise is just a standard check
		return small_angle < angle and angle < big_angle
	else:
		# anticlockwise only happens when the positive x axis is inside the angle
		print(angle)
		print(small_angle)
		print(big_angle)
		return angle < small_angle or angle > big_angle


# TODO: This needs finishing. Consider: https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm
func get_portal_line(line:PackedVector2Array, bounds:Rect2):
	"""
	returns the portion of the portal line that is inside the given bounds
	"""
	# remove all points where both the point and the points to either side of it are outside the bounds.
	# record all points that are outside but that have an adjacent point inside so that these can be moved
	# to the border.
	var points = []
	
	# move all out of bound points toward their previous point
	
	# compute the intersection points and use them in place of the out of bounds points.
	for i in range(len(points)):
		if bounds.has_point(points[i]):
			points.append(points[i])
		else:
			var in_point = points[i - 1] if i >= 1 else points[i + 1]
			
			var cast_point = get_cast_point(in_point, points[i], bounds)
			
			points.append(cast_point[0])
	
	
	
	return points

func set_view(target:Node):
	var global_bounds = get_viewport_rect()
	var bounds = Rect2(to_local(global_bounds.position), global_bounds.size)
	
	var viewport_top_left     = bounds.position
	var viewport_top_right    = viewport_top_left  + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = viewport_top_left  + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN  * bounds.size.y
	
	var target_pos = to_local(target.global_position)
	
	# the angles from the cast_point to the corners of the screen.
	var angle_tl = fix_angle(target_pos.angle_to_point(viewport_top_left))
	var angle_tr = fix_angle(target_pos.angle_to_point(viewport_top_right))
	var angle_bl = fix_angle(target_pos.angle_to_point(viewport_bottom_left))
	var angle_br = fix_angle(target_pos.angle_to_point(viewport_bottom_right))
	
	# get the points that make up the portal border.
	var portal_points = $line.points
	
	var cast_points = []
	var edges = []
	var angles = []
	for i in portal_points:
		var err = get_cast_point(target_pos, i, bounds)
		if err:
			return ERR_HELP
		cast_points.append(err[0])
		edges.append(err[1])
		angles.append(fix_angle(target_pos.angle_to_point(i)))
	
	# start the polygon with all the points that make up the portal line.
	var points = portal_points
	cast_points.reverse()
	points.append_array(cast_points)
	
	$view.polygon = points
	$line2.points = points

func get_cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	"""
	NOTE: target, cast_point, and bounds are all in local coords.
	target is the position from which the line is cast.
	cast_point is the point towards which the line is cast.
	"""
	if not bounds.has_point(target):
		printerr("Invalid arguments to get_cast_point, `target` must be inside the given bounds.")
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
	if angle_br < angle and angle <= angle_bl:
		edge = Vector2.DOWN # including bottom left 
		
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
		
	elif angle_bl < angle and angle <= angle_tl:
		edge = Vector2.LEFT # including top left
		
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
		
	elif angle_tl < angle and angle <= angle_tr:
		edge = Vector2.UP # including top right
		
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
		
		## NOTE: interesting point, some of the other theta calculations are just
		## the negative of their pair. This is actually the case here but TAU - angle
		## is equivalent and prevents negative results.
		
		distance = abs(dist)/tan(theta)
		
		intersect = Vector2((1 if dsign else -1) * distance, dist)
		
	elif angle > angle_tr or angle <= angle_br:
		edge = Vector2.RIGHT # including bottom right
		
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
	
	return [intersect, edge]
