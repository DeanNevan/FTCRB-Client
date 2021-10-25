extends Node2D

#DYNAMIC：动态改变颜色
#COLORFUL：固定颜色数组
#FIX：统一颜色
enum COLOR_STYLE{
	DYNAMIC
	COLORFUL
	FIX
}

#DYNAMIC：动态改变轨迹透明度
#FIX：统一透明度
enum ALPHA_STYLE{
	DYNAMIC
	FIX
}

var color_style = COLOR_STYLE.FIX#颜色模式
var alpha_style = ALPHA_STYLE.DYNAMIC#透明度模式

var track_positions := []#鼠标位置数组
var colorful_colors := []#保存每个点的颜色
var track_length = 10#轨迹长度

var fix_color := Color.white#统一颜色
#颜色数组
var colors := [
	Color.red,
	Color.orange,
	Color.yellow,
	Color.green,
	Color.cyan,
	Color.blue,
	Color.purple
]
var width = 3#轨迹宽度
var fix_alpha = 1#统一透明度
var dynamic_alpha := Vector2(0, 1)#动态透明度的区间
var is_tracking := false#是否tracking

var frame_track_period = 20
var frame_count = 0

func _draw():
	if track_positions.size() < 2:
			return
	var _points_colors := []
	match color_style:
			COLOR_STYLE.DYNAMIC:
					for i in track_positions.size():
							_points_colors.append(colors[randi() % colors.size()])
			COLOR_STYLE.FIX:
					for i in track_positions.size():
							_points_colors.append(fix_color)
			COLOR_STYLE.COLORFUL:
					_points_colors = colorful_colors
	match alpha_style:
			ALPHA_STYLE.DYNAMIC:
					for i in track_positions.size():
							if i != 0:
									_points_colors[i].a = dynamic_alpha.x + float(dynamic_alpha.y - dynamic_alpha.x) * (float(i) / track_positions.size())
							else:
									_points_colors[i].a = dynamic_alpha.x
			ALPHA_STYLE.FIX:
					for i in track_positions.size():
							_points_colors[i].a = fix_alpha
	
	#画线
	draw_polyline_colors(
			track_positions,
			_points_colors,
			width,
			true
	)

func _ready():
	#start_track()#开始track鼠标轨迹
	randomize()

func track():
	if track_positions.size() > track_length:
		track_positions.pop_front()
		track_positions.push_back($DotSprite.position.rotated(deg2rad(rotation_degrees)))
		colorful_colors.pop_front()
		colorful_colors.push_back(colors[randi() % colors.size()])
	else:
		track_positions.append($DotSprite.position.rotated(deg2rad(rotation_degrees)))
		colorful_colors.append(colors[randi() % colors.size()])

func _physics_process(delta: float) -> void:
	if is_tracking:
		frame_count += 1
		if frame_count >= frame_track_period:
			track()
			frame_count = 0
	else:
		frame_count = 0
		track_positions.pop_front()
		colorful_colors.pop_front()
	update()


func start_track():
	is_tracking = true

func stop_track():
	is_tracking = false
