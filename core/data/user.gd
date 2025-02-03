class_name User extends Resource

# auth
@export var username:String
@export var password:String

## Contains all the items/accessories/etc that the users
## player owns.
@export var inventory:Inventory
