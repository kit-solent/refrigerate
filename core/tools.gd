class_name Tools extends Node

func has_point(rect:Rect2, point:Vector2):
	"""
	Returns `true` if `point` is within or on the border of `rect`.
	"""
	# try a normal check and a check with the point moved in (up and left) one pixel.
	return rect.has_point(point) or rect.has_point(point - Vector2.ONE)

func fix_angle(angle:float):
	"""
	Forces angle to be positive.
	"""
	if angle < 0:
		angle += TAU
	
	return float(angle)

func are_colinear(points:PackedVector2Array):
	"""
	Returns `true` if the given points are colinear
	"""
	# lines with 0, 1, or 2 points are always colinear
	if len(points) < 3:
		return true
	
	var grad = (points[1].y - points[0].y)/(points[1].x - points[0].x)
	for i in range(len(points)-1):
		var new_grad = (points[i+1].y - points[i].y)/(points[i+1].x - points[i].x)
		if new_grad != grad:
			return false
	
	return true

func fix_line(line:PackedVector2Array):
	"""
	Removes any points that are colinear with their neibours from the line as they are redundant
	and have no effect on the shape of the line.
	"""
	var new = PackedVector2Array([line[0]])
	
	for i in range(1, len(line) - 1): # loop from the 2nd point to the 2nd to last point
		if not are_colinear(PackedVector2Array([line[i-1], line[i], line[i+1]])):
			new.append(line[i])
	
	# add the final point
	new.append(line[-1])
	
	return new

func is_between(angle:float, a:float, b:float):
	"""
	Returns true if `angle` is between the angles `a` and `b`.
	"""
	var big_angle = max(a, b)
	var small_angle = min(a, b)
	var diff = big_angle - small_angle
	
	# this is the acute direction from small to big
	var direction = diff < TAU # true is clockwise and false is anticlockwise
	
	if direction:
		# clockwise is just a standard check
		return small_angle < angle and angle < big_angle
	else:
		# anticlockwise only happens when the positive x axis is inside the angle
		return angle < small_angle or angle > big_angle

func clip_line_vrt(start:Vector2, stop:Vector2, upper_limit:float, lower_limit:float):
	"""
	Vertically clippes the line segment from start to stop against the upper and lower limits.
	Regardless of the input points the line segment will be returned from the top down.
	If the line segment does not lie within the limits return an empty PackedVector2Array
	"""
	# order the start and stop points vertically to ensure that start is above
	var flipped = false
	if start.y > stop.y:
		flipped = true
		var temp = start
		start = stop
		stop = temp
	
	if stop.y < upper_limit or start.y > lower_limit:
		return PackedVector2Array()
	
	var dist
	if start.y < upper_limit:
		dist = (upper_limit - start.y)*(start.x - stop.x)/(start.y - stop.y)
		
		# replace the start point with the newly calculated one.
		start = Vector2(start.x + dist, upper_limit)
	
	if stop.y > lower_limit:
		dist = (stop.y - lower_limit)*(stop.x - start.x)/(start.y - stop.y)
		
		# replace the stop point with the newly calculated one.
		stop = Vector2(stop.x + dist, lower_limit)
	
	return PackedVector2Array([stop, start] if flipped else [start, stop])

func clip_line_hor(start:Vector2, stop:Vector2, left_limit:float, right_limit:float):
	"""
	Vertically clippes the line segment from start to stop against the upper and lower limits.
	Regardless of the input points the line segment will be returned from the top down.
	If the line segment does not lie within the limits return an empty PackedVector2Array
	"""
	# order the start and stop points horizontally so that start is to the left
	var flipped = false
	if start.x > stop.x:
		flipped = true
		var temp = start
		start = stop
		stop = temp
	
	if stop.x < left_limit or start.x > right_limit:
		# if the line is entirly to the left or right of the limit
		return PackedVector2Array()
	
	var dist
	if start.x < left_limit:
		dist = (left_limit - start.x)*(start.y - stop.y)/(start.x - stop.x)
		
		# replace the start point with the newly calculated one.
		start = Vector2(left_limit, start.y + dist)
	
	if stop.x > right_limit:
		dist = (stop.x - right_limit)*(stop.y - start.y)/(start.x - stop.x)
		
		# replace the stop point with the newly calculated one.
		stop = Vector2(right_limit, stop.y + dist)
	
	return PackedVector2Array([stop, start] if flipped else [start, stop])

func clip_line_segment(start:Vector2, stop:Vector2, bounds:Rect2):
	"""
	Returns the section of the given straight line that lies inside the given bounds.
	Returns an empty PackedVector2Array if the line is entirly outside the bounds.
	"""
	var clip
	
	# clip the line vertically
	clip = clip_line_vrt(start, stop, bounds.position.y, bounds.position.y + bounds.size.y)
	if len(clip)==0:
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	# clip the line horizontally
	clip = clip_line_hor(start, stop, bounds.position.x, bounds.position.x + bounds.size.x)
	
	if len(clip)==0:
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	return PackedVector2Array([start, stop])

func clip_line(line:PackedVector2Array, bounds:Rect2):
	"""
	Returns the portion of the portal line that is inside the given bounds.
	This is an implimentation of the Cohen–Sutherland algorithm (https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm)
	modified for multi-point lines. Note that this function returns an array of lines as the portal clip could be composed
	of more than one line.
	"""
	# break the line into straight sections (two point lines) and store them in `lines`
	var lines:Array[PackedVector2Array] = []
	# temp is used to allow iterative editing of an array.
	var temp:Array[PackedVector2Array] = []
	
	# split the given line into it's segments.
	for i in range(len(line)-1): # NOTE: if len(line) is 0 range(-1) does the same as range(0) i.e. it doesn't loop.
		temp.append(PackedVector2Array([line[i], line[i+1]]))
	
	lines = temp
	temp = []
	
	# clip all the lines
	for l in lines:
		var clipped_line = Core.tools.clip_line_segment(l[0], l[1], bounds)
		if len(clipped_line) > 0:
			# only add the line if it contains points.
			# if it is empty then the clip must have been
			# a trivial reject.
			temp.append(clipped_line)
	
	lines = temp
	temp = []
	
	# line reconstruction requires lines to have a length greater than 0.
	# check if `lines` is empty and if so return an empty array of lines.
	if len(lines)==0:
		return [PackedVector2Array()]
	
	
	print(lines)
	# reconstruct the line from it's parts. The new_lines array starts with the first
	# point of the first line in clipped_lines (which is the first point of the total line)
	temp = [PackedVector2Array([lines[0][0]])]
	
	for i in range(len(lines)):
		if lines[i][0] != temp[-1][-1]:
			# if the first point of the new line is different to the last point of the
			# old line then the lines are seperate so initialise a new line.
			temp.append(PackedVector2Array([lines[i][0]]))
		# add the new point.
		temp[-1].append(lines[i][1])
	
	lines = temp
	temp = []
	
	# apply fix_line to each line
	for l in lines:
		temp.append(fix_line(l))
	
	lines = temp
	temp = []
	
	return lines

func cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	"""
	Casts a line from target in the direction of cast_point and returns the point where it intersects with bounds.
	target must be within bounds.
	"""
	if not has_point(bounds, target):
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

func cast_polygon(target:Vector2, line:PackedVector2Array, bounds:Rect2):
	"""
	Casts `line` against `bounds` from the perspective of `target` and returns the resulting polygon.
	The `target` point and all points in `line` must be inside the bounds.
	"""
	# ensure that target and all points of line are within the bounds
	if not has_point(bounds, target):
		printerr("Invalid `target` in cast_polygon. `target` must be within the bounds")
		return ERR_INVALID_PARAMETER
	
	for i in line:
		if not has_point(bounds, i):
			printerr("Invalid `line` in cast_polygon. All points in `line` must be within the bounds.")
			return ERR_INVALID_PARAMETER
	
	# initialise the polygon with the line
	var polygon = fix_line(line)
	
	# find all the cast points and their edges
	var cast_points = []
	for i in line:
		cast_points.append(cast_point(target, i, bounds))
	
	# reverse the cast points so that the cast point for the last point in line will get
	# connected to that last point. This ensures that the polygon runs in a consistant direction
	cast_points.reverse()
	
	# add the cast_points to the polygon and insert the corner points if required
	var prev_point = cast_points[0][0]
	var edge = cast_points[0][1] # initialise with the first edge to eusure that the first edge check return true
	for i in cast_points:
		if i[1] != edge:
			# if the edges are not the same then add the corner points.
			polygon += find_corner(edge, i[1], prev_point, i[0], target, bounds)
		
		polygon.append(i[0])
		
		# update the point
		prev_point = i[0]
	
	return polygon

func cast_polygons(target:Vector2, line:PackedVector2Array, bounds:Rect2):
	var lines = clip_line(line, bounds)
	var polygons = []
	for i in lines:
		polygons.append(cast_polygon(target, i, bounds))
	return polygons

func find_corner(edge1:Vector2, edge2:Vector2, point1: Vector2, point2: Vector2, target:Vector2, bounds:Rect2):
	# left up right down
	var corners = {
		Vector2.UP + Vector2.LEFT: PackedVector2Array([bounds.position]),
		Vector2.UP + Vector2.RIGHT: PackedVector2Array([bounds.position + Vector2.RIGHT * bounds.size.x]),
		Vector2.DOWN + Vector2.RIGHT: PackedVector2Array([bounds.end]),
		Vector2.DOWN + Vector2.LEFT: PackedVector2Array([bounds.position + Vector2.DOWN * bounds.size.y])
	}
	
	var left_limit   = bounds.position.x
	var right_limit  = bounds.position.x + bounds.size.x
	var top_limit    = bounds.position.y
	var bottom_limit = bounds.position.y + bounds.size.y
	
	var sorted = [edge1, edge2]
	sorted.sort()
	
	if edge1 + edge2 in corners:
		return corners[edge1 + edge2]
	elif sorted == [Vector2.UP, Vector2.DOWN]:
		# TODO BUG: This check means that some cases where the target is above a point of a portal that
		# is above them without being through the portal. This happens when the portal is on an angle.
		# a better method would work out which side of the line the target is on and use that.
		if target.x < point1.x and target.x < point2.x:
			# if the target is to the left of the points then return the right corners
			return corners[Vector2.RIGHT + Vector2.DOWN] + corners[Vector2.RIGHT + Vector2.UP]
		else:
			# otherwise return the left corners
			return corners[Vector2.LEFT + Vector2.DOWN] + corners[Vector2.LEFT + Vector2.UP]
	elif sorted == [Vector2.LEFT, Vector2.RIGHT]:
		if target.y > point1.y and target.y > point2.y:
			# if the target is below the points then return the upper corners
			return corners[Vector2.LEFT + Vector2.UP] + corners[Vector2.RIGHT + Vector2.UP]
		else:
			# otherwise return the lower
			return corners[Vector2.LEFT + Vector2.DOWN] + corners[Vector2.RIGHT + Vector2.DOWN]
	else:
		printerr("Failed to find a corner for the given edges.")
		return ERR_INVALID_PARAMETER

func transform_array(array:PackedVector2Array, transform:Vector2):
	"""
	Returns an array with `transform` added to each element of `array`
	"""
	var new = []
	for i in array:
		new.append(i + transform)
	
	return new
