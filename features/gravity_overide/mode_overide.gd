extends Area2D

var gravity_shader = preload("res://core/resources/shaders/gravity.gdshader")

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.set_gravity_direction(gravity_direction)

func set_polygon(polygon:PackedVector2Array):
	if not $collision:
		printerr("The ModeOveride must be added to the scene tree before set_polygon can be called.")
		return ERR_DOES_NOT_EXIST
	
	$collision.polygon = polygon
	$visuals.polygon = polygon

func change_gravity_direction(direction:Vector2):
	gravity_direction = direction
	#$visuals.material.shader = gravity_shader # TODO: Learn how to use shaders
	
	if direction == Vector2.ZERO:
		$visuals.color = Core.topdown_color
	else:
		$visuals.color = Core.platformer_color
