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

var delay_a_frame = true

func _process(_delta:float):
	# putting this in ready doesn't work for some reason so do it on the
	# first frame that _process runs.
	if delay_a_frame:
		$sub_viewport.size = get_local_bounds().size
		delay_a_frame = false
	
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
		$sub_viewport/camera_2d.global_position = pair.global_position
		
		# update the view
		if $on_screen_notifier.is_on_screen():
			set_view(target)

# keeps trask of if there are currently polygons displayed in the view
var polygons_in_view:bool = false

@warning_ignore("shadowed_variable")
func set_view(target:Node):
	# TODO: There is a flicker than you can quite easily see
	# for complex shapes and certain target positions.
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), $line.points, get_local_bounds())
	
	for i in polygons:
		# duplicate the texture storage node with all
		# its properties then replace the polygon.
		var new = $texture_storage.duplicate()
		new.polygon = i
		new.show()
		
		# Shift the texture origin from the centre of the portal
		# to the top left of the viewport rect (plus margin).
		# This puts the whole texture on screen.
		# We can't use get_local_bounds().position because that
		# is affected by the camera smoothing.
		new.texture_offset = -$texture_storage.texture.get_size()/2
		
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
