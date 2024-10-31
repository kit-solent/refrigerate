class_name Portal extends Node2D

@export var pair:Portal
@export var point_a:Vector2 = 32 * Vector2.UP
@export var point_b:Vector2 = 32 * Vector2.DOWN

func _ready():
	pair
	$sub_viewport.world_2d

func _process(delta: float):
	pass # use set_view here.

func set_view(target:Node):
	var target_pos = to_local(target.global_position)
	var viewport_rect = get_viewport_rect()
	
	# the coordinates of the corners of the viewport rectangle relative to our origin.
	var viewport_top_left = to_local(viewport_rect.position)
	var viewport_top_right = viewport_top_left + Vector2.RIGHT * viewport_rect.size.x
	var viewport_bottom_left = viewport_top_left + Vector2.DOWN * viewport_rect.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN * viewport_rect.size.y
	
	$line_2d2.points = [
		viewport_top_left * 0.9,
		viewport_top_right * 0.9,
		viewport_bottom_right * 0.9,
		viewport_bottom_left * 0.9
	]
	
	var points = [point_a,point_b]

	$view.polygon = points
	#$line_2d2.points = points

func get_cast_point(target:Vector2, cast_point:Vector2, bounds:Rect2):
	"""
	NOTE: target, cast_point, and bounds are all in local coords.
	"""
	
	if not (bounds.has_point(target) and bounds.has_point(cast_point)):
		printerr("Invalid arguments to get_cast_point, both points must be inside the given bounds.")
		return ERR_INVALID_PARAMETER
	
	# the coordinates of the corners of the viewport rectangle relative to our origin.
	var viewport_top_left     = bounds.position
	var viewport_top_right    = viewport_top_left  + Vector2.RIGHT * bounds.size.x
	var viewport_bottom_left  = viewport_top_left  + Vector2.DOWN  * bounds.size.y
	var viewport_bottom_right = viewport_top_right + Vector2.DOWN  * bounds.size.y
	
	var angle_tl = target.angle_to_point(viewport_top_left)
	var angle_tr = target.angle_to_point(viewport_top_right)
	var angle_bl = target.angle_to_point(viewport_bottom_left)
	var angle_br = target.angle_to_point(viewport_bottom_right)
	
	var angle = target.angle_to_point(cast_point)
	
	var direction = cast_point - target
	var xMult = 0
	var yMult = 0
	
	if direction.x != 0:
		if direction.x > 0:
			print(viewport_top_right.x - target.x)
			print(direction.x)
			xMult = (viewport_top_right.x - target.x)/direction.x
		else:
			print(viewport_top_left.x - target.x)
			print(direction.x)
			xMult = (viewport_top_left.x - target.x)/direction.x
	
	print(xMult)
	
	# so that the angle is only ever positive
	if angle < 0:
		angle += 2*PI
	
	
func to_local_rect(rect:Rect2):
	"""
	Converts a rect in global coordinates to local coordinates.
	"""
	return Rect2(to_local(rect.position), rect.size)
