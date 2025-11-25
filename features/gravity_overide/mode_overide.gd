extends Area2D

var gravity_shader = preload("res://core/resources/shaders/gravity.gdshader")

func _ready():
	$on_screen.rect = Core.tools.line_bounds($visuals.polygon).grow(16)
	$line.hide()

func _on_body_entered(body):
	if body.is_in_group("players"):
		body.set_gravity_direction(gravity_direction)

func set_polygon(polygon:PackedVector2Array):
	if not $collision:
		printerr("The ModeOveride must be added to the scene tree before set_polygon can be called.")
		return ERR_DOES_NOT_EXIST
	
	$collision.polygon = polygon
	$visuals.polygon = polygon

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
		
		# find a list of lines representing the cross over between the mode overide area and the viewport bounds.
		var lines = Geometry2D.intersect_polygons($visuals.polygon, Core.tools.rect_to_polygon(Core.tools.get_local_bounds(self,0)))
		
		# for each line add it to $lines
		for line in lines: # TODO: The lines should go along the border of the screen and then along the border of the mode overide area.
			var new = $line.duplicate()
			new.show()
			new.points = line
			
			# connect it up (NOTE: new.points.append doesn't work. Not quite sure why.)
			new.add_point(new.points[0])
			new.add_point(new.points[1]) # Without this the connected line ends aren't quite smooth. There's a pixel/corner missing.
			$lines.add_child(new)
