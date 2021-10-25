tool
extends Node

const TIME_SLICE_DURATION_MS = 4

signal scan_completed

signal _internal_process
signal _file_cache_updated
signal _loc_updated

var _lines_of_code = 0
var _loc_per_type = {}
var _asset_counts = {}

var _asset_types = [
	"script",
	"texture",
	"sound",
	"scene",
	"model",
	"font",
	"other_resources"
]

var _script_types = {
	"gd": "gdscript",
	"cs": "csharp",
	"c": "cpp",
	"cpp": "cpp",
	"h": "cpp",
	"hpp": "cpp",
	"py": "python",
	"shader": "shader"
}

var _asset_extensions = {
	"gd": "script",
	"cs": "script",
	"c": "script",
	"cpp": "script",
	"h": "script",
	"py": "script",
	"shader": "script",

	"png": "texture",
	"bmp": "texture",
	"tga": "texture",

	"ogg": "sound",
	"wav": "sound",

	"tscn": "scene",
	"scn": "scene",

	"obj": "model",
	"gltf": "model",
	"dae": "model",
	
	"ttf": "font",
	"otf": "font",
	
	"res": "other_resources",
	"tres": "other_resources"
}

var _exclude_dirs := [
	"res://addons",
	"res://protobuf"
]

var _rank_count := []
var _rank_script := []

func _ready():
	set_process(false)


func run():
	_calculate_stats()


func get_asset_types():
	return _asset_types


func get_asset_counts():
	return _asset_counts


func get_loc():
	return _lines_of_code


func get_data():
	var data = {}
	data["lines_of_code"] = _loc_per_type
	for type in _asset_counts:
		var count = _asset_counts[type]
		data[type] = count
	return data


func _process(delta):
	#print("Processing...")
	var time_before = OS.get_ticks_msec()
	while OS.get_ticks_msec() - time_before < TIME_SLICE_DURATION_MS:
		emit_signal("_internal_process")


func _calculate_stats():
	set_process(true)

	var files = []
	var dirs = []

	_scan_dirs_recursively("res://", files, dirs)
	yield(self, "_file_cache_updated")

	_calculate_lines_of_code(files)
	yield(self, "_loc_updated")

	_count_asset_types(files)

	set_process(false)
	#print("Done")
	emit_signal("scan_completed")
	
	print_rank_script()
	#print("最长的脚本是%s，有%s行" % [str(_max_script), str(_max_count)])
	

func print_rank_script():
	print("脚本长度排名：")
	for i in _rank_count.size():
		print("%s. %s %s行" % [str(i + 1), _rank_script[i], str(_rank_count[i])])

func _count_asset_types(file_paths):
	for asset_type in _asset_types:
		_asset_counts[asset_type] = 0

	for file_path in file_paths:
		var ext = file_path.get_extension()

		if _asset_extensions.has(ext):
			var asset_type = _asset_extensions[ext]
			_asset_counts[asset_type] += 1

	#print(_asset_counts)


func _calculate_lines_of_code(file_paths):
	var total_loc = 0
	for i in range(len(file_paths)):
		var file_path : String = file_paths[i]

		var ext = file_path.get_extension()
		
		if _script_types.has(ext):
			var loc = _count_lines(file_path)
			total_loc += loc
			
			var _temp = file_path.split("/", false)
			var _script_name = _temp[_temp.size() - 1]
			if _rank_count.size() == 0:
				_rank_count.append(loc)
				_rank_script.append(_script_name)
			elif !_rank_script.has(_script_name):
				for j in _rank_count.size():
					if loc > _rank_count[j]:
						_rank_count.insert(j, loc)
						_rank_script.insert(j, _script_name)
						if _rank_count.size() > 10:
							_rank_count.pop_back()
							_rank_script.pop_back()
						break
			
			var script_type = _script_types[ext]
			if _loc_per_type.has(script_type):
				_loc_per_type[script_type] += loc
			else:
				_loc_per_type[script_type] = loc
		
		yield(self, "_internal_process")

	_lines_of_code = total_loc

	#print("LOC: ", total_loc, ", ", _loc_per_type)
	emit_signal("_loc_updated")


func _count_lines(file_path):
	#print("Counting lines in ", file_path)

	var f = File.new()
	var err = f.open(file_path, File.READ)
	if err != OK:
		print("ERROR: cannot open file '", file_path, "'")
		return 0

	var count = 0
	while not f.eof_reached():
		f.get_line()
		count += 1

	f.close()
	return count


func _scan_dirs_recursively(root, out_files, out_dirs):
	var dirs_to_scan = [root]

	while not dirs_to_scan.empty():
		var prev_dir_count = len(out_dirs)

		var dir = dirs_to_scan[-1]
		dirs_to_scan.pop_back()

		_scan_dir(dir, out_files, out_dirs)
		#_scanned_dirs[dir] = true

		var dir_count = len(out_dirs)

		for i in range(prev_dir_count, dir_count):
			if out_dirs[i] in _exclude_dirs:
				continue
			dirs_to_scan.append(out_dirs[i])
		
		yield(self, "_internal_process")

	emit_signal("_file_cache_updated")


func _scan_dir(root, out_files, out_dirs):
	#print("Scanning ", root)

	var dir = Directory.new()
	var err = dir.change_dir(root)

	if err != OK:
		print("Error: can't go to directory '", root, "', ", err)
		return

	dir.list_dir_begin(true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		var path = root.plus_file(file)
		if dir.current_is_dir():
			out_dirs.append(path)
		else:
			out_files.append(path)



