extends Node

@export_category("Mode Overide Colors")
@export var topdown_color:Color
@export var platformer_color:Color


func _ready():
	pass

func _process(_delta):
	#update_data()
	pass

# User Authentication
const host="https://refrigerate-580a7-default-rtdb.firebaseio.com/"
var is_request_pending:bool=false
var remote_data:String=""
var current_user:User=User.new()

func save_user(_user:User):
	pass

func update_data():
	if is_request_pending or current_user==null or remote_data==JSON.stringify(current_user.to_json()):
		return # only update if there is no pending request, we have a valid user and there have been
		# changes made sice the last update.
	is_request_pending=true
	remote_data=JSON.stringify(current_user.to_json())
	$http_request.request(host+"/users/%s.json"%current_user.user_id,[],HTTPClient.METHOD_PUT, remote_data)

func _on_http_request_request_completed(result, response_code, _headers, _body):
	if result != HTTPRequest.RESULT_SUCCESS:
		printerr("request failed with  response code: "+str(response_code))
	is_request_pending=false

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
