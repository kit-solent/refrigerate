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
	"""
	Sets the bounding line for this mode overide. Note that dispite the
	name the argument to this method is a bounding line where the first
	point in the array included again at the end.
	"""
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

# TODO: for fixing the line borders: find all lines with same endpoints
# and have one mode_overide "steal" the line for itself, joining it to
# the existing line.
# OR: just extend the line ends by half a line width so that they fully
# overlap.

func _draw():
	if Core.debug_state:
		# show the on screen notifier rectangle
		draw_rect($on_screen.rect, color, false, 2)

var color = Color.GREEN
func _process(_delta:float):
	queue_redraw()
	if Core.debug_frame:
		print("Is on screen: "+str($on_screen.is_on_screen()))
	
	color = Color.GREEN
	if $on_screen.is_on_screen():
		color = Color.RED
		# remove the preexisting lines
		for line in $lines.get_children():
			$lines.remove_child(line)
			line.queue_free()
		
		# take the part of the visuals polygon that is on screen as an array of polygons
		var polygons = Geometry2D.intersect_polygons($visuals.polygon, Core.tools.rect_to_polygon(Core.tools.get_local_bounds(self,0)))
		# for each polygon, append the first point to turn it into a line and clip it against the empty_edges array
		var lines:Array[PackedVector2Array] = []
		
		for polygon in polygons:
			var line = polygon
			line.append(line[0])
			if Core.debug_frame:
				print("line: "+str(line))
				print(Core.tools.clip_line_sets([[
					Vector2(192.0, 192.0),
					Vector2(0.0, 192.0),
					Vector2(0.0, -64.0),
					Vector2(192.0, -64.0),
					Vector2(192.0, 192.0)]
					], []))
			
			# clipping the line can result in multiple lines so store them in an array
			var clipped_lines:Array[PackedVector2Array] = Core.tools.clip_line_sets([line], empty_edges)
			
			# then add that array to the new_polygons
			lines.append_array(clipped_lines)
		
		# for each line add it to $lines
		for line in lines:
			if Core.debug_frame:
				print("creating a new line on screen")
			var new:Line2D = $_line_template.duplicate()
			
			# extend the line ends to fully cover the end pixel
			var extended_line = Core.tools.extend_line_ends(line, new.width/2)
			new.points = extended_line
			new.show()
			
			$lines.add_child(new)
