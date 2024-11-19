class_name Player extends RigidBody2D

@export_enum("TopDown","PlatformerDown","PlatformerUp","PlatformerLeft","PlaformerRight") var mode=1
@export var move_velocity:float=1000
@export var jump_velocity:float=500
var gravity_strength=ProjectSettings.get_setting("physics/2d/default_gravity")
@export var acceleration:float = 10
@export var deacceleration:float = 40
@export var terminal_velocity:float = 1500

func _process(delta: float):
	if Core.debug_frame:
		set_mode((mode + 1)%5)

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	if mode == Core.modes.TopDown: # TopDown mode.
		pass
	else: # one of the Platformer modes.
		# apply the transformation for the current mode to the default gravity
		var gravity = Core.mode_transforms[mode] * Vector2.DOWN
		
		# apply gravity.
		linear_velocity += gravity*gravity_strength*_state.step
		
		var dir = Input.get_axis("player left","player right")
		if dir:
			if mode == Core.modes.PlatformerDown:
				linear_velocity.x = lerp(linear_velocity.x,dir*move_velocity,acceleration*_state.step)
			elif mode == Core.modes.PlatformerUp:
				linear_velocity.x = lerp(linear_velocity.x,-dir*move_velocity,acceleration*_state.step)
			elif mode == Core.modes.PlatformerLeft:
				linear_velocity.y = lerp(linear_velocity.y,dir*move_velocity,acceleration*_state.step)
			elif mode == Core.modes.PlatformerRight:
				linear_velocity.y = lerp(linear_velocity.y,-dir*move_velocity,acceleration*_state.step)
		else:
			if mode in [Core.modes.PlatformerDown,Core.modes.PlatformerUp]: # If the gravity direction is down or up.
				linear_velocity.x = lerp(linear_velocity.x,0.0,deacceleration*_state.step) 
			elif mode in [Core.modes.PlatformerLeft,Core.modes.PlatformerRight]: # If the gravity direction is left or right.
				linear_velocity.y = lerp(linear_velocity.y,0.0,deacceleration*_state.step)
		
		# apply jump forces.
		if Input.is_action_just_pressed("player jump"):
			linear_velocity += -gravity*jump_velocity
		
		# apply terminal velocity.
		linear_velocity = linear_velocity.clamp(-Vector2.ONE * terminal_velocity, Vector2.ONE * terminal_velocity)

func _on_body_entered(body):
	if body.is_in_group("terrain"):
		pass

func set_mode(_mode:int):
	mode = _mode
	rotation = Core.mode_transforms[mode].get_rotation()
	print(mode)
	print(rotation)
	if mode == Core.modes.TopDown:
		$topdown_collision.set_deferred("disabled", false)
		$platformer_collision.set_deferred("disabled", true)
	else:
		$topdown_collision.set_deferred("disabled", true)
		$platformer_collision.set_deferred("disabled", false)
