class_name ModeOveride extends Area2D
@export_enum("TopDown","PlatformerDown","PlatformerUp","PlatformerLeft","PlaformerRight") var mode=1

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.set_mode(mode)
