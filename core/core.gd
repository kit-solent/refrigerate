extends Node

@export_category("Core")

## If true runs the game in debug mode. This includes features such as turning of the canvas modulate
## and enabling Godot's built in debugging features like visable collision shapes, paths, navigation, and avoidance.
@export var debug = false

@export_group("Mode Overide Colors")
@export var topdown_color:Color
@export var platformer_color:Color

@onready var main:Node = null

signal debug_action

var tools = Tools.new()

var debug_frame:bool = false
var debug_state:bool = false

enum modes {TopDown, PlatformerDown, PlatformerLeft, PlatformerUp, PlatformerRight}

var mode_names = ["TopDown", "PlatformerDown", "PlatformerLeft", "PlatformerUp", "PlatformerRight"]
var mode_colours = [
	Color("ff000037"),
	Color("2428987b"),
	Color("00ff0033"),
	Color("ffff0069"),
	Color("ff00ff5f")
]

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

func _ready():
	# if we are in the `ingame` scene then get a reference to the root `ingame` node.
	if has_node("/root/ingame"):
		main = get_node("/root/ingame")
	
	# set Godot's default debugging hints to match the games debug state.
	#get_tree().debug_collisions_hint = debug
	#get_tree().debug_paths_hint = debug
	#get_tree().debug_navigation_hint = debug
	
func _process(_delta:float):
	# the frame is a debug frame if the debug key has been pressed and we are in debug mode.
	debug_frame = Input.is_action_just_pressed("debug key") and debug
	debug_state = Input.is_action_pressed("debug key") and debug
	
	# emit the debug_action when the debug key is pressed.
	if debug_frame:
		debug_action.emit()

## User Authentication
#const host="https://refrigerate-580a7-default-rtdb.firebaseio.com/"
#var active_user:User
#var is_request_pending:bool=false
#
#var remote_data:String=""
#var pending_remote_data:String=""
#
#func _on_http_request_request_completed(result:int, response_code:int, _headers:PackedStringArray, _body:PackedByteArray):
	#if result != HTTPRequest.RESULT_SUCCESS:
		#printerr("request failed with response code: "+str(response_code))
	#else:
		#remote_data=pending_remote_data # if the request succeded then the remote data will now be what we sent.
	#is_request_pending=false
#
#func _process(_delta):
	#update_data()
#
#func update_data():
	#if is_request_pending or remote_data==JSON.stringify(active_user.to_json()) or not active_user:
		#return # only update if there is no pending request, we have a valid user and there have been changes made sice the last update.
	#is_request_pending=true
	#pending_remote_data=JSON.stringify(active_user.to_json())
	#$http_request.request(host+"/users/%s.json"%active_user.get_identifier(),[],HTTPClient.METHOD_PUT, pending_remote_data)
#
#func login(username:String,password:String):
	#pass





########################################
## Refrigerate Google account details
## Name: Refrigerate Game
## Birthday: 1/1/2000
## Email: refrigerate.game@gmail.com
## Password: 3K]hpg9Zds;Q8W'TQ|H_
## Firebase url: https://refrigerate-580a7-default-rtdb.firebaseio.com/
## 
## 
########################################
