extends Map

var explosion = preload("res://features/explosion/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug key"):
		var new = explosion.instantiate()
		get_parent().get_node("temp").add_child(new)
		new.global_position = $marker_2d.global_position
