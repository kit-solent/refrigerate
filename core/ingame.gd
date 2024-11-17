extends Control
@onready var camera_target=$view/world/players/player

func _ready():
	$view/world/meta/darkener.visible = not Core.debug
	#Core.local_player=$h_box_container/panel/view/view/world/players/player

func _process(_delta):
	$view/world/meta/camera.global_transform=camera_target.global_transform

func get_player():
	return $view/world/players/player
