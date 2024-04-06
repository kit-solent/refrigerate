extends Node

var current_user:User=User.new()

func _ready():
	current_user.setup_from_json({"username":"jeff","password":"1234"})

func _process(delta):
	if not is_request_pending and current_user:
		_update_data()

# Firebase
const host="https://refrigerate-580a7-default-rtdb.firebaseio.com/"
var is_request_pending:bool=false
var remote_data:String

func _update_data():
	if remote_data==JSON.stringify(current_user.to_json()):
		return # if the current data is the same as the last
	print("hello")
	is_request_pending=true
	remote_data=JSON.stringify(current_user.to_json())
	$http_request.request(host+"/players/%s.json"%current_user.user_id,[],HTTPClient.METHOD_PUT, remote_data)

func _on_http_request_request_completed(result, response_code, headers, body):
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
