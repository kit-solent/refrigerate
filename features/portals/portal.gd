extends Node2D

## A portal's pair is the portal that it 'displays'
## and that is the telleportation destination.
@export var pair:Node2D

@onready var target:Node = Core.main.get_player()

## Emitted when this portal telleports a node.
signal telleported(node:Node)

## If true then the portal will not telleport bodies until the next frame.
var skip_frame = false
@onready var line:Line2D = $_line

func _ready():
	$sub_viewport.world_2d = get_viewport().world_2d
	
	# find the bounding rectangle of the line, expand it for error margin, and assign it to the on screen notifier.
	$on_screen_notifier.rect = Core.tools.line_bounds($line.points).grow(64)
	
	# check for a Line2D to use as the portal line or use the default.
	var extra_lines = 0
	for child in get_children():
		if (child is Line2D) and (not child == $_line):
			if line == $_line:
				# if we are still using the default line the replace it.
				line = child
				$_line.hide()
				$_line.queue_free()
			else:
				# otherwise we have found more than 1 non default line child.
				# the first one is used and a warning given
				extra_lines += 1
	
	if extra_lines > 0:
		push_warning("Portal "+name+" has "+str(extra_lines + 1)+" Line2D children. Only the first of these ("+line.name+") will be used for the portal line.")

var delay_a_frame = true

# Stores the position of the target in local
# coordinates as of the last frame. Used to
# see where they have come from.
@onready var prev_target_pos:Vector2 = to_local(target.global_position)

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
		
		# check if the player needs telleporting.
		var target_pos = to_local(target.global_position) # get the current target position
		var intersections = Core.tools.lines_intersect(
			PackedVector2Array([prev_target_pos, target_pos]), # construct a line from `prev_target_pos` to `target_pos`
			$line.points # and count the times it cuts through the portal line.
		)
		
		if len(intersections) > 0 and (not skip_frame):
				# if the players movement in the last frame takes them through the portal
				# line then teleport them to the new location with the same local offset.
				target.global_position = pair.global_position + target_pos
				
				# telleport the camera without smoothing. As camera positioning is done in
				# the ingame script we need to move it manually here.
				Core.main.get_camera().global_position = target.global_position
				Core.main.get_camera().reset_smoothing()
				
				# let the universe know that we just telleported the target.
				telleported.emit(target)
				
				# tell our pair not to send the target straight back again.
				pair.skip_telleportation_frame()
		
		# update the view
		if $on_screen_notifier.is_on_screen():
			set_view(target)
	
	prev_target_pos = to_local(target.global_position)
	skip_frame = false

func skip_telleportation_frame():
	"""
	When called, tells this portal not to transport bodies this frame.
	This is to prevent 'double telleports' where the motion of telleporting
	causes the body to be taken straight back again.
	"""
	skip_frame = true

# keeps trask of if there are currently polygons displayed in the view
var polygons_in_view:bool = false

@warning_ignore("shadowed_variable")
func set_view(target:Node):
	# TODO: There is a flicker than you can quite easily see
	# for complex shapes and certain target positions.
	
	# add new polygons
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), line.points, get_local_bounds())
	
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
		if false:
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
