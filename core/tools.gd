class_name Tools extends Node

func rect_to_polygon(rect:Rect2):
	"""
	Converts the given Rect2 to a polygon (PackedVector2Array)
	"""
	return PackedVector2Array([
		rect.position,
		rect.position + Vector2.RIGHT * rect.size.x,
		rect.end,
		rect.position + Vector2.DOWN * rect.size.y
	])

func wrap_slice(arr:Array, start:int, end:int):
	"""
	An Array slicing function that wraps arround and handles slicing backwards.
	Is both ends exclusive.
	"""
	var sliced = []
	var length = len(arr)
	
	while end < start:
		end += length
	
	# add 1 to start to make both ends exclusive.
	for i in range(start + 1, end):
		sliced.append(arr[i % length])
	
	return sliced

func angle_diff(angle_a:float, angle_b:float):
	"""
	Returns tha absolute difference between the two angles in radians.
	"""
	# ensure the angles are in the range 0 - TAU
	angle_a = fix_angle(angle_a)
	angle_b = fix_angle(angle_b)
	
	var max_angle = angle_a if angle_a > angle_b else angle_b
	var min_angle = angle_b if angle_a > angle_b else angle_a
	
	return max_angle - min_angle

func get_centre(points):
	"""
	Returns the centroid of the given points.
	This is the average of the points or the point in the centre of
	the points
	"""
	var centroid = Vector2.ZERO
	for i in points:
		centroid += i
	centroid /= len(points)
	
	return centroid

func merge_polygons(polygons:Array[PackedVector2Array]):
	"""
	Merges any adjacent or overlapping polygons into a single polygon.
	Returns an array of polygons.
	"""
	var merged_polygons = polygons.duplicate()
	var has_merged = true
	
	while has_merged:
		has_merged=false
		for i in range(len(merged_polygons)):
			for j in range(i+1, len(merged_polygons)):
				# try and merge the two polygons
				var merge_attempt = Geometry2D.merge_polygons(merged_polygons[i], merged_polygons[j])
				
				# check if the merge was a success
				if len(merge_attempt)==1:
					merged_polygons[i] = merge_attempt[0]
					merged_polygons.remove_at(j)
					has_merged = true
					break
			
			if has_merged:
				break
	
	return merged_polygons

func line_bounds(line:PackedVector2Array):
	"""
	Returns the smallest Rect2 that contains all points in `line`.
	This is the bounding box of `line`. If line is empty then return
	a zero size rect at the origin.
	"""
	if len(line)==0:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	
	# create a Rect2 centered on the first point in line with zero size
	var rect = Rect2(line[0], Vector2.ZERO)
	
	# expand the rect to include every point in the line.
	for i in line.slice(1):
		rect = rect.expand(i)
	
	return rect

func to_local_rect(node:CanvasItem, rect:Rect2):
	"""
	An implimentation of the to_local method for `Rect2`s. `node` is the node who's
	coordinate space will be used for the transformation. 
	"""
	return Rect2(node.to_local(rect.position), rect.size)

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
	if len(line)==0:
		return PackedVector2Array()
	
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
		var clipped_line = clip_line_segment(l[0], l[1], bounds)
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

func segment_line(line:PackedVector2Array):
	"""
	Returns an array of the segments of `line`.
	"""
	var segments = []
	
	for i in range(len(line)-1):
		segments.append(PackedVector2Array([line[i], line[i+1]]))
	
	return segments

func segment_lines(lines):
	"""
	Calls segment_line on all lines in `lines` and returns the results in a single array.
	"""
	var segments = []
	
	for i in lines:
		segments.append_array(segment_line(i))
	
	return segments

func cast_point(target:Vector2, point:Vector2, bounds:Rect2):
	"""
	Casts a line from target in the direction of cast_point and returns the point where it intersects with bounds.
	target must be within bounds.
	"""
	# TODO: Consider using similar triangles to write a better implimentation.
	
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
	var angle_down  = 1 * TAU/4
	var angle_left  = 2 * TAU/4
	var angle_up    = 3 * TAU/4
	
	# the angle from the target to the cast point.
	var angle = fix_angle(target.angle_to_point(point))
	
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

func cast_polygon(target:Vector2, start:Vector2, stop:Vector2, bounds:Rect2):
	"""
	Casts the line segment from `start` to `stop` against `bounds` from the perspective of `target` and returns the resulting polygon.
	Both `start` and `stop` must be inside the bounds but `target` may be outside
	"""
	# TODO: modify so that the start and stop points can be out of bounds and the polygon cast still works
	if not (has_point(bounds, start) and has_point(bounds, stop)):
		printerr("Invalid `line` in cast_polygon. Both points in `line` must be within the bounds.")
		return ERR_INVALID_PARAMETER
	
	# initialise the polygon with the line
	var polygon = PackedVector2Array([start, stop])
	
	# find the cast points and their edges
	var start_cast = cast_point(target, start, bounds)[0]
	var stop_cast  = cast_point(target, stop , bounds)[0]
	
	polygon.append(stop_cast)
	polygon.append_array(find_corners(stop, start, target, bounds))
	polygon.append(start_cast)
	
	return polygon

func cast_polygons(target:Vector2, line:PackedVector2Array, bounds:Rect2):
	var segments = segment_lines(clip_line(line, bounds))
	var polygons:Array[PackedVector2Array] = []
	
	for i in segments:
		polygons.append(cast_polygon(target, i[0], i[1], bounds))
	
	# TODO polygons = merge_polygons(polygons)
	
	return polygons

func find_corners(point1: Vector2, point2: Vector2, target:Vector2, bounds:Rect2, direction:bool = false):
	"""
	Find the appropriate corner coordinates based on the given edges, points, target, and bounds.
	This uses the target point to work out which direction the polygon is being cast and from there
	which corner points need to be included. If `direction` is true then the corners will be added in
	a clockwise order, otherwise an anticlockwise order will be used. 
	"""
	# determine the direction using cross products
	var cross = (point1 - target).cross(point2 - target)
	direction = cross > 0
	
	# the corners of the bounds.
	var bounds_tl = bounds.position
	var bounds_tr = bounds.position + Vector2.RIGHT * bounds.size.x
	var bounds_bl = bounds.position + Vector2.DOWN  * bounds.size.y
	var bounds_br = bounds.end
	
	# the angles from the target to the corners of the bounds.
	var angle_tl = fix_angle(target.angle_to_point(bounds_tl))
	var angle_tr = fix_angle(target.angle_to_point(bounds_tr))
	var angle_bl = fix_angle(target.angle_to_point(bounds_bl))
	var angle_br = fix_angle(target.angle_to_point(bounds_br))
	
	# the angles from the target to the points (same as the angles from the points to their intersects).
	var angle_a = fix_angle(target.angle_to_point(point1))
	var angle_b = fix_angle(target.angle_to_point(point2))
	
	var angles = [
		angle_br,
		angle_bl,
		angle_tl,
		angle_tr,
		angle_a,
		angle_b,
	]
	
	# sort the angles from smallest to largest so that they travel in a clockwise order.
	angles.sort()
	
	# move angle_a to the start of the array.
	angles = angles.slice(angles.find(angle_a)) + angles.slice(0, angles.find(angle_a))
	
	var chosen_angles
	if direction:
		# this is all the angles between a and b in a clockwise order.
		chosen_angles = angles.slice(1, angles.find(angle_b))
	else:
		# this is all the angles between a and b in an anticlockwise order.
		# take all the angles after b and then reverse their order
		chosen_angles = angles.slice(angles.find(angle_b) + 1)
		chosen_angles.reverse()
	
	# convert the chosen angles into corner positions
	var corners = []
	for i in chosen_angles:
		corners.append({
			angle_tl:bounds_tl,
			angle_tr:bounds_tr,
			angle_bl:bounds_bl,
			angle_br:bounds_br
		}[i])
	
	return corners

func transform_array(array:PackedVector2Array, transform:Vector2):
	"""
	Returns a PackedVector2Array with `transform` added to each element of `array:PackedVector2Array`
	"""
	var new = []
	for i in array:
		new.append(i + transform)
	
	return new

func visual_node(node:Node):
	"""
	Returns a visual reperesentation of the given node.
	"""
