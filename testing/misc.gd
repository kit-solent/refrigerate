extends Node2D

func _ready():
	#Core.debug_frame = true
	print(Core.tools.merge_lines([
		PackedVector2Array([Vector2(0,0), Vector2(1,0)]),
		PackedVector2Array([Vector2(1,0), Vector2(1,1)]),
		PackedVector2Array([Vector2(1,1), Vector2(0,1)]),
		PackedVector2Array([Vector2(0,1), Vector2(0,0)])
	]))
	
	print("finished")
	
	#print(Core.tools.merge_lines([
		#PackedVector2Array([Vector2(192.0, -64.0), Vector2(192.0, 192.0)]),
		#PackedVector2Array([Vector2(0.0, -64.0), Vector2(192.0, -64.0)]),
		#PackedVector2Array([Vector2(0.0, 192.0), Vector2(0.0, -64.0)]),
		#PackedVector2Array([Vector2(192.0, 192.0), Vector2(0.0, 192.0)])
	#]))
	
	# _stupid_stupid_godot_engine()


func _stupid_stupid_godot_engine():
	var arr:Array[PackedVector2Array] = []
	var val = [PackedVector2Array([Vector2.ONE,Vector2.ONE])]
	arr.append(val)
	print(arr)
	# [[(0.0, 0.0)]]
	# val ( Array[PackedVector2Array] ) is type coerced into PackedVector2Array
	# giving [(0.0, 0.0)]. i.e. Godot is stupid.
