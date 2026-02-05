@icon("res://assets/icons/tools.svg")
class_name Tools extends Node
## A collection of utility functions used by other parts
## of the Refrigerate game.

# Error code policy: When an error is caught by the code return the
# default/empty/smallest return value that fits the type and
# assert(false) after printing an error message. Don't return FAILED

func is_nth_frame(n:int = Core.nth_frame_default, force_0th_frame:bool = false):
	"""
	Returns true if the game is in its nth frame where n defaults to
	Core.nth_frame_default. Used to trigger debug prints in code that
	runs every frame (i.e. code called in _process) so that output is
	only generated once. n can be made larger to trigger debug code
	after initial loading that happens in the early frames, e.g. loading
	screens. If force_oth_frame is true then the frame count is taken
	directly from Engine.get_frames_drawn() and ignores the custom offset
	tool. This will only return true in debug mode (Core.debug == true)
	"""
	if not Core.debug:
		return false
	
	if force_0th_frame:
		return Engine.get_frames_drawn() == n
	else:
		return Engine.get_frames_drawn() - Core.nth_frame_offset == n

func print_nth(text, n:int = Core.nth_frame_default, force_0th_frame:bool = false):
	"""
	Print the message only if Core.tools.is_nth_frame(n, force_0th_frame) == true.
	This is equivalent to writing the following
	if Core.tools.is_nth_frame(n, force_0th_frame):
		print(text)
	"""
	if is_nth_frame(n, force_0th_frame):
		print(text)

func any(booleans:Array):
	"""
	Performs an or check on all booleans in the array. This function returns
	true if any value in the array is true and returs false only if all
	values are false. If any value cannot be interpreted as a boolean then idk.
	"""
	for i in booleans:
		if i:
			return true
	return false

func all(booleans:Array):
	"""
	Performs an and check on all booleans in the array. This function returns
	false if any value in the array is false and returs true only if all
	values are true. If any value cannot be interpreted as a boolean then idk.
	"""
	for i in booleans:
		if not i:
			return false
	return true

func chain_lt(values:Array, strict = true) -> bool:
	"""
	Represents a chained "less than" inequality of all the items in `values`.
	If `strict` is true then use a strict inequality and if false use a non-strict inequality.
	e.g. chain_lt([a, b, c, d]) => a < b < c < d
	If `values` has 1 or less item(s) then return FAILED
	"""
	if len(values) <= 1:
		printerr("chain_lt expects at least 2 arguments.")
		# stop the code for debugging
		assert(false)
		return false

	var val = values[0]
	for index in range(1, len(values)):
		var next_val = values[index]
		
		# each successive item should be bigger than the previous
		if strict:
			if not (next_val > val):
				return false
		else:
			if not (next_val >= val):
				return false
		
		# update the value
		val = next_val
	
	return true

func chain_gt(values:Array, strict = true):
	"""
	Represents a chained "greater than" inequality of all the items in `values`.
	If `strict` is true then use a strict inequality and if false use a non-strict inequality.
	e.g. chain_gt([a, b, c, d]) => a < b < c < d
	If `values` has 1 or less item(s) then return FAILED
	"""
	var values_copy = values.duplicate()
	values_copy.reverse()
	return chain_lt(values_copy, strict)

func polygon_to_line(polygon:PackedVector2Array) -> PackedVector2Array:
	"""
	Godot stores polygons as a list of points where the last is connected to the first
	so to find the border line of a polygon the first point must be appended to that 
	array. Lines don't automatically connect their end point to the start.
	See also line_to_polygon
	"""
	# don't modify the original
	polygon = polygon.duplicate()
	polygon.append(polygon[0])
	return polygon

func line_to_polygon(line:PackedVector2Array) -> PackedVector2Array:
	"""
	The bounding line for a polygon in Godot must include the start point again at the
	end in order to connect it up but polygons do this automatically so to convert a line
	into a polygon the last point must be removed.
	See also polygon_to_line
	"""
	if line[0] != line[-1]:
		printerr("Warning: in line_to_polygon the first and last points on the line are not equal so the line probably doesn't represent a closed polygon. Continuing anyway.")
	
	# don't modify the original
	line = line.duplicate()
	line.remove_at(-1)
	return line

func polygons_to_lines(polygons:Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	"""
	Calls polygon_to_line on each polygon in polygons returning the results in an array.
	"""
	var lines:Array[PackedVector2Array] = []
	for polygon in polygons:
		lines.append(polygon_to_line(polygon))
	return lines

func lines_to_polygons(lines:Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	"""
	Calls line_to_polygon on each polygon in polygons returning the results in an array.
	"""
	var polygons:Array[PackedVector2Array] = []
	for line in lines:
		lines.append(line_to_polygon(line))
	return polygons

func rect_to_polygon(rect:Rect2) -> PackedVector2Array:
	"""
	Converts the given Rect2 to a polygon (PackedVector2Array).
	Starts at the top left and adds points clockwise.
	"""
	return PackedVector2Array([
		rect.position,
		rect.position + Vector2.RIGHT * rect.size.x,
		rect.end,
		rect.position + Vector2.DOWN * rect.size.y
	])

func wrap_slice(arr:Array, start:int, end:int) -> Array:
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

func angle_diff(angle_a:float, angle_b:float) -> float:
	"""
	Returns tha absolute difference between the two angles in radians.
	"""
	# ensure the angles are in the range 0 - TAU
	angle_a = fix_angle(angle_a)
	angle_b = fix_angle(angle_b)
	
	var max_angle = angle_a if angle_a > angle_b else angle_b
	var min_angle = angle_b if angle_a > angle_b else angle_a
	
	return max_angle - min_angle

func get_centre(points:PackedVector2Array) -> Vector2:
	"""
	Returns the centroid of the given points.
	This is the average of the points or the point in the centre of
	the points
	"""
	var centroid = Vector2.ZERO
	for point in points:
		centroid += point
	centroid /= len(points)
	
	return centroid

func merge_polygons(polygons:Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	"""
	Merges any adjacent or overlapping polygons into a single polygon.
	Returns an array of polygons. Also removes redundant colinear points.
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
	
	# remove redundant points i.e. points that when removed don't change the
	# shape of the polygon
	var new_polygons:Array[PackedVector2Array] = []
	for polygon in merged_polygons:
		# decolinearise_line works just as well on polygons.
		new_polygons.append(decolinearise_line(polygon))
	
	return new_polygons

func line_bounds(line:PackedVector2Array) -> Rect2:
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

func to_local_rect(node:CanvasItem, rect:Rect2) -> Rect2:
	"""
	An implimentation of the to_local method for `Rect2`s. `node` is the node who's
	coordinate space will be used for the transformation.
	"""
	return Rect2(node.to_local(rect.position), rect.size)

func rect_has_point(rect:Rect2, point:Vector2) -> bool:
	"""
	Returns `true` if `point` is within or on the border of `rect`.
	"""
	# rect_has_point returns false if the point is on the right or bottom edges
	# so cannot be used. Manualy check all cases
	if point.x < rect.position.x:
		return false
	if point.x > rect.position.x + rect.size.x:
		return false
	if point.y < rect.position.y:
		return false
	if point.y > rect.position.y + rect.size.y:
		return false
	return true

func fix_angle(angle:float) -> float:
	"""
	Forces angle to be positive.
	"""
	while angle < 0:
		angle += TAU
	
	return float(angle)

func make_line_unique(line:PackedVector2Array):
	"""
	Remove any adjacent double up points from the array so that each point is distinct
	from its neibours.
	"""
	# Can't remove double up points if there is 1 or no points.
	if len(line) < 2:
		return line
	
	# start with just the first point
	var new = PackedVector2Array([line[0]])
	var prev_point = line[0]
	
	# loop from the 2nd to the last point adding as we go
	for index in range(1, len(line)):
		if line[index] == prev_point:
			continue
		else:
			new.append(line[index])
			prev_point = line[index]
	
	return new

func are_colinear(points:PackedVector2Array, ordered:bool = false, epsilon = 0.0000001) -> bool:
	"""
	Returns `true` if the given points are colinear, i.e. if they all lie on the same 1D
	line. `epsilon` is a slight error margin used in the cross product test.
	If `ordered` is false (default) then the method simply checks that all points occupy the
	same 1D line regardless of their order along that line. If true then the method returns
	false for points where traveling from the first to the last point would require a change
	of direction (even by 180°). This method begins by removing double up points (because
	direction is only deffined between distinct points).
	"""
	# make sure we don't edit the original array.
	points = make_line_unique(points.duplicate())
	
	# you need at least 3 points for them not to be trivially colinear.
	if len(points) < 3:
		return true
	
	# get the direction between the first and second points.
	var direction = points[1] - points[0]
	points.remove_at(0)
	
	for index in range(len(points)-1): # loop from the (new) first point to the 2nd to last point.
		# check that the angle between the pre-calculated direction and the new direction is sufficiently small.
		var new_direction = points[index + 1] - points[index]
		var angle = direction.angle_to(new_direction)
		
		var condition = abs(angle) < epsilon # strict test.
		
		# include the non-strict case
		if not ordered:
			condition = condition or (abs(abs(angle) - PI) < epsilon)
		
		if condition:
			# if the point passes the test then keep iterating.
			continue
		else:
			# if the vectors point in different directions then the array is not colinear
			return false
	
	return true

func decolinearise_line(line:PackedVector2Array) -> PackedVector2Array:
	"""
	Removes any points that are colinear with their neibours from the line as they are redundant
	and have no effect on the shape of the line. This method assumes that the last point of the
	line is connected to the first point and will remove end points if they are colinear with
	their wrapped neibours.
	"""
	if len(line) < 3:
		return line
	
	# start with only the first point of the line.
	var new = PackedVector2Array([line[0]])
	
	# add all the other points if they are not colinear with their neibours.
	for i in range(1, len(line) - 1): # loop from the 2nd point to the 2nd to last point
		# perform an ordered colinearity check. i.e. line[i] must be in
		# the middle of the other two for it to be redundant.
		if not are_colinear(PackedVector2Array([line[i-1], line[i], line[i+1]]), true):
			new.append(line[i])
	
	# add the final point
	new.append(line[-1])
	
	# check the first and last points
	if are_colinear(PackedVector2Array([new[-1], new[0], new[1]]), true):
		new.remove_at(0)
	if are_colinear(PackedVector2Array([new[-2], new[-1], new[0]]), true):
		# remove_at doesn't support negative indices.
		new.remove_at(new.size() - 1)
	
	return new

func is_between(angle:float, a:float, b:float) -> bool:
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

func clip_segment_vrt(start:Vector2, stop:Vector2, upper_limit:float, lower_limit:float) -> PackedVector2Array:
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

func clip_segment_hor(start:Vector2, stop:Vector2, left_limit:float, right_limit:float) -> PackedVector2Array:
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

func clip_line_segment(start:Vector2, stop:Vector2, bounds:Rect2) -> PackedVector2Array:
	"""
	Returns the section of the given straight line that lies inside the given bounds.
	Returns an empty PackedVector2Array if the line is entirly outside the bounds.
	"""
	var clip
	
	# clip the line vertically
	clip = clip_segment_vrt(start, stop, bounds.position.y, bounds.position.y + bounds.size.y)
	if len(clip)==0:
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	# clip the line horizontally
	clip = clip_segment_hor(start, stop, bounds.position.x, bounds.position.x + bounds.size.x)
	
	if len(clip)==0:
		return clip
	
	start = clip[0]
	stop = clip[1]
	
	return PackedVector2Array([start, stop])

func clip_line(line:PackedVector2Array, bounds:Rect2) -> Array[PackedVector2Array]:
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
	
	# apply decolinearise_line to each line
	for l in lines:
		temp.append(decolinearise_line(l))
	
	lines = temp
	temp = []
	
	return lines

func segment_line(line:PackedVector2Array) -> Array[PackedVector2Array]:
	"""
	Returns an array of the segments of `line`.
	"""
	var segments:Array[PackedVector2Array] = []
	
	for i in range(len(line)-1):
		segments.append(PackedVector2Array([line[i], line[i+1]]))
	
	return segments

func segment_lines(lines) -> Array[PackedVector2Array]:
	"""
	Calls segment_line on all lines in `lines` and returns the results in a single array.
	"""
	var segments:Array[PackedVector2Array] = []
	
	for i in lines:
		segments.append_array(segment_line(i))
	
	return segments

func cast_point(target:Vector2, point:Vector2, bounds:Rect2) -> Array[Vector2]:
	"""
	Casts a line from target in the direction of point and returns the point where it intersects with bounds.
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
		
		# NOTE: interesting point, some of the other theta calculations are just
		# the negative of their pair. This is actually the case here but TAU - angle
		# is equivalent and prevents negative results.
		
		distance = abs(dist)/tan(theta)
		
		intersect = Vector2((1 if dsign else -1) * distance, dist)
		
	elif angle > angle_tr or angle <= angle_br:
		edge = Vector2.RIGHT # including bottom right
		
		# calculate the horrisontal distance from the target to the right edge.
		dist = viewport_top_right.x - target.x
		
		# NOTE: This angle calculation is slightly different due to the 0 angle being in the middle of the range.
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

func cast_polygon(target:Vector2, start:Vector2, stop:Vector2, bounds:Rect2) -> PackedVector2Array:
	"""
	Casts the line segment from `start` to `stop` against `bounds` from the perspective of `target` and returns the resulting polygon.
	Both `start` and `stop` must be inside the bounds but `target` may be outside
	"""
	# TODO: modify so that the start and stop points can be out of bounds and the polygon cast still works
	if not (rect_has_point(bounds, start) and rect_has_point(bounds, stop)):
		printerr("Invalid `line` in cast_polygon. Both points in `line` must be within the bounds.")
		# stop the code for debugging
		assert(false)
		return PackedVector2Array([])
	
	# initialise the polygon with the line
	var polygon = PackedVector2Array([start, stop])
	
	# find the cast points and their edges
	var start_cast = cast_point(target, start, bounds)[0]
	var stop_cast  = cast_point(target, stop , bounds)[0]
	
	polygon.append(stop_cast)
	polygon.append_array(find_corners(stop, start, target, bounds))
	polygon.append(start_cast)
	
	return polygon

func cast_polygons(target:Vector2, line:PackedVector2Array, bounds:Rect2) -> Array[PackedVector2Array]:
	"""
	Casts `line` against `bounds` from the perspective of `target`. This is done
	by calling `cast_polygon` on each segment of `line` and merging the polygons
	afterwards.
	"""
	var segments = segment_lines(clip_line(line, bounds))
	var polygons:Array[PackedVector2Array] = []
	
	for i in segments:
		polygons.append(cast_polygon(target, i[0], i[1], bounds))
	
	polygons = merge_polygons(polygons)
	
	return polygons

func find_corners(point1: Vector2, point2: Vector2, target:Vector2, bounds:Rect2, direction:bool = false) -> PackedVector2Array:
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
	var bounds_tl:Vector2 = bounds.position
	var bounds_tr:Vector2 = bounds.position + Vector2.RIGHT * bounds.size.x
	var bounds_bl:Vector2 = bounds.position + Vector2.DOWN  * bounds.size.y
	var bounds_br:Vector2 = bounds.end
	
	# the angles from the target to the corners of the bounds.
	var angle_tl:float = fix_angle(target.angle_to_point(bounds_tl))
	var angle_tr:float = fix_angle(target.angle_to_point(bounds_tr))
	var angle_bl:float = fix_angle(target.angle_to_point(bounds_bl))
	var angle_br:float = fix_angle(target.angle_to_point(bounds_br))
	
	# the angles from the target to the points (same as the angles from the points to their intersects).
	var angle_a:float = fix_angle(target.angle_to_point(point1))
	var angle_b:float = fix_angle(target.angle_to_point(point2))
	
	var angles:Array[float] = [
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
	var corners:PackedVector2Array = PackedVector2Array([])
	for i in chosen_angles:
		corners.append({
			angle_tl:bounds_tl,
			angle_tr:bounds_tr,
			angle_bl:bounds_bl,
			angle_br:bounds_br
		}[i])
	
	return corners

func transform_array(array:PackedVector2Array, transform:Vector2) -> PackedVector2Array:
	"""
	Returns a PackedVector2Array with `transform` added to each element of `array:PackedVector2Array`
	"""
	var new = []
	for i in array:
		new.append(i + transform)
	
	return new

func lines_intersect(line1:PackedVector2Array, line2:PackedVector2Array) -> PackedVector2Array:
	"""
	Returns a list of all intersections between `line1` and `line2`. If
	the lines don't intersect then return an empty PackedVector2Array.
	"""
	var intersections = PackedVector2Array()
	
	for i1 in range(0, line1.size()-1): # loop from the first to the 2nd to last index.
		var p11 = line1[i1]
		var p12 = line1[i1 + 1]
		for i2 in range(0, line2.size()-1):
			var p21 = line2[i2]
			var p22 = line2[i2 + 1]
			
			var intersect = Geometry2D.segment_intersects_segment(p11,p12,p21,p22)
			if intersect:
				intersections.append(intersect)
	
	return intersections

func get_local_bounds(node:Node, margin:float = 64) -> Rect2: # TODO: Make this return a polygon that accounts for rotation.
	"""
	Returns the viewport rect in the local space of the given node and expands it by the given error margin.
	"""
	# this is the viewport rect in global coordinates.
	var global_rect = (node.get_viewport_rect() * node.get_viewport_transform()).grow(margin)
	
	# convert to local coordinates before returning.
	return to_local_rect(node, global_rect)

func get_segments(polygon:PackedVector2Array) -> Array[PackedVector2Array]:
	"""
	Returns a list of all the line segments that make up the polygon/line (each consists of two points).
	If the polygon/line has 1 or no points then print and return and error.
	"""
	if len(polygon) <= 1:
		printerr("get_segments requires the polygon to have at least 2 points.")
		# stop the code for debugging
		assert(false)
		return []
	
	var segments:Array[PackedVector2Array] = []
	for count in range(len(polygon)-1): # ignore the last point as it will be taken by the previous one.
		segments.append(PackedVector2Array([
			polygon[count],
			polygon[count + 1]
		]))
	
	return segments

func _segment_has_point(segment:PackedVector2Array, point:Vector2) -> bool:
	"""
	Returns true if `point` lies on the line segment `segment`. Note that `segment`
	must have exactly 2 points. If `point` is one of the end points then return false.
	This method is redundant because segment_has_point is simpler and probs better.
	"""
	if len(segment) != 2:
		printerr("segment_has_point requires the given segment to have only 2 points.")
		# stop the code for debugging
		assert(false)
		return false
	
	if point==segment[0] or point==segment[1]:
		return false
	
	if not are_colinear(PackedVector2Array([segment[0], segment[1], point])):
		return false
	
	if (point.x < min(segment[0].x, segment[1].x)) or (point.x > max(segment[0].x, segment[1].x)):
		# if the point is further left than the leftmost point on the segment or further right than
		# the rightmost point on the segment then it can't be on it.
		return false
	
	if (point.y < min(segment[0].y, segment[1].y)) or (point.y > max(segment[0].y, segment[1].y)):
		# if the point is further up than the upmost point on the segment or further down than
		# the downmost point on the segment then it can't be on it.
		return false
	
	# if the point is colinear with the segment and is within its bounding box then it must be on it.
	return true

func segment_has_point(segment:PackedVector2Array, point:Vector2) -> bool:
	"""
	Returns true if `point` lies on the line segment `segment`. Note that `segment`
	must have exactly 2 points. If `point` is one of the end points then return false.
	This method uses the are_colinear method with an ordered test.
	"""
	if len(segment) != 2:
		printerr("segment_has_point requires the given segment to have only 2 points.")
		# stop the code for debugging
		assert(false)
		return false
	
	if point==segment[0] or point==segment[1]:
		return false
	
	return are_colinear(PackedVector2Array([segment[0], point, segment[1]]), true)

func get_segment_overlap(segment1:PackedVector2Array, segment2:PackedVector2Array) -> PackedVector2Array:
	"""
	Returns the line segment representing the overlap between segment1 and segment2. If
	there is no overlap then return an empty PackedVector2Array. If the two segments are
	non-colinear but intersect at a single point then return an empty PackedVector2Array.
	Both segments should (being segments) only have two points in their arrays.
	"""
	if len(segment1) != 2 or len(segment2) != 2:
		printerr("get_segment_overlap expects both segments to have a length of 2")
		# stop the code for debugging
		assert(false)
		return PackedVector2Array([])
	
	# ensure all the 4 points are colinear
	if not are_colinear(PackedVector2Array([segment1[0],segment1[1],segment2[0],segment2[1]])):
		return PackedVector2Array([])
	
	# We need to find the vector parametric form of the line containing both segments.
	# This requires at least two distinct points to whos difference forms the direction
	# vector. Given that both segments have to have a non-zero length for there to be
	# any non-zero overlap we can first ensure that both segments have two distinct points.
	if segment1[0] == segment1[1] or segment2[0] == segment2[1]:
		return PackedVector2Array([])
	
	var direction = segment1[0] - segment1[1]
	
	# The constant at the end (r = D * t + C) can be any point on the line so we can pick
	var constant = segment1[0]
	
	# The parametric form is now:
	# point = direction * t + constant
	# solving for t gives:
	# t = (point - constant).n / direction.n
	# where n is any of x or y as can be seen by expanding the vector form
	
	var t_10 = get_parameter(segment1[0], direction, constant)
	var t_11 = get_parameter(segment1[1], direction, constant)
	var t_20 = get_parameter(segment2[0], direction, constant)
	var t_21 = get_parameter(segment2[1], direction, constant)
	
	var seg1_min = min(t_10,t_11)
	var seg1_max = max(t_10,t_11)
	var seg2_min = min(t_20,t_21)
	var seg2_max = max(t_20,t_21)
	
	var t_start = max(seg1_min, seg2_min)
	var t_stop = min(seg1_max, seg2_max)
	
	if t_start >= t_stop:
		return PackedVector2Array([])
	
	var point1 = direction * t_start + constant
	var point2 = direction * t_stop  + constant
	
	return PackedVector2Array([point1, point2])

func clip_segment(segment:PackedVector2Array, mask:PackedVector2Array) -> Array[PackedVector2Array]:
	"""
	Returns the portion of segment that is not shared with mask. This only removes non-zero
	length sections from segment so single point intersections or end to end connections are not
	counted as overlap. If segment has 0 length then return an empty Array regardless of whether
	segment had points in it. Both segments must (being segments) have exactly 2 points. This
	method returns an array of segments because if mask is in the middle of segment then
	removing it results in two endpoint segments.
	"""
	if len(segment)!=2 or len(mask)!=2:
		printerr("clip_segment expects both segments to have exactly 2 points.")
		# stop the code for debugging
		assert(false)
		return []
	
	if segment[0]==segment[1]:
		return []
	
	var overlap = get_segment_overlap(segment, mask)
	
	if len(overlap)==0:
		return [segment]
	
	# if there is an overlap we need to remove that section from segment. 
	# we already know that overlap and segment are colinear so we can put
	# them both in vector parametric form and use the parameter intervals to
	# remove the overlapping section
	
	# point = direction * t + constant
	var direction = segment[1] - segment[0]
	var constant = segment[0]
	
	# find the parameter (t) values for the end points of both segment and the overlap.
	# seethe comments in the get_segment_overlap method for a more in depth description.
	# t = (point - constant).n / direction.n
	
	var t_seg1_0    = get_parameter(segment[0], direction, constant)
	var t_seg1_1    = get_parameter(segment[1], direction, constant)
	var t_overlap_0 = get_parameter(overlap[0], direction, constant)
	var t_overlap_1 = get_parameter(overlap[1], direction, constant)
	var seg1_int = [min(t_seg1_0, t_seg1_1), max(t_seg1_0, t_seg1_1)]
	var overlap_int = [min(t_overlap_0, t_overlap_1), max(t_overlap_0, t_overlap_1)]
	
	# now remove the interval `overlap_int` from the interval `seg1_int`
	var new_interval
	var new_interval_2 = null
	
	# if they are entierly seperate then the new interval is just seg1
	if seg1_int[0] >= overlap_int[1] or seg1_int[1] <= overlap_int[0]:
		new_interval = seg1_int
	
	# where the overlap interval takes the bottom of seg1
	elif chain_lt([overlap_int[0], seg1_int[0], overlap_int[1], seg1_int[1]], false):
		new_interval = [overlap_int[1], seg1_int[1]]
	
	# where the overlap interval takes the top of seg1
	elif chain_lt([seg1_int[0], overlap_int[0], seg1_int[1], overlap_int[1]], false):
		new_interval = [seg1_int[0], overlap_int[0]]
	
	# if the overlap interval entierly contains seg1
	elif overlap_int[0] <= seg1_int[0] and overlap_int[1] >= seg1_int[1]:
		return []
	
	# if the overlap interval takes the middle out of seg1. This is a strict inequality
	# because all non-strict cases should have already been covered.
	elif chain_lt([seg1_int[0], overlap_int[0], overlap_int[1], seg1_int[1]]):
		new_interval = [seg1_int[0], overlap_int[0]]
		new_interval_2 = [overlap_int[1], seg1_int[1]]
	
	else:
		printerr("Something went wrong in clip_segment. This statment should be unreachable.")
		# stop the code for debugging
		assert(false)
		return []
	
	# some of the non-strict tests allow for zero-length results so remove them
	if new_interval[0]==new_interval[1]:
		return []
	if new_interval_2 and (new_interval_2[0]==new_interval_2[1]):
		new_interval_2 = null
	
	var new_seg = PackedVector2Array([
		direction * new_interval[0] + constant,
		direction * new_interval[1] + constant
	])
	
	if not new_interval_2:
		return [new_seg]
	else:
		var new_seg_2 = PackedVector2Array([
			direction * new_interval_2[0] + constant,
			direction * new_interval_2[1] + constant
		])
		return [new_seg, new_seg_2]

func clip_lines(line:PackedVector2Array, mask:PackedVector2Array) -> Array[PackedVector2Array]:
	"""
	Returns the portion of line that is not shared with mask. This only removes non-zero
	length sections from line so single point intersections or end to end connections are not
	counted as overlap. If line has 0 length then return an empty Array regardless of whether
	line had points in it. This method returns an array of lines because if mask is in the
	middle of segment then removing it results in two endpoint segments. This is the same as
	the clip_segment method but works for multi-segment lines. Clips are calculated segment
	by segment.
	"""
	var line_segments:Array[PackedVector2Array] = segment_line(line)
	var mask_segments:Array[PackedVector2Array] = segment_line(mask)
	
	var clipped_segments:Array[PackedVector2Array] = []
	
	while len(line_segments):
		# pop_back is preferable to pop_front for performance
		var segment:PackedVector2Array = line_segments.pop_back()
		
		for mask_segment in mask_segments:
			var clip:Array[PackedVector2Array] = clip_segment(segment, mask_segment)
			
			# take the first piece as the segment
			segment = clip[0]
			# and add the rest to line_segments to finish checking later.
			line_segments.append_array(clip.slice(1))
		
		clipped_segments.append(segment)
	
	# merge the segments back together again
	var clipped_line = merge_lines(clipped_segments)
	
	return clipped_line

func clip_line_sets(lines:Array[PackedVector2Array], mask:Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	"""
	For each line in lines clip it against all lines in mask and return the result. This can
	generate a list bigger than lines as clipping a line can split it into pieces. After clipping
	an attempt is made to merge lines so if lines isn't already in its simplest form the resulting
	array may be smaller than lines (or even if it is in its simplest form because clipping could
	entierly remove disconnected sections).
	"""
	# collect all the segments from lines and from mask
	var line_segments:Array[PackedVector2Array]
	for line in lines:
		line_segments.append_array(segment_line(line))
	
	var mask_segments:Array[PackedVector2Array]
	for mask_line in mask:
		mask_segments.append_array(segment_line(mask_line))
	
	# TODO: From here downward the code is the same as in clip_lines so I could remove
	# clip_lines entierly and just use this function for single line cases.
	var clipped_segments:Array[PackedVector2Array] = []
	
	while len(line_segments):
		# pop_back is preferable to pop_front for performance
		var segment:PackedVector2Array = line_segments.pop_back()
		
		for mask_segment in mask_segments:
			var clip:Array[PackedVector2Array] = clip_segment(segment, mask_segment)
			
			# if there's nothing left of the segment then leave it blank and skip
			# the rest of the mask.
			if len(clip)==0:
				segment = PackedVector2Array([])
				break
			
			# take the first piece as the segment
			segment = clip[0]
			# and add the rest to line_segments to finish checking later.
			line_segments.append_array(clip.slice(1))
		
		# don't add empty segments.
		if len(segment):
			clipped_segments.append(segment)
	
	# merge the segments back together again
	var clipped_line = merge_lines(clipped_segments)
	
	return clipped_line

func merge_lines(lines:Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	"""
	Merges the lines in the array such that lines with shared endpoints or overlapping sections
	are merged and lines entierly within other lines are removed. This starts by splitting each
	line into its segments so lines that internally overlap will also be simplified.
	"""
	# split the lines into segments.
	lines = segment_lines(lines).duplicate()
	
	print_nth("merging segments: "+str(lines))
	
	var new_lines:Array[PackedVector2Array] = []
	while len(lines): # while we have at least one line left
		var segment = lines.pop_back() # faster than pop_front because indices don't have to be updated 
		print_nth("    new lines is now: "+str(new_lines))
		print_nth("####performing pass with: "+str(segment))
		
		# remove 0 length segments by not adding them to the new_lines array
		if segment[0] == segment[1]:
			print_nth("    skipping 0 length segment")
			continue
		
		# used to carry continue statments through two nested loops
		var cont:bool = false
		
		# remove/trim overlapping segments
		for new_line_segment in segment_lines(new_lines):
			var clip = clip_segment(segment, new_line_segment)
			
			# if all of the line got clipped then continue
			if len(clip)==0:
				cont = true
				print_nth("    all of the line overlaps with other lines")
				break
			
			# if we get two resultant segments then keep working
			# with one of them and just do the other one next.
			if len(clip) == 2:
				print_nth("    (adding the other half of the split to the array.)")
				lines.append(clip[1])
			
			segment = clip[0]
		
		if cont: # the segment we've been working with has been merged already.
			continue
		
		# find the 0 to 2 existing lines with which segment shares it's endpoints.
		# this array stores joined lines as follows: [index, line_end, segment_end]
		# index is the index in new_lines of the joined line
		# line_end is 0 if the shared point is at the beginning of the line and -1 if it's at the end.
		# segment_end is 0 if the shared point is at the beginning of the segment and -1 if it's at the end.
		var joined_lines:Array[PackedInt32Array] = []
		for index in range(len(new_lines)):
			var new_line = new_lines[index]
			for combos in [[0,0],[0,-1],[-1,0],[-1,-1]]:
				# conbos[0] is the line endpoint and combos[1] is the segment endpoint.
				if new_line[combos[0]] == segment[combos[1]]:
					joined_lines.append(PackedInt32Array([index, combos[0], combos[1]]))
			
			if len(joined_lines) == 2:
				# keep looping until we find 2 ends to join or we run out of lines to check.
				break
		
		print_nth("    found "+str(len(joined_lines))+" joined lines to merge")
		
		if len(joined_lines) == 0:
			# if the segment doesn't share endpoints with any lines then don't do any merging.
			pass
		elif len(joined_lines) == 1:
			# if the segment only shares an endpoint with one other line then add it on.
			var index = joined_lines[0][0]
			var line_end = joined_lines[0][1]
			var segment_end = joined_lines[0][2]
			# get the other point from the segment, the non-joining one.
			var segment_point = segment[-(segment_end + 1)]
			
			if line_end == 0:
				# if the line joins the segment at its start
				new_lines[index].reverse()
				new_lines[index].append(segment_point)
				new_lines[index].reverse()
			else:
				# if the line joins the segment at the end
				new_lines[index].append(segment_point)
			continue
		else:
			# if the segment joines two lines in the middle then we add the 1st line to the 2nd.
			var index1 = joined_lines[0][0]
			var index2 = joined_lines[1][0]
			var line_end1 = joined_lines[0][1]
			var line_end2 = joined_lines[1][1]
			
			# if the first line joins from it's end then flip it.
			if line_end1 == -1:
				new_lines[index1].reverse()
			
			# if the 2nd line joins from it's last point then flip it before appending.
			# NOTE: This reversing does not get undone but that shouldn't matter
			# as the direction of the line isn't important.
			if line_end2 == -1:
				new_lines[index2].reverse()
			
			# add the lines together and remove the newly redundant one.
			new_lines[index2].append_array(new_lines[index1])
			new_lines.remove_at(index1)
			
			continue
		
		# if none of the attempts to merge the segment so far have worked then
		# just add it as a new line.
		new_lines.append(segment)
	
	var new_lines_temp:Array[PackedVector2Array] = []
	for line in new_lines:
		new_lines_temp.append(decolinearise_line(line))
	
	print_nth("returning merged lines: "+str(new_lines_temp))
	
	return new_lines_temp
	
	# TODO: There is one case this code misses.
	# If you have a loop where the first and last points are the same that will
	# not (and cannot) be simplified. If there is another line that shared an
	# endpoint with some point in the middle of this loop the end joining algorithm
	# won't connect it because it's not an end to end common point. But loops can
	# have their end point adjusted to any of their points without changing the line
	# so if the join was moved to the location of that other line's endpoint then
	# the two lines could become one. Think of a unit square joined at the top left
	# with another line connected to the bottom right. The line could be re-written
	# as going from the bottom right round the loop then off down the other line but
	# this code won't make that simplification. I think this particular simplification
	# won't have visual implications like endpoint connections at corners would though.

func find_connected_edges(polygons:Array[PackedVector2Array]) -> Array[Array]:
	"""
	For each polygon in the array return a list containing each continuous line (PackedVector2Array) on that polygon
	that is shared with the border of another polygon in the array. If only a portion of a line segment is a shared border
	then only return the shared section. This function returns an array where each item corresponds to a polygon in the
	argument so len(polygons) == len(find_connected_edges(polygons)) and each item is an array of the shared line segments
	of that polygon (which is in itself an array) Array[Array[PackedVector2Array]]. Note that single point intersections,
	i.e. those between non-colinear lines, are not counted. Borders (or sections of border) that lie inside other polygons
	are not counted either, the border must be exactly on the border of another polygon. This method starts by simplifying
	the polygons by removing all adjacent points that are the same and any points made redundant by colinearity.
	"""
	var temp:Array[PackedVector2Array] = []
	for polygon in polygons:
		temp.append(decolinearise_line(make_line_unique(polygon)))
	polygons = temp
	
	print(polygons)
	
	var all_overlaps:Array[Array] = []
	for count in range(len(polygons)):
		# store the overlapping sections for this polygon
		var overlaps:Array[PackedVector2Array] = []
		
		# the target polygon
		var polygon = polygons[count]
		
		# all the other polygons
		var other_polygons = polygons.duplicate()
		other_polygons.remove_at(count)
		
		# the line segments of the target polygon
		var segments = get_segments(polygon)
		
		# the line segments from all the other polygons
		var other_segments = []
		for p in other_polygons:
			other_segments.append_array(get_segments(p))
		
		# for each segment in the target polygon check it against all the other segments from the other polygons
		for segment in segments:
			for other_segment in other_segments:
				var overlap = get_segment_overlap(segment,other_segment)
				
				# if there is an overlap store it and join them all together at the end
				if len(overlap):
					overlaps.append(overlap)
		
		all_overlaps.append(merge_lines(overlaps))
	
	return all_overlaps

func get_parameter(point:Vector2, direction:Vector2, constant:Vector2) -> float:
	"""
	Uses the vector equation point = direction * t + constant
	to solve for t given the 3 other values. This method assumes
	all vectors are in 2-space.
	"""
	var parameter:float
	if direction.x != 0:
		parameter = (point - constant).x/direction.x
	else:
		parameter = (point - constant).y/direction.y
	return parameter
