class_name Player extends RigidBody2D
## A player is an in-game entity controlled by either the local user or a remote
## player. Note that this class is not a functional player by itself and the player
## scene should be used instead. i.e. use load("res://core/player/player.tscn") instead of Player.new().
## This class can be used to access the data ascociated with players such as the modes enum or
## mode_transforms dictionary.

enum modes {TopDown, ## The player can move in any direction and there is no gravity.
			PlatformerDown, ## Gravity acts down.
			PlatformerLeft, ## Gravity acts to the left.
			PlatformerUp, ## Gravity acts up.
			PlatformerRight ## Gravity acts to the right.
}

## These are the different ways that the player can move in top down mode.
enum topdown_options {
	EightDirectional, ## The player always faces upwards and uses the 4 movment keys to move around.
	TurnAndMove, ## The player uses the left and right movment keys to turn and the forward and backward keys to move.
	Mouse ## The player always faces the mouse and can move left/right/up/down using the movment keys.
}

## These are the Transform2Ds for the 5 modes.
## They are used for gravity, jump, and movment 
## calculations so the TopDown transform should
## nullify any vectors to which it is applied.
var mode_transforms = {
	0: Transform2D(0, Vector2.ZERO, 0, Vector2.ZERO), # TopDown mode has no direction in this sense so apply a 0 scale.
	1: Transform2D(0 * TAU/4, Vector2.ZERO),
	2: Transform2D(1 * TAU/4, Vector2.ZERO),
	3: Transform2D(2 * TAU/4, Vector2.ZERO),
	4: Transform2D(3 * TAU/4, Vector2.ZERO),
}

var mode_names = ["TopDown", "PlatformerDown", "PlatformerLeft", "PlatformerUp", "PlatformerRight"]
var mode_colours = [
	Color("ff000037"),
	Color("2428987b"),
	Color("00ff0033"),
	Color("ffff0069"),
	Color("ff00ff5f")
]

## The mode of movment used by this player, often deffined by the region of the map they are in.
## The default mode with a value of 0 is top down with no gravity.
@export var mode:modes = modes.TopDown

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
	
	if mode == modes.TopDown: # TopDown mode.
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
		if dir:
			if mode == modes.PlatformerDown:
				linear_velocity.x = lerp(linear_velocity.x,dir*move_velocity,acceleration*state.step)
			elif mode == modes.PlatformerUp:
				linear_velocity.x = lerp(linear_velocity.x,-dir*move_velocity,acceleration*state.step)
			elif mode == modes.PlatformerLeft:
				linear_velocity.y = lerp(linear_velocity.y,dir*move_velocity,acceleration*state.step)
			elif mode == modes.PlatformerRight:
				linear_velocity.y = lerp(linear_velocity.y,-dir*move_velocity,acceleration*state.step)
		else:
			if mode in [modes.PlatformerDown,modes.PlatformerUp]: # If the gravity direction is down or up.
				linear_velocity.x = lerp(linear_velocity.x,0.0,deacceleration*state.step) 
			elif mode in [modes.PlatformerLeft,modes.PlatformerRight]: # If the gravity direction is left or right.
				linear_velocity.y = lerp(linear_velocity.y,0.0,deacceleration*state.step)
		
		# apply jump forces.
		if Input.is_action_just_pressed("player jump"):
			linear_velocity += -get_gravity()*jump_velocity*state.step
	
	# apply terminal velocity.
	linear_velocity = linear_velocity.clamp(-Vector2.ONE * terminal_velocity, Vector2.ONE * terminal_velocity)

func _on_body_entered(body):
	if body.is_in_group("terrain"):
		pass

var update = false
func set_mode(_mode:modes):
	mode = _mode
	print(mode)
	update = true # let the _integrate_forces function know that we need to update our direciton.
	if mode == Core.modes.TopDown:
		$topdown_collision.set_deferred("disabled", false)
		$platformer_collision.set_deferred("disabled", true)
	else:
		$topdown_collision.set_deferred("disabled", true)
		$platformer_collision.set_deferred("disabled", false)
