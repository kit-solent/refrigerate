class_name Portal extends Node2D

@export var pair:Portal

func _process(delta: float) -> void:
	$marker_2d.global_position = get_global_mouse_position()
	set_view($marker_2d)

func get_local_bounds():
	return get_viewport_rect() * get_viewport_transform()

func set_view(target:Node):
	# clear the existing polygons
	for i in $view.get_children():
		$view.remove_child(i)
		i.queue_free()
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(target.position, $line.points, get_local_bounds())
	for i in polygons:
		var new = Polygon2D.new()
		new.polygon = i
		$view.add_child(new)
