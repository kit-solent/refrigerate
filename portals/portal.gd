class_name Portal extends Node2D

@export var pair:Portal

func _ready():
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug key"):
		$marker_2d.global_position = get_global_mouse_position()
		$view.polygon = Core.tools.cast_polygon($marker_2d.position, $line.points, get_local_bounds())

func get_local_bounds():
	return get_viewport_rect() * get_viewport_transform()

func portal_segments():
	return Core.tools.clip_line($line.points, get_local_bounds())

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
