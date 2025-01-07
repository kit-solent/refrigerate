@icon("res://core/assets/explosion_icon.png")
class_name Explosion extends Node2D

enum EXPLOSION_TYPE {ANIMATED, PARTICLE}
@export var type:EXPLOSION_TYPE = EXPLOSION_TYPE.ANIMATED

var explosion_spriteframes = preload("res://features/explosion/explosion_spriteframes.tres")

func run(explosion_type:EXPLOSION_TYPE = type):
	"""
	Runs the explosion using the given `explosion_type`.
	The Explosion node then deletes itself.
	"""
	print('uuuuup')
	if explosion_type == EXPLOSION_TYPE.ANIMATED:
		print("whoops")
		var animation = AnimatedSprite2D.new()
		animation.sprite_frames = explosion_spriteframes
		#NOTE: the &"name" literal is a StringName type.
		add_child(animation)
		animation.play(&"explosion")
	elif explosion_type == EXPLOSION_TYPE.PARTICLE:
		printerr("Particle explosions have not been implimented yet.")
	
	queue_free()
