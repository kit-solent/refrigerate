class_name Player extends RigidBody2D

@export_enum("TopDown","PlatformerDown","PlatformerUp","PlatformerLeft","PlaformerRight") var mode=1
@export var move_velocity:float=1000
@export var jump_velocity:float=1000
var gravity_strength=ProjectSettings.get_setting("physics/2d/default_gravity")
@export var acceleration:int = 10
@export var deacceleration:int = 40
@export var terminal_velocity:int = 1500

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	if mode==Core.modes.TopDown: # TopDown mode.
		pass
	else: # one of the Platformer modes.
		linear_velocity += Core.gravity[mode]*gravity_strength*_state.step
		var dir = Input.get_axis("player left","player right")
		if dir:
			if mode == 1:
				linear_velocity.x = lerp(linear_velocity.x,dir*move_velocity,acceleration*_state.step)
			elif mode == 2:
				linear_velocity.x = lerp(linear_velocity.x,-dir*move_velocity,acceleration*_state.step)
			elif mode == 3:
				linear_velocity.y = lerp(linear_velocity.y,dir*move_velocity,acceleration*_state.step)
			elif mode == 4:
				linear_velocity.y = lerp(linear_velocity.y,-dir*move_velocity,acceleration*_state.step)
		else:
			if mode in [1,2]: # If the gravity direction is down or up.
				linear_velocity.x = lerp(linear_velocity.x,0.0,deacceleration*_state.step) 
			elif mode in [3,4]: # If the gravity direction is left or right.
				linear_velocity.y = lerp(linear_velocity.y,0.0,deacceleration*_state.step)
		if Input.is_action_just_pressed("player jump"):
			if mode == 1: # Gravity down
				linear_velocity.y += -jump_velocity
			elif mode == 2: # Gravity up
				linear_velocity.y += jump_velocity
			elif mode == 3: # Gravity left
				linear_velocity.x += jump_velocity
			elif mode == 4: # Gravity right
				linear_velocity.x += -jump_velocity
		linear_velocity.y=clamp(linear_velocity.y,-terminal_velocity,terminal_velocity)
		linear_velocity.x=clamp(linear_velocity.x,-terminal_velocity,terminal_velocity)

func _on_body_entered(body):
	if body.is_in_group("terrain"):pass

func set_mode(_mode:int):
	mode=_mode
	rotation=Core.gravity[_mode].angle()-(PI/2)
	if _mode==0:
		$topdown_collision.set_deferred("disabled",false)
		$platformer_collision.set_deferred("disabled",true)
	else:
		$topdown_collision.set_deferred("disabled",true)
		$platformer_collision.set_deferred("disabled",false)
