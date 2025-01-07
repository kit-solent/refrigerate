extends Node2D

@export var k:float = 0.015
@export var d:float = 0.03
@export var spread:float = 0.0002
@export var border_thickness:float = 1.1
@export var splash_clamp:float = 6.0

var spring_scene = preload("res://features/water/spring.tscn")
var passes = 8
var distance_between_springs = 80

# stores the sections of polygon that make up the body of the water.
# between each section and after the last section there will be a
# spring group. This means there should be the same number of polygon_parts
# as spring groups or, alternativly there should be no surface sections for
# an entirely enclosed water body.
var polygon_parts:Array[PackedVector2Array] = []

# the water body starts with nothing so doesn't have a surface.
var has_surface:bool = false

func _physics_process(_delta):
	for group in $spring_groups.get_children():
		# exclude the first child as that is the path
		var springs = group.get_children().slice(1)
		for i in springs:
			i.water_update(k, d)
		
		var left_deltas = []
		var right_deltas = []
		
		for i in range(springs.size()):
			left_deltas.append(0)
			right_deltas.append(0)
		
		for p in range(passes):
			for i in range(springs.size()):
				# if the spring has a left neibour
				if i > 0:
					# calculate the distance from the ith spring to its left neibour.
					left_deltas[i] = spread * (springs[i].position.y - springs[i-1].position.y)
					springs[i-1].velocity += left_deltas[i]
				
				# if the spring has a right neibour
				if i < springs.size() - 1:
					# calculate the distance from the ith spring to its right neibour.
					right_deltas[i] = spread * (springs[i].position.y - springs[i+1].position.y)
					springs[i+1].velocity += right_deltas[i]
	
	draw_water_body()

func splash(speed, group, spring):
	# first check the group exists.
	if group >= 0 and group < $spring_groups.get_child_count():
		var group_node = $spring_groups.get_child(group)
		# then check the spring exists in that group. Offset by 1 to exclude the SmoothPath.
		if spring+1 >= 0 and spring+1 < group_node.get_child_count():
			var spring_node = group_node.get_child(spring + 1)
			# then apply the speed to the given spring.
			spring_node.velocity += speed
			# clamp the velocity of the spring.
			spring_node.velocity = clamp(spring_node.velocity, -splash_clamp, splash_clamp)

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
			var group = $spring_groups.get_child(polygon_part)
			# the first child in any group is it's curve.
			var curve = group.get_child(0)
			var surface_points = curve.curve.get_baked_points()
			
			# add the points to the polygon
			temp_polygon.append_array(surface_points)
	
	$polygon.polygon = temp_polygon

func update_borders():
	for group in $spring_groups.get_children():
		var border = group.get_child(0)
		var curve = Curve2D.new()
		
		for spring in group.get_children().slice(1):
			curve.add_point(spring.position)
		
		border.curve = curve
		border.smooth(true)
		border.queue_redraw()

func set_polygon(polygon_sections:Array[PackedVector2Array]):
	"""
	poly should be an array of PackedVector2Arrays.
	The first PackedVector2Array will be a regular
	polygon section and every odd indexed (1, 3, 5, etc)
	will be a surface section.
	"""
	# if there is more than 1 section then there will be at least 1 surface section.
	has_surface = len(polygon_sections) > 1
	
	# set the collision detection polygon
	for section in polygon_sections:
		$area/collision_polygon_2d.polygon.append_array(section)
	
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
			#TODO: border.color = border_color and for spline length
			border.width = border_thickness
			border.name = "border"
			new_group.add_child(border)
			
			# add the points from the polygon_section as springs.
			for point in polygon_section:
				var new_spring = spring_scene.instantiate()
				# name the springs starting with spring0, spring1, spring2, etc
				# subtract 1 to account for the SmoothPath
				new_spring.name = "spring" + str(new_group.get_child_count() -1)
				new_spring.position = point
				new_spring.initialise()
				new_spring.set_collision_width(distance_between_springs)
				new_spring.splash.connect(splash.bind($spring_groups.get_child_count(), new_group.get_child_count() -1))
				new_group.add_child(new_spring)
				
			$spring_groups.add_child(new_group)
		else:
			polygon_parts.append(polygon_section)
		
		surface = not surface
	
	# TODO: Could trigger a redraw here?
