class_name Tools extends Node

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
	
	# this is the acute direction from small to big
	var direction = diff < TAU # true is clockwise and false is anticlockwise
	# this is the absolute angle between a and b
	var abs_diff = diff if direction else TAU - diff
	
	if direction:
		# clockwise is just a standard check
		return small_angle < angle and angle < big_angle
	else:
		# anticlockwise only happens when the positive x axis is inside the angle
		return angle < small_angle or angle > big_angle

func get_cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	"""
	Casts a line from target in the direction of cast_point and returns the point where it intersects with bounds.
	target must be within bounds.
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
	var angle_tl = Core.tools.fix_angle(target.angle_to_point(viewport_top_left))
	var angle_tr = Core.tools.fix_angle(target.angle_to_point(viewport_top_right))
	var angle_bl = Core.tools.fix_angle(target.angle_to_point(viewport_bottom_left))
	var angle_br = Core.tools.fix_angle(target.angle_to_point(viewport_bottom_right))
	
	# the angles pointing directly up, down, left, and right.
	var angle_right = 0
	var angle_down  = 1 * TAU/4
	var angle_left  = 2 * TAU/4
	var angle_up    = 3 * TAU/4
	
	# the angle from the target to the cast point.
	var angle = Core.tools.fix_angle(target.angle_to_point(cast_point))
	
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

func clip_line_vrt(start:Vector2, stop:Vector2, upper_limit:float, lower_limit:float):
	"""
	Vertically clippes the line segment from start to stop against the upper and lower limits.
	Regardless of the input points the line segment will be returned from the top down.
	If the line segment does not lie within the limits return an empty PackedVector2Array
	"""
	# order the start and stop points vertically to ensure that start is above
	if start.y > stop.y:
		var temp = start
		start = stop
		stop = temp
	
	if stop.y < upper_limit or start.y > lower_limit:
		# if the line is entirly above or below the limit
		print("failing as entirly above or below limits")
		print(start)
		print(stop)
		print(upper_limit)
		print(lower_limit)
		print("END BLOCK")
		#
		#failing as entirly above or below limits
		#(-408, -400)
		#(720, -168)
		#0
		#648
		#END BLOCK
		#
		return PackedVector2Array()
	
	var dist
	if start.y < upper_limit:
		dist = (upper_limit - start.y)*(start.x - stop.x)/(stop.y - start.y)
		
		# replace the start point with the newly calculated one.
		start = Vector2(start.x + dist, upper_limit)
	
	if stop.y > lower_limit:
		dist = (stop.y - lower_limit)*(stop.x - start.x)/(stop.y - start.y)
		
		# replace the stop point with the newly calculated one.
		stop = Vector2(stop.x + dist, lower_limit)
	
	return PackedVector2Array([start, stop])

func clip_line_hor(start:Vector2, stop:Vector2, left_limit:float, right_limit:float):
	"""
	Vertically clippes the line segment from start to stop against the upper and lower limits.
	Regardless of the input points the line segment will be returned from the top down.
	If the line segment does not lie within the limits return an empty PackedVector2Array
	"""
	# order the start and stop points horizontally so that start is to the left
	if start.x > stop.x:
		var temp = start
		start = stop
		stop = temp
	
	if stop.x < left_limit or start.x > right_limit:
		# if the line is entirly to the left or right of the limit
		return PackedVector2Array()
	
	var dist
	if start.x < left_limit:
		dist = (left_limit - start.x)*(start.y - stop.y)/(stop.x - start.x)
		
		# replace the start point with the newly calculated one.
		start = Vector2(left_limit, start.y + dist)
	
	if stop.x > right_limit:
		dist = (stop.x - right_limit)*(stop.y - start.y)/(stop.x - start.x)
		
		# replace the stop point with the newly calculated one.
		stop = Vector2(right_limit, stop.y + dist)
	
	return PackedVector2Array([start, stop])

func clip_line(start:Vector2, stop:Vector2, bounds:Rect2):
	"""
	Returns the section of the given straight line that lies inside the given bounds.
	Returns an empty PackedVector2Array if the line is entirly outside the bounds.
	"""
	var clip
	
	# clip the line vertically
	clip = clip_line_vrt(start, stop, bounds.position.y, bounds.position.y + bounds.size.y)
	
	if len(clip)==0:
		print("vrt clip failed")
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	# clip the line horizontally
	clip = clip_line_hor(start, stop, bounds.position.x, bounds.position.x + bounds.size.x)
	
	if len(clip)==0:
		print("hor clip failed")
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	return PackedVector2Array([start, stop])
