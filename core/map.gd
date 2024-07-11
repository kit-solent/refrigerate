extends TileMap

func merge_polygons(list:Array):
	var result=[]
	while true:
		var merged_any=false
		for i in range(1,len(list)): # loop over all indexs in the list except 0 (the first one)
			var merge=Geometry2D.merge_polygons(list[0],list[i])
			if len(merge)==1: # if the merge was a success...
				list.remove_at(i)
				list[0]=merge[0]
				merged_any=true
				break
		if not merged_any:
			# if none of the polygons merged then move on.
			result.append(list.pop_front())
		if len(list)<=1:
			if len(list)==1:
				result.append(list[0])
			break
	return result

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
		shapes=merge_polygons(shapes)
		for i in shapes:
			var new=Area2D.new()
			new.add_child(CollisionPolygon2D.new())
			new.get_child(0).polygon=Geometry2D.offset_polygon(i,tile_set.tile_size.x/2)
			add_child(new)

func _ready():
	create_regions()
