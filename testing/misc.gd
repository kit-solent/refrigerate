extends Node2D

func _ready():
	var lines:Array[PackedVector2Array] = []
	for child in $node_2d.get_children():
		lines.append(child.points)
	
	var new_lines = Core.tools.merge_lines(lines)
	print(new_lines)
	for n in new_lines:
		var new = Line2D.new()
		new.points = n
		$trala.add_child(new)
