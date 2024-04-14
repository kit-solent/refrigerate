extends RigidBody2D

@export var platformer:bool=true ## If true the body is in platformer mode. Otherwise it is in top down mode.
@export var move_velocity:float=1000
@export var jump_velocity:float=2000
@export var gravity_direction:int=0 ## 0=down, 1=left, 2=up, 3=right
var gravity_strength=ProjectSettings.get_setting("physics/2d/default_gravity")

func _integrate_forces(_state:PhysicsDirectBodyState2D):
	print(typeof(gravity_strength))
	if platformer:
		linear_velocity.x=0 # reset the horizontal velocity.
		linear_velocity+=Vector2.DOWN*gravity_strength*_state.step
		if Input.is_action_pressed("player left"):
			linear_velocity+=Vector2.LEFT * move_velocity
		if Input.is_action_pressed("player right"):
			linear_velocity+=Vector2.RIGHT * move_velocity
		if Input.is_action_just_pressed("player jump"):
			linear_velocity+=Vector2.UP * jump_velocity
	else:
		pass

func _on_body_entered(body):
	if body.is_in_group("terrain"):pass
