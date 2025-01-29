extends Control

@export var main_shader:Shader
@export var overlay_shader:Shader

@onready var camera_target=get_player()

func _ready():
	$h_box_container/panel/view/view/world/meta/darkener.visible = not Core.debug
	$h_box_container/panel/view.material.shader = main_shader
	$h_box_container/panel/overlay.material.shader = overlay_shader
	
	#Core.local_player=$h_box_container/panel/view/view/world/players/player

func _process(_delta):
	$h_box_container/panel/view/view/world/meta/camera.global_transform=camera_target.global_transform
	#$h_box_container/panel/view/view/world/meta/camera.global_position=camera_target.global_position

func get_player():
	return $h_box_container/panel/view/view/world/players/player
