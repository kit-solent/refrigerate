class_name Player extends RigidBody2D

@export_enum("TopDown","PlatformerDown","PlatformerUp","PlatformerLeft","PlaformerRight") var mode=1
@export var move_velocity:float=1000
@export var jump_velocity:float=500
var gravity_strength=ProjectSettings.get_setting("physics/2d/default_gravity")
@export var acceleration:int = 10
@export var deacceleration:int = 40
@export var terminal_velocity:int = 1500
#enum modes {TopDown, PlatformerDown, PlatformerUp, PlatformerLeft, PlatformerRight}

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	if mode == Core.modes.TopDown: # TopDown mode.
		pass
	else: # one of the Platformer modes.
		linear_velocity += Core.gravity[mode]*gravity_strength*_state.step
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
		if Input.is_action_just_pressed("player jump"):
			if mode == Core.modes.PlatformerDown: # Gravity down
				linear_velocity.y += -jump_velocity
			elif mode == Core.modes.PlatformerUp: # Gravity up
				linear_velocity.y += jump_velocity
			elif mode == Core.modes.PlatformerLeft: # Gravity left
				linear_velocity.x += jump_velocity
			elif mode == Core.modes.PlatformerRight: # Gravity right
				linear_velocity.x += -jump_velocity
		linear_velocity.y=clamp(linear_velocity.y,-terminal_velocity,terminal_velocity)
		linear_velocity.x=clamp(linear_velocity.x,-terminal_velocity,terminal_velocity)

func _on_body_entered(body):
	if body.is_in_group("terrain"):pass

func set_mode(_mode:int):
	mode = _mode
	rotation = Core.gravity[_mode].angle()-(TAU/4)
	if _mode == Core.modes.TopDown:
		$topdown_collision.set_deferred("disabled", false)
		$platformer_collision.set_deferred("disabled", true)
	else:
		$topdown_collision.set_deferred("disabled", true)
		$platformer_collision.set_deferred("disabled", false)
