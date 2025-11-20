extends Node2D

# A portal's pair is the portal that it 'displays'
# and that (when I write functionality for this) is
# the telleportation destination.
@export var pair:Node2D

@onready var target:Node = Core.main.get_player()

func _ready():
	$sub_viewport.world_2d = get_viewport().world_2d
	
	# find the bounding rectangle of the line, expand it for error margin, and assign it to the on screen notifier.
	$on_screen_notifier.rect = Core.tools.line_bounds($line.points).grow(64)

func _process(_delta:float):
	# every frame we delete all the polygons (if any).
	# this prevents polygons from lingering after the portal
	# has left the screen. These can be picked up by other
	# portals which looks bad.
	if polygons_in_view:
		clear_view()
		
	# the portal is only drawn if on the local screen. This works with multiplayer, only showing the portal to those who can see it.
	# the portal should also only be drawn if it's target is within a certain distance of the portal.
	if pair:
		# Move our camera to the pair portal. Global coordinates must be used because the
		# camera is inside a viewport and so doesn't have coordinates local to the pair (I think).
		$sub_viewport/camera_2d.global_position = pair.global_position + Vector2(256.3478, 254.47421)
		
		# update the view
		if $on_screen_notifier.is_on_screen():
			set_view(target)
	
	# TODO: This hack gives the below positions.
	# adding the difference to the camera position
	# gives the right position but the "magic vector"
	# is only as accurate as the visual mouse calibration.
	
	# DEBUG
	#if Input.is_action_just_pressed("debug key"):
	#	print("Portal: "+name)
	#	print("  Global Position: "+str(global_position))
	#	print("  Mouse  Position: "+str(get_global_mouse_position()))
	
	# portal                 Vector2(246.0, -625.0)
	# mouse/target portal    Vector2(502.3478, -370.5258)
	# mouse - portal = vector from us to target
	# = Vector2(256.3478, 254.47421)

# keeps trask of if there are currently polygons displayed in the view
var polygons_in_view:bool = false

@warning_ignore("shadowed_variable")
func set_view(target:Node):
	# TODO: There is a flicker than you can quite easily see
	# for complex shapes and certain target positions.
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), $line.points, get_local_bounds())
	
	for i in polygons:
		var new = $texture_storage.duplicate() # Polygon2D.new()
		new.polygon = i
		new.show()
		
		# Copy the viewport texture over from the storage node to the new polygon.
		#new.texture = $texture_storage.texture
		
		# add a border for debugging
		var border = Line2D.new()
		border.default_color = Color.RED
		border.width = 4.0
		border.points = new.polygon # use the polygon border to make the line
		border.add_point(new.polygon.get(0)) # and connect it up with the last point again
		new.add_child(border)
		
		$view.add_child(new)
	
	# record the fact that there are polygons in the view that need to
	# be cleared if this portal leaves the screen.
	polygons_in_view = true


func clear_view():
	"""
	Clears the portal view by deleting all view polygons.
	"""
	for i in $view.get_children():
		$view.remove_child(i)
		i.queue_free()
	
	polygons_in_view = false

func get_local_bounds(margin:float = 64):
	"""
	Returns the viewport rect in local space and expands it a little for error margin.
	"""
	# this is the viewport rect in global coordinates.
	var global_rect = (get_viewport_rect() * get_viewport_transform()).grow(margin)
	
	# convert to local coordinates before returning.
	return Core.tools.to_local_rect(self, global_rect)
