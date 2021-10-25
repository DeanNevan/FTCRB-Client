extends Node

var logger : Logger = Logger.new("全局", Logger.LOG_LEVEL.DEBUG)

func get_local_timestamp() -> int:
	return OS.get_system_time_msecs()

func get_vector_via_accuracy(vector : Vector2, accuracy : float, _basic_range = PI / 2):
	var ran = rand_range((-PI / 2) * ((1 - accuracy) / 2), (PI / 2) * ((1 - accuracy) / 2))
	return vector.rotated(ran)

func multiply_dictionary(dic_from : Dictionary, dic_to : Dictionary) -> Dictionary:
	var new_dic := {}
	for i in dic_to:
		new_dic[i] = dic_to[i] * dic_from[i]
	return new_dic

func transfer_position_3d_to_2d_in_camera(camera : Camera, target_pos : Vector3) -> Vector2:
	return camera.unproject_position(target_pos)

func get_spatial_towards(spatial : Spatial) -> Vector3:
	return -spatial.global_transform.basis.z

#_signal_object : 信号发出的节点
#_signal : 信号
#_target_object : 连接目标
#_function : 目标的方法
#_para : 传递参数
#_connect_flag：连接flag
func connect_signal(_signal_object : Object, _signal : String, _target_object : Object, _function : String, _para := [], _connect_flag = 0):
	if !is_instance_valid(_signal_object):
		print("信号" + _signal + " 来源对象无效")
		return
	if !_signal_object.has_signal(_signal):
		print("信号" + _signal + " 来源对象" + str(_signal_object) + " 无该信号")
		return
	if !is_instance_valid(_target_object):
		print("信号" + _signal + " 连接对象无效" + " 来源对象为" + str(_signal_object))
		return
	if !_target_object.has_method(_function):
		print("信号" + _signal + " 连接对象" + str(_target_object) + " 无该方法" + _function)
		return
	if _signal_object.is_connected(_signal, _target_object, _function):
		print("信号" + _signal + " 重复连接" + " 来源对象为" + str(_signal_object))
		return
	connect_and_detect(_signal_object.connect(_signal, _target_object, _function, _para, _connect_flag))

func connect_and_detect(_return_value):
	if _return_value != 0:
		print("其它错误连接，错误代号", _return_value)
		return false
	return true

func combine_arrays(arrays : Array):
	var arr := []
	for i in arrays:
		for j in i:
			arr.append(j)
	return arr

func get_collision_layers(_layer_dec : int) -> Array:
	var _layers := []
	var _count = -1
	while _layer_dec != 0:
		_count += 1
		if _layer_dec % 2:
			_layers.append(_count)
		_layer_dec /= 2
	return _layers

func clear_collision_layers(object : CollisionObject2D):
	for i in 20:
		object.set_collision_layer_bit(i, false)
	pass

func clear_collision_masks(object : CollisionObject2D):
	for i in 20:
		object.set_collision_mask_bit(i, false)
	pass

func sum_dictionary_values(dic : Dictionary) -> float:
	var sum := 0.0
	for i in dic.values():
		sum += i
	return sum

# Helper class to convert values from the server into Godot values.
class Converter:
	# Converts a string in the format `"r,g,b,a"` to a Color. Alpha is skipped.
	static func color_string_to_color(string: String) -> Color:
		var values := string.replace('"', '').split(",")
		return Color(float(values[0]), float(values[1]), float(values[2]))
	
	# Converts a Transform2D to a string in the format `"position.x,position.y,rotation,scale.x(may null),scale.y(may null)"`.
	static func transform2d_to_transform2d_string(transform: Transform2D, include_scale : bool = false) -> String:
		var string : String = ""
		if include_scale:
			string = "%s,%s,%s,%s,%s" % [
				transform.get_origin().x,
				transform.get_origin().y,
				transform.get_rotation(),
				transform.get_scale().x,
				transform.get_scale().y
			]
		else:
			string = "%s,%s,%s" % [
				transform.get_origin().x,
				transform.get_origin().y,
				transform.get_rotation()
			]
		return string



	# Converts a string in the format `"position.x,position.y,rotation,scale.x(may null),scale.y(may null)"` to a Transform2D.
	static func transform2d_string_to_transform2d(string: String) -> Transform2D:
		var values := string.replace('"', '').split(",")
		var tra : Transform2D = Transform2D(float(values[2]), Vector2(float(values[0]), float(values[1])))
		if values.size() > 3:
			tra.scaled(Vector2(float(values[3]), float(values[4])))
		return tra
	
	# Converts a Vector2D to a string in the format `"x,y"`.
	static func vector2d_to_vector2d_string(vector: Vector2) -> String:
		return "%s,%s" % [
			vector.x,
			vector.y
			]
	
	# Converts a string in the format `"x,y"` to a Vector2D.
	static func vector2d_string_to_vector2d(string: String) -> Vector2:
		var values := string.replace('"', '').split(",")
		if values.size() == 2:
			return Vector2(float(values[0]), float(values[1]))
		else:
			return Vector2()
	# Converts a Vector3D to a string in the format `"x,y,z"`.
	static func vector3d_to_vector3d_string(vector: Vector3) -> String:
		return "%s,%s,%s" % [
			vector.x,
			vector.y,
			vector.z
			]
	# Converts a string in the format `"x,y,z"` to a Vector3D.
	static func vector3d_string_to_vector3d(string: String) -> Vector3:
		var values := string.replace('"', '').split(",")
		if values.size() == 3:
			return Vector3(float(values[0]), float(values[1]), float(values[2]))
		else:
			return Vector3()
	
	static func image_data_to_image(image_data : Array, decompress := true) -> Image:
		var data = PoolByteArray(image_data)
		var img = Image.new()
		img.load_png_from_buffer(data)
		if decompress:
			img.decompress()
		return img
	
	static func image_to_image_data(img : Image, shrink_times := 4, get_centered := false, flip_y := true, compress := true) -> Array:
		if flip_y:
			img.flip_y()
		for i in shrink_times:
			img.shrink_x2()
		if get_centered:
			if img.get_size().x > img.get_size().y:
				img = img.get_rect(Rect2(Vector2((img.get_size().x - img.get_size().y) / 2, 0), Vector2(img.get_height(), img.get_height())))
			else:
				img = img.get_rect(Rect2(Vector2((img.get_size().y - img.get_size().x) / 2, 0), Vector2(img.get_width(), img.get_width())))
		img.convert(Image.FORMAT_RGB8)
		var img_data = img["data"]
		var result : PoolByteArray = img.save_png_to_buffer()
		return Array(result)
