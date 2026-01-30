extends Node2D

func _ready():
	var new_poly = Geometry2D.clip_polygons($polygons/polygon_2d.polygon,$polygons/polygon_2d3.polygon)
	var poly = Polygon2D.new()
	poly.polygon = new_poly
	add_child(poly)
	poly.color = Color(1.0, 0.0, 0.0, 1.0)
	print(new_poly)
	poly.show()
