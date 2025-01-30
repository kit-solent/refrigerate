## Base class for point effects in the game. These effects
## happen at a certain time, last for a set duration, and
## happen at a certain position in 2D space. NOTE: scripts
## that inherit this class should not override the _ready
## method as that is used internally. The `ready` method
## should be used instead.

@icon("res://assets/icons/effect.svg")
class_name Effect extends Node2D

## if true the effect runs as soon as it enters the scene tree.
## if false the run method must be used to trigger the effect.
@export var autorun:bool = true

## the number of sub effects that must finish for this effect
## to be finished. As effects finish this counter is decreased
## and the effect node is freed after it reaches 0. This value
## should not be changed manualy and if it is the node will not
## be freed untill effect_finished is called.
@export var effect_count:int = 0

## fired when the effect has finished. This happens when all its parts
## e.g. audio, visual, particles, etc, have all finished.
signal finished

func _ready() -> void:
	ready()
	if autorun:
		run()

func effect_finished():
	"""
	Called whenever a sub effect has finished. Frees the node
	if the effect_count reaches 0.
	"""
	print("hello")
	effect_count -= 1
	
	if effect_count <= 0:
		get_parent().remove_child(self)
		queue_free()


# user overriden methods

func run() -> void:
	"""
	Triggers the effect.
	"""
	pass

func ready() -> void:
	"""
	Called when _ready is called but before any
	effect triggering happens.
	"""
	pass
