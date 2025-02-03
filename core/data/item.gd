## A resource that reperesents an item or accessory
## ownable by a character.
class_name Item extends Resource

## The unique id assigned to thie item. All items of the same type
## have the same id.
@export var id:int

## The texture used when displaying this item in an inventory
## or other reperesentation of the item.
@export var icon:ImageTexture
