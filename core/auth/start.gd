extends Control

func _ready():
	pass

func _process(_delta):
	pass


func _on_gameplay_video_finished():
	# the video will automatically restart but
	# here we could play something else or stop it.
	pass


@onready var tab_container = $main/main/center_container/tab_container
func _on_sign_in_button_down() -> void:
	tab_container.current_tab = 4

func _on_sign_up_button_down() -> void:
	tab_container.current_tab = 5

func _on_source_button_down() -> void:
	tab_container.current_tab = 1

func _on_lore_button_down() -> void:
	tab_container.current_tab = 2

func _on_credits_button_down() -> void:
	tab_container.current_tab = 3
