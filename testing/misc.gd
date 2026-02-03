extends Node2D

func _ready():
	var arr:Array[PackedVector2Array] = []
	var val = [PackedVector2Array([Vector2.ZERO,Vector2.ONE])]
	arr.append(val)
	print(arr)
	
