class_name Portal extends Node2D

@export var pair:Portal

func _ready():
	var new = Line2D.new()
	clip_line($line.points[0], $line.points[1], get_local_bounds())
	$lines.add_child(new)

func get_local_bounds():
	return Rect2(to_local(get_viewport_rect().position), get_viewport_rect().size)

func clip_line(start:Vector2, stop:Vector2, bounds:Rect2):
	"""
	Returns the section of the given straight line that lies inside the given bounds.
	Returns an empty PackedVector2Array if the line is entirly outside the bounds.
	"""
	var direction = stop - start
	
	var top_limit    = bounds.position.y
	var bottom_limit = bounds.position.y + bounds.size.y
	var left_limit   = bounds.position.x
	var right_limit  = bounds.position.x + bounds.size.x
	
	var viewport_top_left     = bounds.position
	var viewport_top_right    = bounds.position + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = bounds.position + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = bounds.position + Vector2.DOWN  * bounds.size.y + Vector2.RIGHT * bounds.size.x
	
	var intersects = PackedVector2Array()
	# for each edge (top, bottom, left, right) work out where this line would intersect it
	var top = Geometry2D.line_intersects_line(viewport_top_left, Vector2.RIGHT * bounds.size.x, start, direction)
	if top:
		intersects.append(top)
	
	var right = Geometry2D.line_intersects_line(viewport_top_right, Vector2.DOWN * bounds.size.y, start, direction)
	if right:
		intersects.append(right)
	
	var bottom = Geometry2D.line_intersects_line(viewport_bottom_left, Vector2.RIGHT * bounds.size.x, start, direction)
	if bottom:
		intersects.append(bottom)
	
	var left = Geometry2D.line_intersects_line(viewport_top_left, Vector2.DOWN * bounds.size.y, start, direction)
	if left:
		intersects.append(left)
	
	if len(intersects) == 0:
		# if the line does not intersect the bounds
		# TODO: has_point rejects points on the bottom or right edges so consider writing an alternative that includes those points.
		if bounds.has_point(start) and bounds.has_point(stop):
			# if the line is inside then return it
			return PackedVector2Array([start, stop])
		else:
			# otherwise return nothing
			return PackedVector2Array()
	if len(intersects) == 2:
		# if the line intersects twice then it must start and end outside
		# in this case just return the two intersects
		return intersects
	if len(intersects) == 1:
		# if there is 1 intersect then find and use the inside point and the intersect
		if bounds.has_point(start):
			return PackedVector2Array([start, intersects[0]])
		elif bounds.has_point(stop):
			return PackedVector2Array([stop, intersects[0]])
		else:
			printerr("what??? gfsdjgflsdg")
	print("what?? GIUOLHK this should not ever happen")
	print(intersects)
	for i in range(len(intersects)):
		get_node("dot"+str(i)).position = intersects[i]

func get_portal_line(line:PackedVector2Array, bounds:Rect2):
	"""
	Returns the portion of the portal line that is inside the given bounds.
	This is an implimentation of the Cohen–Sutherland algorithm (https://en.wikipedia.org/wiki/Cohen%E2%80%93Sutherland_algorithm)
	modified for multi-point lines. Note that this function returns an array of lines as the portal clip could be composed
	of more than one line.
	"""
	# break the line into straight sections (two point lines) and store them in `lines`
	var lines:Array = Array()
	for i in range(len(line)-1):
		lines.append(PackedVector2Array([line[i], line[i+1]]))
	print(lines)
	# clip all the lines
	var clipped_lines = []
	for l in lines:
		var clipped_line = clip_line(l[0], l[1], bounds)
		if len(clipped_line) > 0:
			# only add the line if it contains points.
			# if it is empty then the clip must have been
			# a trivial reject.
			clipped_lines.append(clipped_line)
	
	print(clipped_lines)
	# reconstruct the line from it's parts. The new_lines array starts with the first
	# point of the first line in clipped_lines (which is the first point of the total line)
	var new_lines:Array[PackedVector2Array] = [clipped_lines[0]]
	for i in range(1, len(clipped_lines) - 1):
		if clipped_lines[i][0] != new_lines[-1][-1]:
			# if the first point of the new line is different to the last point of the
			# old line then the lines are seperate
			new_lines.append(PackedVector2Array())
		
		# add the new point.
		new_lines[-1].append(clipped_lines[i][1])
	
	# TODO: this step can be removed if it becomes clear that it never happens.
	# remove any duplicate points from the lines
	for _line in new_lines:
		var existing_points = []
		for _point in line:
			if _point in existing_points:
				printerr("portal.gd get_portal_line: duplicate point removal is required")
			existing_points.append(_point)
	
	return new_lines

func set_view(target:Node):
	var bounds = get_local_bounds()
	
	var viewport_top_left     = bounds.position
	var viewport_top_right    = viewport_top_left  + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = viewport_top_left  + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN  * bounds.size.y
	
	var target_pos = to_local(target.global_position)
	
	# the angles from the cast_point to the corners of the screen.
	var angle_tl = Core.tools.fix_angle(target_pos.angle_to_point(viewport_top_left))
	var angle_tr = Core.tools.fix_angle(target_pos.angle_to_point(viewport_top_right))
	var angle_bl = Core.tools.fix_angle(target_pos.angle_to_point(viewport_bottom_left))
	var angle_br = Core.tools.fix_angle(target_pos.angle_to_point(viewport_bottom_right))
	
	# get the points that make up the portal border.
	var portal_points = $line.points
	
	var cast_points = []
	var edges = []
	var angles = []
	for i in portal_points:
		var err = Core.tools.get_cast_point(target_pos, i, bounds)
		if err:
			return ERR_HELP
		cast_points.append(err[0])
		edges.append(err[1])
		angles.append(Core.tools.fix_angle(target_pos.angle_to_point(i)))
	
	# start the polygon with all the points that make up the portal line.
	var points = portal_points
	cast_points.reverse()
	points.append_array(cast_points)
	
	$view.polygon = points
	$line2.points = points
