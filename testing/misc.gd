extends Node2D

func _ready():
	var segment = $line_2d.points
	var point = $marker_2d.position
	print(Core.tools.segment_has_point(segment, point))
	print(Core.tools.segment_has_point2(segment, point))
	
	return
	var lines:Array[PackedVector2Array] = []
	for child in $node_2d.get_children():
		lines.append(child.points)
	
	var new_lines = Core.tools.merge_lines(lines)
	print(new_lines)
	for n in new_lines:
		var new = Line2D.new()
		new.points = n
		$trala.add_child(new)
