extends Effect

# TODO: Particle explosions have not been implemented yet.
@export_enum("Animated", "Particle") var explosion_type:String = "Animated"

func run():
	if explosion_type == "Particle":
		push_error("Particle explosions have not been implemented yet")
	
	$audio.play()
	var duration
	
	if explosion_type == "Animated":
		var speed = $animation.sprite_frames.get_animation_speed(&"explosion")
		var frames = $animation.sprite_frames.get_frame_count(&"explosion")
		duration = frames / speed # frames / (frames / second) = (frames * second) / frames = second
		$animation.show()
		$animation.play()
	elif explosion_type == "Particle":
		$particles.show()
		$particles.emitting = true
		
		# explination of the formula for the duration of a one_shot particle system.
		# https://github.com/godotengine/godot-proposals/issues/649#issuecomment-995761510
		duration = $particles.lifetime * (2 - $particles.explosiveness)
	
	$light.enabled = true
	# fade the light out over the duration of the animation
	get_tree().create_tween().\
	tween_property($light, ^"energy", 0, duration).\
	set_ease(Tween.EASE_IN)
