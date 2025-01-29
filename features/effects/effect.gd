@icon("res://core/assets/icons/effect.svg")
class_name Effect extends Node2D

## If true the effect will run as soon as it enters the scene tree. Otherwise the run method must be used to activate the effect.
@export var autorun = true

func _ready() -> void:
	if autorun:
		run()

func run():
	"""
	Runs the effect. This could mean playing visual, audio, lighting or other effects.
	"""
	pass
