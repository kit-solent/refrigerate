extends Node2D

@export var k = 0.015
@export var d = 0.03
@export var spread = 0.0002
@export var border_thickness:float = 1.1

var spring = preload("res://water/spring.tscn")
var springs = []
var passes = 8

var depth = 1000
var target_height = global_position.y
var bottom = target_height + depth

func _ready():
	$water_border.width = border_thickness
	
	for i in $springs.get_children():
		springs.append(i)
		i.initialise()
	
	splash(2, 50)

func _physics_process(_delta):
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
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed

func draw_water_body():
	var surface_points = PackedVector2Array()
	
	for i in springs:
		surface_points.append(i.position)
	
	var first_index = 0
	var last_index  = surface_points.size() - 1
	
	var water_polygon_points = surface_points
	
	water_polygon_points.append(Vector2(surface_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(surface_points[first_index].x, bottom))
	
	$polygon_2d.polygon = water_polygon_points

func new_border():
	var curve = Curve2D.new().duplicate()
	
	var surface_points = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
		
	for i in range(surface_points.size()):
		curve.add_point(surface_points[i])
	
	$water_border.curve = curve
	$water_border.smooth(true)
	$water_border.queue_redraw()
	
