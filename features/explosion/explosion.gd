@icon("res://core/assets/explosion_icon.png")
class_name Explosion extends Node2D

enum EXPLOSION_TYPE {ANIMATED, PARTICLE}
@export var type:EXPLOSION_TYPE = EXPLOSION_TYPE.ANIMATED
@export var autorun:bool = true

var explosion_spriteframes = preload("res://features/explosion/explosion_spriteframes.tres")

func _ready():
	if autorun:
		run()

func run(explosion_type:EXPLOSION_TYPE = type):
	"""
	Runs the explosion using the given `explosion_type`.
	The Explosion node then deletes itself.
	"""
	if explosion_type == EXPLOSION_TYPE.ANIMATED:
		var animation = AnimatedSprite2D.new()
		animation.sprite_frames = explosion_spriteframes
		add_child(animation)
		animation.animation_finished.connect(queue_free)
		#NOTE: the &"name" literal is a StringName type.
		animation.play(&"explosion")
	elif explosion_type == EXPLOSION_TYPE.PARTICLE:
		printerr("Particle explosions have not been implimented yet.")
		queue_free()
