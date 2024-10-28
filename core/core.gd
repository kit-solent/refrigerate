extends Node

@export_category("Mode Overide Colors")
@export var topdown_color:Color
@export var platformer_color:Color

enum modes {TopDown, PlatformerDown, PlatformerUp, PlatformerLeft, PlatformerRight}
var gravity = {
	0:Vector2.ZERO, # TopDown mode has no gravity
	1:Vector2.DOWN,
	2:Vector2.UP,
	3:Vector2.LEFT,
	4:Vector2.RIGHT
}

func _ready():
	pass


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
