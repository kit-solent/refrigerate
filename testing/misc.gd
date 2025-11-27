extends Node2D

func _ready():
	var polygons:Array[PackedVector2Array] = []
	for child in $polygons.get_children():
		if child is Polygon2D:
			polygons.append(child.polygon)
	
	var m_poly = Core.tools.merge_polygons(polygons)
	for i in m_poly:
		var new = Polygon2D.new()
		new.polygon = i
		$m_poly.add_child(new)
