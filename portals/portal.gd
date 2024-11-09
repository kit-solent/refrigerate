class_name Portal extends Node2D

@export var pair:Portal
@onready var target:Node = Core.main.get_player()

func _process(delta: float):
	if $on_screen_notifier.is_on_screen():
		set_view(target)

func set_view(target:Node):
	# clear the existing polygons
	clear_view()
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), $line.points, get_local_bounds())
	for i in polygons:
		var new = Polygon2D.new()
		new.polygon = i
		$view.add_child(new)

func clear_view():
	for i in $view.get_children():
		$view.remove_child(i)
		i.queue_free()

func get_local_bounds(margin:float = 64):
	"""
	Returns the viewport rect in local space and expands it a little for error margin.
	"""
	return (get_viewport_rect() * get_viewport_transform()).grow(64)
