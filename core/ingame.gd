extends Control

@export var main_shader:Shader
@export var overlay_shader:Shader


@onready var camera_target=$view/world/players/player

func _ready():
	$view/world/meta/darkener.visible = not Core.debug
	$h_box_container/panel/view.material.shader = main_shader
	$h_box_container/panel/overlay.material.shader = overlay_shader
	
	#Core.local_player=$h_box_container/panel/view/view/world/players/player

func _process(_delta):
	$view/world/meta/camera.global_transform=camera_target.global_transform
	
	if Core.debug_frame:
		$view/world/meta/mode_overides.visible = not $view/world/meta/mode_overides.visible

func get_player():
	return $view/world/players/player
