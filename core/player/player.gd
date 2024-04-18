extends RigidBody2D

@export_enum("TopDown","PlatformerDown","PlatformerUp","PlatformerLeft","PlaformerRight") var mode=1
@export var move_velocity:float=1000
@export var jump_velocity:float=2000
var gravity_strength=ProjectSettings.get_setting("physics/2d/default_gravity")
@export var acceleration = 2

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	if mode==Core.modes.TopDown:
		pass
	else: # must be one of the Platformer modes.
		linear_velocity += Core.gravity[mode]*gravity_strength*_state.step
		var dir = Input.get_axis("player left","player right")
		if dir: # TODO: movment needs to be based on mode.
			linear_velocity = lerp(linear_velocity,Core.gravity[mode].rotated(PI/2)*dir*move_velocity,acceleration*_state.step)
		else:
			linear_velocity = lerp(linear_velocity,0.0,linear_damp*_state.step) 
		if Input.is_action_just_pressed("player jump"):
			linear_velocity.y = -jump_velocity
func _on_body_entered(body):
	if body.is_in_group("terrain"):pass

func set_mode(_mode:int):
	mode=_mode
	# TODO rotate body accordingly and change image if topdown
