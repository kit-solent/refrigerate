extends Node2D

var velocity = 0
var force = 0
var height = 0
var target_height = 0

func water_update(k:float, d:float):
	height = position.y
	
	var x = height - target_height
	var loss = -d * velocity
	
	force = -k*x + loss
	
	velocity += force
	
	position.y += velocity

func initialise():
	height = position.y
	target_height = position.y
	velocity = 0
