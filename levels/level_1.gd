extends Map

var explosion = preload("res://features/explosion/explosion.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("debug key"):
		var new = explosion.instantiate()
		get_parent().get_node("temp").add_child(new)
		new.global_position = $marker_2d.global_position
