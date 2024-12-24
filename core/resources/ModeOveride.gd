class_name ModeOveride extends Area2D
@export_enum("TopDown","PlatformerDown","PlatformerLeft","PlatformerUp","PlaformerRight") var mode=1

var gravity_shader = preload("res://core/resources/shaders/gravity.gdshader")

func _on_body_entered(body):
	return # TODO: temporary
	@warning_ignore("unreachable_code")
	if body.is_in_group("players"):
		body.set_mode(mode)

func set_polygon(polygon:PackedVector2Array):
	if not $collision:
		printerr("The ModeOveride must be added to the scene tree before set_polygon can be called.")
		return ERR_DOES_NOT_EXIST
	$collision.polygon = polygon
	$visuals.polygon = polygon

func set_mode(_mode:int):
	mode = _mode
	add_to_group(Core.mode_names[mode])
	$visuals.material.shader = gravity_shader
	$visuals.material.shader
	#$visuals.color = Core.mode_colours[mode]
