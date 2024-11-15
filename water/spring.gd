extends Node2D

var velocity = 0
var force = 0
var height = position.y
var target_height = position.y + 500 # for testing
var spring_constant = 0.015
var damping = 0.03

func update(k:float, d:float):
	height = position.y
	
	var x = height - target_height
	var loss = -d * velocity
	
	force = -k*x + loss
	
	velocity += force
	
	position.y += velocity
	

func _physics_process(delta:float):
	update(spring_constant, damping)
