extends Node2D

func _ready():
	var clip = Core.tools.clip_segments(
		PackedVector2Array([$line_2d.points[0], $line_2d.points[1]]),
		PackedVector2Array([$line_2d2.points[0], $line_2d2.points[1]])
	)
	print(clip)
	
	$line_2d3.points = clip[0]
	$line_2d3.show()
	if len(clip) == 2:
		$line_2d4.points = clip[1]
		$line_2d4.show()
