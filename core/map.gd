extends TileMapLayer

@onready var mode_overides = get_parent().get_node("meta/mode_overides")
var mode_overide_scene = preload("res://core/resources/ModeOveride.tscn")
var wader_scene = preload("res://features/water/water.tscn")

func _process(delta):
	if Input.is_action_just_pressed("debug key"):
		print("hup")
		$explosion.run()

func create_regions(id:int, atlas:Array=[], remove:bool=true):
	"""
	Returns an array of polygons of the merged tiles of the given id.
	If atlas has items then only use tiles with atlas positions in atlas.
	If remove is true tiles will be removed from the tilemap. Otherwise... they won't.
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
			map_to_local(cell)+Vector2(+tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom right ( ⌞ )
			map_to_local(cell)+Vector2(-tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom left ( ⌟ )
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
	This is the format expected by the water setup method.
	"""
	var old_regions = create_regions(id, [], false) # don't delete the regions yet.
	var new_regions:Array[PackedVector2Array] = []
	for region in old_regions:
		new_regions.append(region)
		
		var stup = false
		while true:
			pass
	
	for cell in get_used_cells_by_id(id):
		set_cell(cell) # now delete all the tiles.
	
	return []

func clear_regions():
	for region in mode_overides.get_children():
		mode_overides.remove_child(region)
		region.queue_free()

func update_regions():
	clear_regions()
	
	for id in [1, 2, 3, 4, 5]: # these are the gravity regions.
		var regions = create_regions(id)
		for region in regions:
			var overide = mode_overide_scene.instantiate()
			overide.set_mode(id - 1)
			overide.set_polygon(region)
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
	
	#TODO: This is a temporary test of water.tscn
	var poly:Array[PackedVector2Array] = [
		PackedVector2Array([
			Vector2(9, -2) * 64,
			Vector2(6, -2) * 64,
			Vector2(6, -1) * 64,
			Vector2(5, -1) * 64,
			Vector2(5,  1) * 64,
			Vector2(-5, 1) * 64,
			Vector2(-5, 0) * 64,
			Vector2(-6, 0) * 64,
			Vector2(-6, -2) * 64,
		]),
		PackedVector2Array([
			Vector2(-6, -3) * 64,
			Vector2(-5, -3) * 64,
			Vector2(-4, -3) * 64,
			Vector2(-3, -3) * 64,
			Vector2(-2, -3) * 64,
			Vector2(-1, -3) * 64,
		]),
		PackedVector2Array([
			Vector2(-1, -2) * 64,
			Vector2(-3, -2) * 64,
			Vector2(-3, -1) * 64,
			Vector2(3, -1) * 64,
			Vector2(3, -2) * 64,
			Vector2(4, -2) * 64,
			Vector2(4, -3) * 64,
		]),
		PackedVector2Array([
			Vector2(5, -3) * 64,
			Vector2(6, -3) * 64,
			Vector2(7, -3) * 64,
			Vector2(8, -3) * 64,
			Vector2(9, -3) * 64,
		])
	]
	$water.set_polygon(poly)
