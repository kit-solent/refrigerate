extends Area2D

var gravity_shader = preload("res://core/resources/shaders/gravity.gdshader")

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.set_gravity_mode(gravity_direction)

func set_polygon(polygon:PackedVector2Array):
	if not $collision:
		printerr("The ModeOveride must be added to the scene tree before set_polygon can be called.")
		return ERR_DOES_NOT_EXIST
	$collision.polygon = polygon
	$visuals.polygon = polygon

func set_gravity_direction():
	mode = _mode
	add_to_group(Core.mode_names[mode])
	$visuals.material.shader = gravity_shader
	#$visuals.color = Core.mode_colours[mode]
