extends Node2D

@export var k:float = 0.015
@export var d:float = 0.03
@export var spread:float = 0.0002
@export var border_thickness:float = 1.1

var spring_scene = preload("res://water/spring.tscn")
var passes = 8
var distance_between_springs = 80

# stores the sections of polygon that make up the body of the water.
# between each section and after the last section there will be a
# spring group. This means there should be the same number of polygon_parts
# as spring groups or, alternativly there should be no surface sections for
# an entirely enclosed water body.
var polygon_parts:Array[PackedVector2Array] = []
var has_surface:bool

func _ready():
	$border.width = border_thickness
	
	for i in range($springs.get_child_count()):
		var thingy = $springs.get_children()[i]
		thingy.initialise(i)
		thingy.set_collision_width(distance_between_springs)
		thingy.splash.connect(splash)

func _physics_process(_delta):
	$character_body_2d.velocity=get_global_mouse_position()-$character_body_2d.global_position
	$character_body_2d.move_and_slide()
	
	var springs = $springs.get_children()
	for i in springs:
		i.water_update(k, d)
	
	var left_deltas = []
	var right_deltas = []
	
	for i in range(springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
	
	for p in range(passes):
		for i in range(springs.size()):
			if i > 0:
				# calculate the distance from the ith spring to its left neibour.
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			if i < springs.size() - 1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
	
	draw_water_body()

func splash(index, speed):
	if index >= 0 and index < $springs.get_child_count():
		$springs.get_children()[index].velocity += speed

func draw_water_body():
	# the borders must be updated even if they are not shown as they are used
	# to draw the surface sections.
	if has_surface:
		update_borders()
	
	# use a temporary polygon variable instead of $polygon.polygon
	# to avoid multiple redraw calls.
	var temp_polygon:PackedVector2Array = PackedVector2Array([])
	for polygon_part in range(len(polygon_parts)):
		# add the polygon section
		for point in polygon_parts[polygon_part]:
			temp_polygon.append(point)
		
		# now add the surface section
		if has_surface:
			# get the spring group using the polygon_part index
			var group = $spring_groups.get_children()[polygon_part]
			# the first child in any group is it's curve.
			var curve = group.get_children()[0]
			var surface_points = curve.curve.get_baked_points()
			
			# add the points to the polygon
			temp_polygon.append_array(surface_points)
	
	$polygon.polygon = temp_polygon

func update_borders():
	for i in range($spring_groups.get_child_count()):
		pass
	
	var curve = Curve2D.new()
	
	for spring in $springs.get_children():
		curve.add_point(spring.position)
	
	$border.curve = curve
	$border.smooth(true)
	$border.queue_redraw()

func set_polygon(polygon_sections:Array[PackedVector2Array]):
	"""
	poly should be an array of PackedVector2Arrays.
	The first PackedVector2Array will be a regular
	polygon section and every odd indexed (1, 3, 5, etc)
	will be a surface section.
	"""
	# if there is more than 1 section then there will be at least 1 surface section.
	has_surface = len(polygon_sections) > 1
	
	# clear the existing springs and polygon sections.
	for i in $spring_groups.get_children():
		$spring_groups.remove_child(i)
		i.queue_free()
	
	polygon_parts = []
	$polygon.polygon = PackedVector2Array([])
	
	var surface = false
	for polygon_section in polygon_sections:
		if surface:
			var new_group = Node2D.new()
			# name the groups starting with group0, group1, group2, etc
			new_group.name = "group" + str($spring_groups.get_child_count())
			
			# add the border for the group
			var border = SmoothPath.new()
			#TODO: border.color = border_color and for width/spline length
			border.name = "border"
			new_group.add_child(border)
			
			# add the points from the polygon_section as springs.
			for point in polygon_section:
				var new_spring = spring_scene.instantiate()
				# name the springs starting with spring0, spring1, spring2, etc
				new_spring.name = "spring" + str(new_group.get_child_count())
				new_spring.position = point
				new_group.add_child(new_spring)
				
			$spring_groups.add_child(new_group)
		else:
			polygon_parts.append(polygon_section)
		
		surface = not surface
		
		# TODO: Could trigger a redraw here?
