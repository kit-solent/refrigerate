extends Control
@onready var camera_target=$h_box_container/view/view/world/players/player

func _ready():
	pass

func _process(_delta):
	$h_box_container/view/view/world/meta/camera.global_transform=camera_target.global_transform

