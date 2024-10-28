extends Node2D

@export var height:float = 64 # px
@export var distance:float = 1000

func _ready():
	pass

func _process(delta: float):
	$marker_2d.global_position = get_global_mouse_position()
	set_view($marker_2d, distance)

func set_view(target:Node, distance:float):
	var points = [
		Vector2(0,  height/2),
		Vector2(0, -height/2)
	]
	
	var target_pos = to_local(target.global_position)

	var theta_a = atan((target_pos.y + height/2) / -target_pos.x)
	var theta_b = atan((target_pos.y - height/2) / -target_pos.x)
	
	var Ax = target_pos.x + distance * cos(theta_a)
	var Ay = target_pos.y - distance * sin(theta_a)
	
	var Bx = target_pos.x + distance * cos(theta_b)
	var By = target_pos.y - distance * sin(theta_b)
	
	points.append(Vector2(Ax, Ay) if Ay < By else Vector2(Bx, By))
	points.append(Vector2(Bx, By) if Ay < By else Vector2(Ax, Ay))
	
	$view.polygon = points
	$line_2d2.points = points
