class_name User extends Resource

@export var id:int
@export var username:String
@export var password:String

func to_json():
	"""
	returns the json reperesentation of this user.
	"""
	return {
		"id":id,
		"username":username,
		"password":password,
	}

func from_json(dict:Dictionary):
	"""
	Initialises this User object with the data from the given dictionary.
	"""
	id=dict["id"]
	username=dict["username"]
	password=dict["password"]
