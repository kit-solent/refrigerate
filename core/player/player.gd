class_name Player extends RigidBody2D
## A player is an in-game entity controlled by either the local user or a remote player.
## Note that this class is not a functional player by itself and the player scene should
## be used instead. i.e. use load("res://core/player/player.tscn") instead of Player.new().
## This class can be used to access the data ascociated with players such as the modes enum
## or mode_transforms dictionary.

## These are the different ways that the player can move in top down mode.
enum topdown_options {
	## The player always faces upwards and uses the 4 movment keys to move around.
	EightDirectional,
	## The player uses the left and right movment keys to turn and the forward and backward keys to move.
	TurnAndMove,
	## The player always faces the mouse and can move left/right/up/down using the movment keys.
	Mouse 
}

## The direction that gravity points in. If Vector2.ZERO then the
## player is in top down mode.
@export var gravity_direction:Vector2 = Vector2.ZERO

## The movment options for when the player is in top down mode.
@export var topdown_setup:topdown_options = topdown_options.EightDirectional

@export var move_velocity:float = 1000
@export var rotational_velocity:float = TAU/4 # 4 seconds to make a full turn.
@export var jump_velocity:float = 50
@export var acceleration:float = 10
@export var deacceleration:float = 40
@export var terminal_velocity:float = 1500

func _integrate_forces(state:PhysicsDirectBodyState2D):
	# used later
	var dir
	var rot
	
	if gravity_direction == Vector2.ZERO:
		if topdown_setup in [topdown_options.EightDirectional,topdown_options.Mouse]:
			dir = Input.get_vector("player left", "player right", "player forward", "player backward")
		elif topdown_setup == topdown_options.TurnAndMove:
			dir = Input.get_axis("player backward", "player forward")
			rot = Input.get_axis("player left", "player right")
			rotation += rot * rotational_velocity * state.step
		
		if topdown_setup == topdown_options.Mouse:
			rotation = TAU/4
			# since look at assumes the node is facing right and we are facing up
			#rotation += TAU/4
		
		# accelerate toward the calculated direction
		linear_velocity = lerp(linear_velocity, dir * move_velocity, acceleration*state.step)
		
	else: # one of the Platformer modes.
		# apply gravity.
		linear_velocity += get_gravity()*state.step
		
		dir = Input.get_axis("player left", "player right")
		# TODO
		
		# apply jump forces.
		if Input.is_action_just_pressed("player jump"):
			linear_velocity += -get_gravity()*jump_velocity*state.step
	
	# apply terminal velocity.
	linear_velocity = linear_velocity.clamp(-Vector2.ONE * terminal_velocity, Vector2.ONE * terminal_velocity)

func _on_body_entered(body):
	if body.is_in_group("terrain"):
		pass

var update = false
func set_gravity_direction(direction:Vector2):
	gravity_direction = direction
	update = true # let the _integrate_forces function know that we need to update our direciton.
	if direction == Vector2.ZERO:
		$topdown_collision.set_deferred("disabled", false)
		$platformer_collision.set_deferred("disabled", true)
	else:
		$topdown_collision.set_deferred("disabled", true)
		$platformer_collision.set_deferred("disabled", false)
