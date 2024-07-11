class_name User extends Resource

const identifier:String = "email"
## The variable used to uniquely identify a given User.
## No two users can have the same value for this variable. 
@export var username:String
@export var password:String
var initialised=false
## If false then the user is an empty placeholder. Call from_json to initialise it.

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

func get_identifier():
	return to_json()[identifier]
