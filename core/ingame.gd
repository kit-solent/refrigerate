extends Control
@onready var camera_target

func _ready():
	pass

func _process(delta):
	$h_box_container/view/view/world/meta/camera.global_position=camera_target.global_position


