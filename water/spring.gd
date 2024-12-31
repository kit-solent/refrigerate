extends Node2D

var velocity = 0
var force = 0
var target_height = 0
var motion_factor = 0.02
#var collided_with:Node = null

signal splash(speed)

func water_update(k:float, d:float):
	var x = position.y - target_height
	var loss = -d * velocity
	
	force = -k*x + loss
	
	velocity += force
	
	position.y += velocity

func initialise():
	target_height = position.y
	velocity = 0

func set_collision_width(value):
	var extents = $area_2d/collision_shape_2d.shape.size
	var new_extents = Vector2(value/2, extents.y)
	$area_2d/collision_shape_2d.shape.size = new_extents

func _on_area_2d_body_entered(body):
	#if body == collided_with:
	#	return
	#collided_with = body
	
	var speed
	if body is RigidBody2D:
		speed = body.linear_velocity.y * motion_factor
	elif body is CharacterBody2D:
		speed = body.velocity.y * motion_factor
	
	if speed:
		splash.emit(speed)
