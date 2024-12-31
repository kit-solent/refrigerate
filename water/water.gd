extends Node2D

@export var k:float = 0.015
@export var d:float = 0.03
@export var spread:float = 0.0002
@export var border_thickness:float = 1.1

var spring_scene = preload("res://water/spring.tscn")
var passes = 8
var distance_between_springs = 80
var polygon = []

func _ready():
	$border.width = border_thickness
	
	for i in range(len($springs.get_children())):
		var thingy = $springs.get_children()[i]
		thingy.initialise(i)
		thingy.set_collision_width(distance_between_springs)
		thingy.splash.connect(splash)

func _physics_process(_delta):
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
	
	new_border()
	draw_water_body()

func splash(index, speed):
	if index >= 0 and index < $springs.get_children().size():
		$springs.get_children()[index].velocity += speed

func draw_water_body():
	# extract all the surface points from the curve
	var surface_points:PackedVector2Array = $border.curve.get_baked_points()
	
	## construct the polygon using the polygon template and the surface points.
	# deep copy the template
	var water_polygon = []
	
	var counter = 0
	for i in polygon:
		if i[0]:
			#if the point is a spring
			water_polygon.append()
	water_polygon_points.append(Vector2(water_polygon_points[-1].x, bottom))
	water_polygon_points.append(Vector2(water_polygon_points[0].x, bottom))
	
	$polygon.polygon = water_polygon_points

func new_border():
	var curve = Curve2D.new()
	
	for spring in $springs.get_children():
		curve.add_point(spring.position)
	
	$border.curve = curve
	$border.smooth(true)
	$border.queue_redraw()

func set_polygon(poly):
	polygon = poly
	for i in polygon:
		# i = [is_spring:bool, position:Vector2]
		if i[0]:
			var new = spring_scene.instantiate()
			new.position = i[1]
			$springs.add_child(new)
		$polygon.polygon.append(i[1])
