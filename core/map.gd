extends TileMap

func load_tiles():
	for layer in range(get_layers_count()):
		for cell in get_used_cells_by_id(layer,0):
			pass

func load_tile(layer:int, pos:Vector2i):
	pass

func find_connected_like_cells(layer:int, pos:Vector2i, exclude:Array=[]):
	"""
	Returns all cells adjacently connected to the given cell of the same id on the same layer.
	"""
	var results=[]
	for i in [Vector2i(0,1),Vector2i(1,0),Vector2i(0,-1),Vector2i(-1,0)]:
		if pos+i in exclude:
			continue
		if get_cell_source_id(layer, pos+i) == get_cell_source_id(layer,pos):
			results.append(pos+i)
			results+=find_connected_like_cells(layer,pos+i,results+exclude)
	return results

func create_shape_from_cells(cells:Array) -> ConvexPolygonShape2D:
	var shape=ConvexPolygonShape2D.new()
	var points=[]
	for i in cells:
		points.append(map_to_local(i))
		points.append(map_to_local(i)+Vector2(tile_set.tile_size.x,0))
		points.append(map_to_local(i)+Vector2(0,tile_set.tile_size.y))
		points.append(map_to_local(i)+Vector2(tile_set.tile_size))
	shape.set_point_cloud(points)
	return shape

func _reay():
	$area_2d.add_child(CollisionPolygon2D.new())
	$area_2d.get_child(0).polygon=create_shape_from_cells(find_connected_like_cells(0,Vector2i(16,-16))).points
