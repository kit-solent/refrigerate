class_name User extends Resource

@export var username:String
@export var password:String

## If false then the user is an empty placeholder. Call from_json to initialise it.
var initialised = false

func to_json():
	"""
	returns the json reperesentation of this user.
	"""
	return {
		"username":username,
		"password":password,
	}

func from_json(dict:Dictionary):
	"""
	Initialises this User object with the data from the given dictionary.
	"""
	initialised=true
	username=dict["username"]
	password=dict["password"]
