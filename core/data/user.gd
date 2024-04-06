class_name User extends Resource

@export var user_id:int
@export var username:String
@export var password:String

func to_json():
	return {
		"username":username,
		"password":password,
	}

func setup_from_json(dict:Dictionary):
	username=dict["username"]
	password=dict["password"]
