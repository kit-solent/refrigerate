extends Node2D

var velocity = 0
var force = 0
var height = 0
var target_height = 0
var index = 0
var motion_factor = 0.02


var collided_with:Node = null

signal splash(index, speed)


func water_update(k:float, d:float):
	height = position.y
	
	var x = height - target_height
	var loss = -d * velocity
	
	force = -k*x + loss
	
	velocity += force
	
	position.y += velocity

func initialise(id):
	height = position.y
	target_height = position.y
	velocity = 0
	index = id

func set_collision_width(value):
	var extents = $area_2d/collision_shape_2d.shape.size
	var new_extents = Vector2(value/2, extents.y)
	$area_2d/collision_shape_2d.shape.size = new_extents

func _on_area_2d_body_entered(body):
	if body == collided_with:
		return
	#collided_with = body
	
	var speed
	if body is RigidBody2D:
		speed = body.linear_velocity.y * motion_factor
	elif body is CharacterBody2D:
		speed = body.velocity.y * motion_factor
	splash.emit(index, speed)
