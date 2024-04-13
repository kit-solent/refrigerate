extends RigidBody2D

@export var platformer:bool=true ## If true the body is in platformer mode. Otherwise it is in top down mode.
@export var move_velocity:float=1000
@export var jump_velocity:float=2000
var gravity=ProjectSettings.get_setting("physics/2d/default_gravity")

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	if platformer:
		linear_velocity.x=0 # reset the horizontal velocity.
		linear_velocity+=Vector2.DOWN*gravity*_state.step
		if Input.is_action_pressed("player left"):
			linear_velocity+=Vector2.LEFT * move_velocity
		if Input.is_action_pressed("player right"):
			linear_velocity+=Vector2.RIGHT * move_velocity
		if Input.is_action_just_pressed("player jump"):
			linear_velocity+=Vector2.UP * jump_velocity
