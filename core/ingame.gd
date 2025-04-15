extends Control

@onready var camera_target = get_player()

func _ready():
	# Only darken the scene if we aren't in debug mode.
	#%world/meta/darkener.visible = not Core.debug
	pass
	#Core.local_player=$h_box_container/panel/view/view/world/players/player

func _process(_delta):
	%world/meta/camera.global_transform=camera_target.global_transform

func get_player():
	return %world/players/player
