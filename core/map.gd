extends TileMap

func merge_lots(list:Array):
	for i in range(1,len(list)): # loop over all indexs in the list except 0 (the first one)
		var merge=Geometry2D.merge_polygons(list[0],list[i])
		if len(merge)==1: # if the merge was a success...
			pass


func create_regions():
	for id in [1,2,3,4,5]:
		var shapes:Array
		for cell in get_used_cells_by_id(0,id):
			# Construct a polygon (square) clockwise from the four corners of the cell.
			shapes.append(PackedVector2Array([
				# map_to_local returns the cell centre.
				map_to_local(cell)+Vector2(-tile_set.tile_size.x/2,-tile_set.tile_size.y/2), # top left. ( ⌜ )
				map_to_local(cell)+Vector2(+tile_set.tile_size.x/2,-tile_set.tile_size.y/2), # top right ( ⌝ )
				map_to_local(cell)+Vector2(+tile_set.tile_size.x/2,+tile_set.tile_size.y/2), # bottom right ( ⌞ )
				map_to_local(cell)+Vector2(-tile_set.tile_size.x/2,+tile_set.tile_size.y/2), # bottom left ( ⌟ )
			]))
		# now we need to join the seperate polygons.
		while true:
			var polygons_to_remove = []
			for child_index in len(shapes):
				var polygon1:PackedVector2Array = shapes[child_index]
				for child_subindex in child_index-1:
					var polygon2:PackedVector2Array = shapes[child_subindex]
					var merged_polygon = Geometry2D.merge_polygons(polygon1,polygon2)
					if merged_polygon.size() != 1:
						continue
					polygon2 = merged_polygon[0]
					polygons_to_remove.append(polygon1)
					break
			if polygons_to_remove.size() == 0:
				break
			for polygon_to_remove in polygons_to_remove:
				shapes.erase(polygon_to_remove)
		for i in shapes:
			var new=Area2D.new()
			new.add_child(CollisionPolygon2D.new())
			new.get_child(0).polygon=i
			add_child(new)

func _ready():
	create_regions()
