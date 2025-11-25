## For a seamless effect the target portal should be the same shape as
## this one.
class_name Portal extends Node2D

## A portal's pair is the portal that it 'displays'
## and that is the telleportation destination.
@export var pair:Portal

## When true the portal projects a view of its target location, otherwise
## no view is shown.
@export var view_enabled:bool = true

## When true the portal is able to transport bodies to the target location.
@export var portal_enabled:bool = true

## When true, draws a border around each of the view polygons. Used for 
## debugging purposes.
@export var debugging_border:bool = false

@onready var target:Node = Core.main.get_player()

## Emitted when this portal telleports a node.
signal telleported(node:Node)

@onready var line:Line2D = $_line

func _ready():
	if not pair:
		push_warning("Portal "+name+" has no pair portal. This portal will not work until it has a pair.")
	
	$sub_viewport.world_2d = get_viewport().world_2d
	
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
		
	# find the bounding rectangle of the line, expand it for error margin, and assign it to the on screen notifier.
	$on_screen_notifier.rect = Core.tools.line_bounds(line.points).grow(64)
	
	await get_tree().process_frame # Not sure why this is required but it doesn't work without it.
	$sub_viewport.size = Core.tools.get_local_bounds(self).size

# Stores the position of the target in local
# coordinates as of the last frame. Used to
# see where they have come from.
@onready var prev_target_pos:Vector2 = to_local(target.global_position)

func _process(_delta:float):
	# Clear any existing polygons to prevent polygons from lingering after the portal
	# has left the screen. These can be picked up by other portals which looks bad.
	if polygons_in_view:
		clear_view()
	
	# the portal is only drawn if on the local screen. This works with multiplayer, only showing the portal to those who can see it.
	# the portal should also only be drawn if it's target is within a certain distance of the portal.
	if pair and (not skip_frame) and portal_enabled:
		set_location(prev_target_pos, target)
		
	# update the view
	if pair and $on_screen_notifier.is_on_screen() and view_enabled:
		set_view(target)
	
	prev_target_pos = to_local(target.global_position)
	skip_frame = false

## If true then the portal will not telleport bodies until the next frame.
var skip_frame = false
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
	
	$sub_viewport/camera.global_position = pair.global_position
	
	var polygons = Core.tools.cast_polygons(to_local(target.global_position), line.points, Core.tools.get_local_bounds(self))
	
	for polygon in polygons:
		# duplicate the texture storage node with all
		# its properties then replace the polygon.
		var new = $texture_storage.duplicate()
		new.polygon = polygon
		new.show()
		
		# Shift the texture origin from the centre of the portal to the top left of the viewport
		# rect (plus margin), putting the whole texture on screen. NOTE that get_local_bounds().position
		# is affected by camera smoothing so can't be used here.
		new.texture_offset = -$texture_storage.texture.get_size()/2
		
		# add a border for debugging
		if debugging_border:
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

@warning_ignore("shadowed_variable")
func set_location(prev_pos:Vector2, target:Node):
	var target_pos = to_local(target.global_position)
	
	# get a list of all intersections between the one-frame motion line of
	# the target (from last frame to this frame) with the portal line.
	var intersections = Core.tools.lines_intersect(
		PackedVector2Array([prev_pos, target_pos]),
		$line.points
	)
	
	# TODO: If a single move takes the player through the portal twice then we may want
	# them to be taken there and back again in the same frame (edge case).
	if len(intersections) > 0:
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

func clear_view():
	"""
	Clears the portal view by deleting all view polygons.
	"""
	for i in $view.get_children():
		$view.remove_child(i)
		i.queue_free()
	
	polygons_in_view = false

func enable(view:bool = true, portal:bool = true):
	"""
	Enables or dissables the view and portal aspects of this portal.
	If `view` is true then the view of the target location projected by
	this portal is enabled and if false then this view is dissabled.
	If `portal` is true then the ability of this portal to telleport
	bodies to the target location is enabled and if false it is dissabled.
	"""
	view_enabled = view
	portal_enabled = portal

func set_pair(pair_portal:Portal):
	"""
	Sets the pair portal for this portal.
	"""
	pair = pair_portal
