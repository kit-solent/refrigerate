class_name Portal extends Node2D

@export var pair:Portal
@onready var target:Node = Core.main.get_player()
#@onready var target:Node = $DEBUG/marker_2d


func _process(delta: float):
	$DEBUG/marker_2d.global_position = get_global_mouse_position()
	# the portal is only drawn if on the local screen. This works with multiplayer, only showing the portal to those who can see it.
	# the portal should also only be drawn if it's target is within a certain distance of the portal.
	if $on_screen_notifier.is_on_screen() and get_local_bounds().has_point(to_local(target.global_position)):
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
	"""
	Clears the portal view by deleting all view polygons.
	"""
	for i in $view.get_children():
		$view.remove_child(i)
		i.queue_free()

func get_local_bounds(margin:float = 64):
	"""
	Returns the viewport rect in local space and expands it a little for error margin.
	"""
	return (get_viewport_rect() * get_viewport_transform()).grow(margin)
