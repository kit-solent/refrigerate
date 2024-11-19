extends TileMapLayer

@onready var mode_overides = get_parent().get_node("meta/mode_overides")

func create_regions(id:int):
	"""
	Returns an array of polygons of the merged tiles of the given id.
	"""
	var shapes:Array[PackedVector2Array] = []
	for cell in get_used_cells_by_id(id):
		# Construct a polygon (square) clockwise from the four corners of the cell.
		shapes.append(PackedVector2Array([
			# map_to_local returns the cell centre.
			map_to_local(cell)+Vector2(-tile_set.tile_size.x/2.0,-tile_set.tile_size.y/2.0), # top left. ( ⌜ )
			map_to_local(cell)+Vector2(+tile_set.tile_size.x/2.0,-tile_set.tile_size.y/2.0), # top right ( ⌝ )
			map_to_local(cell)+Vector2(+tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom right ( ⌞ )
			map_to_local(cell)+Vector2(-tile_set.tile_size.x/2.0,+tile_set.tile_size.y/2.0), # bottom left ( ⌟ )
		]))
	
	# merge the polygons
	shapes = Core.tools.merge_polygons(shapes)
	
	return shapes

func clear_regions():
	for region in mode_overides.get_children():
		mode_overides.remove_child(region)
		region.queue_free()

func update_regions():
	clear_regions()
	
	for id in [1, 2, 3, 4, 5]: # these are the gravity regions.
		var regions = create_regions(id)
		for region in regions:
			var overide = Node.new()
			overide.add_to_group(tile_set.get_source(id).resource_name)
			mode_overides.add_child(overide)
	

func _ready():
	update_regions()
