extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$animated_sprite_2d2.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
