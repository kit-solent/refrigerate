extends Node2D

func _ready():
	print(Core.tools.merge_lines([
		PackedVector2Array([Vector2(0,0), Vector2(0,1)]),
		PackedVector2Array([Vector2(0,2), Vector2(0,3)]),
		PackedVector2Array([Vector2(0,1), Vector2(0,2)])
	]))
	


func _stupid_stupid_godot_engine():
	var arr:Array[PackedVector2Array] = []
	var val = [PackedVector2Array([Vector2.ONE,Vector2.ONE])]
	arr.append(val)
	print(arr)
