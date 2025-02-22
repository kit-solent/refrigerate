extends Node2D

@export var pair:Node2D

@onready var target:Node = Core.main.get_player()

func _ready():
	$sub_viewport.world_2d = get_viewport().world_2d
	
	# find the bounding rectangle of the line, expand it for error margin, and assign it to the on screen notifier.
	$on_screen_notifier.rect = Core.tools.line_bounds($line.points).grow(64)
	
	$sub_viewport/camera_2d/color_rect/label.text = name

func _process(_delta:float):
	# the portal is only drawn if on the local screen. This works with multiplayer, only showing the portal to those who can see it.
	# the portal should also only be drawn if it's target is within a certain distance of the portal.
	if pair:
		# move the pairs camera to the right position. Global coordinates must be used because the
		# camera is inside a viewport and so doesn't have coordinates local to the pair (I think).
		$sub_viewport/camera_2d.global_position = pair.global_position
		
		# update the view
		if $on_screen_notifier.is_on_screen():
			set_view(target)

@warning_ignore("shadowed_variable")
func set_view(target:Node):
	# TODO: There is actually flicker than you can quite easily see
	# for complex shapes and certain target positions.
	
	# clear the existing polygons
	clear_view()
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), $line.points, get_local_bounds())
	
	for i in polygons:
		var new = Polygon2D.new()
		new.polygon = i
		
		# a texture storage node is used because dealing with NodePaths and viewport textures from code is messy.
		new.texture = pair.get_node("texture_storage").texture
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
	# this is the viewport rect in global coordinates.
	var global_rect = (get_viewport_rect() * get_viewport_transform()).grow(margin)
	
	# convert to local coordinates before returning.
	return Core.tools.to_local_rect(self, global_rect)
