extends Area2D

var gravity_shader = preload("res://core/resources/shaders/gravity.gdshader")
var empty_edges:Array[PackedVector2Array] = []

func _ready():
	$on_screen.rect = Core.tools.line_bounds($visuals.polygon).grow(16)
	$_line_template.hide()

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.set_gravity_direction(gravity_direction)

func set_polygon(polygon:PackedVector2Array) -> Error:
	if not $collision:
		printerr("The ModeOveride must be added to the scene tree before set_polygon can be called.")
		return ERR_DOES_NOT_EXIST
	
	$collision.polygon = polygon
	$visuals.polygon = polygon
	
	$on_screen.rect = Core.tools.line_bounds(polygon).grow(16)
	
	return OK

func set_empty_edges(edges:Array[PackedVector2Array]):
	empty_edges = edges

func change_gravity_direction(direction:Vector2):
	gravity_direction = direction
	#$visuals.material.shader = gravity_shader # TODO: Learn how to use shaders
	
	if direction == Vector2.ZERO:
		$visuals.color = Core.topdown_color
	else:
		$visuals.color = Core.platformer_color

func _process(_delta:float):
	if $on_screen.is_on_screen():
		# remove the preexisting lines
		for line in $lines.get_children():
			$lines.remove_child(line)
			line.queue_free()
		
		# take the part of the visuals polygon that is on screen as an array of polygons
		var polygons = Geometry2D.intersect_polygons($visuals.polygon, Core.tools.rect_to_polygon(Core.tools.get_local_bounds(self,0)))
		
		# for each polygon, append the first point to turn it into a line and clip it against the empty_edges array
		var lines:Array[PackedVector2Array] = []
		for polygon in polygons:
			var new_polygon = polygon
			new_polygon.append(new_polygon[0])
			
			# clipping the line can result in multiple lines so store them in an array
			var clipped_polygons:Array[PackedVector2Array] = Core.tools.clip_line_sets([new_polygon], empty_edges)
			
			# then add that array to the new_polygons
			lines.append_array(clipped_polygons)
		
		# for each line add it to $lines
		for line in lines:
			var new:Line2D = $_line_template.duplicate()
			new.show()
			new.points = line
			
			# add the 2nd point of the line on again so that the end corner displays properly
			# new.add_point(new.points[1]) # TODO: Fix stuff first
			
			$lines.add_child(new)
