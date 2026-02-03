@icon("res://assets/icons/map.svg")
class_name Map extends TileMapLayer

@onready var mode_overides = get_parent().get_node("meta/mode_overides")
var mode_overide_scene = preload("res://features/gravity_overide/mode_overide.tscn")
var wader_scene = preload("res://features/water/water.tscn")

func create_regions(id:int, atlas:Array=[], remove:bool=true) -> Array[PackedVector2Array]:
	"""
	Returns an array of polygons of the merged tiles of the given id.
	If `atlas` has items then only use tiles with atlas positions in `atlas`.
	If `remove` is true then tiles will be removed from the tilemap.
	NOTE: Because polygons are generated from a grid of tiles they never overlap so clipping is not required.
	"""
	var shapes:Array[PackedVector2Array] = []
	for cell in get_used_cells_by_id(id):
		if len(atlas)>0 and (not get_cell_atlas_coords(cell) in atlas):
			continue # skip the cell if it is not in the atlas.
		
		# Construct a polygon (square) clockwise from the four corners of the cell.
		shapes.append(PackedVector2Array([
			# map_to_local returns the cell centre.
			map_to_local(cell)+Vector2(-tile_set.tile_size.x/2.0,-tile_set.tile_size.y/2.0), # top left. ( ⌜ )
			map_to_local(cell)+Vector2(+tile_set.tile_size.x/2.0,-tile_set.tile_size.y/2.0), # top right ( ⌝ )
			map_to_local(cell)+Vector2(+tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom right ( ⌟ )
			map_to_local(cell)+Vector2(-tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom left ( ⌞ )
		]))
		
		# remove the cell
		if remove:
			set_cell(cell)
	
	# merge the polygons
	shapes = Core.tools.merge_polygons(shapes)
	
	return shapes

func create_water_regions(id:int):
	"""
	Like create_regions but takes into account surface points
	and returns: Array[Array[Array[Vector2]]]
	regions[
		region[
			[sub surface points],
			[surface points],
			[sub surface points],
			etc,
		],
		region2[
			etc
		]
	]
	TODO: Change this format so that there is a regular polygon deffining the edge of the water region
	and another polygon defining the points on that first polygon which are special (surface).
	This is the format expected by the water setup method.
	"""
	var old_regions = create_regions(id, [], false) # don't delete the regions yet.
	var new_regions:Array[PackedVector2Array] = []
	for region in old_regions:
		new_regions.append(region)
		
		var _stup = false
		while true:
			pass
	
	for cell in get_used_cells_by_id(id):
		set_cell(cell) # now delete all the tiles.
	
	return []

func clear_regions():
	"""
	Delete all the mode overide regions.
	"""
	for region in mode_overides.get_children():
		mode_overides.remove_child(region)
		region.queue_free()

func update_regions():
	clear_regions()
	
	 # gravity regions
	for id in [1]:#, 2, 3, 4, 5]:
		var gravity_dir
		if id == 1:
			# account for top down mode.
			gravity_dir = Vector2.ZERO
		else:
			# generate the gravity direction by rotating the DOWN vector anticlockwise
			# (id - 2) times. (Because index 2 is the down direction).
			gravity_dir = Vector2.DOWN.rotated((TAU/4) * (id - 2))
		
		# find the polygons representing the mode overide areas
		var regions = create_regions(id)
		
		var connected_edges = Core.tools.find_connected_edges(Core.tools.polygons_to_lines(regions))
		
		for index in range(len(regions)):
			var overide = mode_overide_scene.instantiate()
			overide.change_gravity_direction(gravity_dir)
			overide.set_polygon(regions[index])
			overide.set_empty_edges(connected_edges[index])
			mode_overides.add_child(overide)
	
	# add the water.
	var water = create_water_regions(6)
	for region in water:
		var new = wader_scene.instantiate()
		new.set_polygon(region)
		get_parent().get_node("terrain").add_child(new)
	# TODO: Currently this code adds all new water regions at the origin
	# and positions the polygon points accordingly. This correctly places
	# the polygon but means the position of the water node is at the origin
	# This should be changed so that the origin of the water body is the top
	# left of the minimum containing rect of the water tiles. The polygon
	# points should then be positioned accordingly.

func _ready():
	update_regions()
