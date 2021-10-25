extends Node

func parse_image_data_string(image_data_string : String) -> Array:
	var image_data : Array = []
	image_data = JSON.parse(image_data_string).result
	return image_data
	pass

func image_data_to_image(image_data : Array, decompress := true) -> Image:
		var data = PoolByteArray(image_data)
		var img = Image.new()
		img.load_png_from_buffer(data)
		if decompress:
			img.decompress()
		return img
	
func image_to_image_data(img : Image, shrink_times := 4, get_centered := false, flip_y := true, compress := true) -> Array:
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
