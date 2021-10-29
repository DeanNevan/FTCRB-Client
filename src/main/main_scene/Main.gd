extends Control

var logger : Logger = Logger.new("主场景", Logger.LOG_LEVEL.DEBUG)

onready var _DebugLabelsContainer = $ControlFloat/DebugLabelsContainer
onready var _WindowSettings = $Windows/WindowSettings
onready var _WindowConnect = $Windows/WindowConnect
onready var _WindowRobotEvent = $Windows/WindowRobotEvent
onready var _WindowRobotRequest = $Windows/WindowRobotRequest
onready var _WindowIntro = $Windows/WindowIntro

onready var _ScrollOpModeLogsContainer = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/ScrollOpModeLogsContainer
onready var _OpModeLogsContainer = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/ScrollOpModeLogsContainer/OpModeLogsContainer
onready var _OpModeTabsContainer = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/ScrollContainer/OpModeTabsContainer

onready var _HeadLabelOpModeName = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer2/HeadLabelOpModeName

onready var _LabelInfoOpModeLogs = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/LabelInfoOpModeLogs
onready var _LabelInfoOpModeTabs = $ControlMain/MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/LabelInfoOpModeTabs



onready var loader_cover : LoaderCover = GUI.new_loader_cover()

var logs_auto_bottom := false

var Scene_EachOpModeLog = preload("res://src/main/main_scene/EachOpModeLog/EachOpModeLog.tscn")
var Scene_EachOpModeTab = preload("res://src/main/main_scene/EachOpModeTab/EachOpModeTab.tscn")

var current_show_logs_op_mode_name := ""

var tween_fade := Tween.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(tween_fade)
	
	_WindowIntro.activate()
	
	ServerConnection.connect("connected", self, "_on_ServerConnection_connected")
	HeartBeatManager.connect("timeout", self, "_on_HeartBeatManager_timeout")
	ServerConnection.connect("responsed", self, "_on_ServerConnection_responsed")
	
	loader_cover.inactivate(false)
	
	for i in _DebugLabelsContainer.get_children():
		var debug_label : DebugLabel = i
		if OS.is_debug_build():
			debug_label.activate()
		else:
			debug_label.inactivate()
	
	update_ui()
	update_logs()
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_ui():
	for i in _OpModeLogsContainer.get_children():
		i.queue_free()
	for i in _OpModeTabsContainer.get_children():
		i.queue_free()
	_HeadLabelOpModeName.text = "显示中的OpMode的名字"
	for i in Data.op_mode_logs:
		var op_mode_name : String = i
		
		var each_op_mode_tab = Scene_EachOpModeTab.instance()
		_OpModeTabsContainer.add_child(each_op_mode_tab)
		each_op_mode_tab.activate(op_mode_name)
		each_op_mode_tab.connect("select", self, "_on_EachOpModeTab_select")
		each_op_mode_tab.connect("delete", self, "_on_EachOpModeTab_delete")
	pass

func update_logs(op_mode_name : String = current_show_logs_op_mode_name):
	for i in _OpModeLogsContainer.get_children():
		i.queue_free()
	if op_mode_name == "" or Data.op_mode_logs.get(op_mode_name) == null:
		_HeadLabelOpModeName.text = "显示中的OpMode的名字"
		return
	_HeadLabelOpModeName.text = op_mode_name
	if op_mode_name == "" or Data.op_mode_logs.get(op_mode_name) == null:
		return
	for id in Data.op_mode_logs[op_mode_name]:
		var each_op_mode_log = Scene_EachOpModeLog.instance()
		_OpModeLogsContainer.add_child(each_op_mode_log)
		
		var content : String = Data.op_mode_logs[op_mode_name][id]["content"]
		var timestamp : int = Data.op_mode_logs[op_mode_name][id]["timestamp"]
		var time_dic : Dictionary = OS.get_datetime_from_unix_time(timestamp)
		
		each_op_mode_log.activate(
			id,
			content,
			"%d:%d:%d" % [
				time_dic.hour + 8,
				time_dic.minute,
				time_dic.second,
			]
		)
	yield(get_tree(), "idle_frame")
	if logs_auto_bottom:
		_ScrollOpModeLogsContainer.get_v_scrollbar().ratio = 1
	pass

func _on_ServerConnection_responsed(response : RBMessage.Response):
	match response.get_type():
		RBMessage.Type.ROBOT_REQUEST:
			var response_robot_request : RBMessage.ResponseRobotRequest = response.get_responseRobotRequest()
			if !response_robot_request.get_result():
				GUI.popup_confirmation(response_robot_request.get_words(), "机器人请求错误...")
		RBMessage.Type.ROBOT_OPMODE_LOG:
			var robot_opmode_log : RBMessage.RobotOpmodeLog = response.get_robotOpmodeLog()
			Data.add_op_mode_log(
				robot_opmode_log.get_opmode_name(),
				robot_opmode_log.get_content(),
				response.get_timestamp()
			)
			update_ui()
			update_logs()
		RBMessage.Type.ROBOT_EVENT:
			var robot_event : RBMessage.RobotEvent = response.get_robotEvent()
			var event_type = robot_event.get_robot_event_type()
			match event_type:
				RBMessage.RobotEventType.EVENT_RESTRAT_ROBOT:
					Data.add_robot_event_string("重启机器")
				RBMessage.RobotEventType.EVENT_EXIT_APP:
					Data.add_robot_event_string("退出APP")
				RBMessage.RobotEventType.EVENT_START:
					Data.add_robot_event_string("启动")
				RBMessage.RobotEventType.EVENT_RESUME:
					Data.add_robot_event_string("继续")
				RBMessage.RobotEventType.EVENT_PAUSE:
					Data.add_robot_event_string("暂停")
				RBMessage.RobotEventType.EVENT_STOP:
					Data.add_robot_event_string("停止")
				RBMessage.RobotEventType.EVENT_DESTROY:
					Data.add_robot_event_string("销毁")
				RBMessage.RobotEventType.EVENT_UNKNOWN:
					Data.add_robot_event_string("未知")
	pass


func _on_HeartBeatManager_timeout():
	GUI.popup_confirmation("心跳超时...")
	pass

func _on_ServerConnection_connected():
	loader_cover.inactivate(false)
	GUI.popup_confirmation("连接成功")

func _on_ButtonSettings_pressed():
	_WindowSettings.activate()
	pass # Replace with function body.

func _on_WindowConnect_confirm_connect(ip : String, port : int):
	var err : int = ServerConnection.connect_to(ip, port)
	if err != OK:
		logger.error("tcp连接出错: %d" % err)
		GUI.popup_confirmation("tcp连接出错: %d" % err)
		ServerConnection.tcp.disconnect_from_host()
	else:
		logger.debug("tcp连接成功")
		yield(get_tree().create_timer(0.5), "timeout")
		var temp := RBMessage.Request.new()
		temp.set_type(RBMessage.Type.CONNECT)
		temp.new_requestConnect()
		ServerConnection.send_message_request(temp)
		loader_cover.activate("发出连接请求...", 3, "超时", false)
		yield(get_tree().create_timer(3), "timeout")
		if !ServerConnection.connected:
			GUI.popup_confirmation("连接超时")
			ServerConnection.tcp.disconnect_from_host()
	pass # Replace with function body.


func _on_WindowSettings_setting_connect():
	_WindowConnect.activate()
	pass # Replace with function body.


func _on_WindowSettings_setting_window_robot_event():
	_WindowRobotEvent.activate()
	pass # Replace with function body.


func _on_WindowSettings_setting_window_robot_request():
	_WindowRobotRequest.activate()
	pass # Replace with function body.


func _on_WindowRobotRequest_confirm_robot_request(content):
	var temp := RBMessage.Request.new()
	temp.set_type(RBMessage.Type.ROBOT_REQUEST)
	temp.new_requestRobotRequest()
	temp.get_requestRobotRequest().set_content(content)
	ServerConnection.send_message_request(temp)
	pass # Replace with function body.

func _on_EachOpModeTab_select(op_mode_name : String):
	current_show_logs_op_mode_name = op_mode_name
	update_logs()
	pass

func _on_EachOpModeTab_delete(op_mode_name : String):
	Data.remove_op_mode_log(op_mode_name)
	update_ui()
	pass


func _on_ButtonLogsAutoBottom_toggled(button_pressed : bool):
	logs_auto_bottom = button_pressed
	pass # Replace with function body.


func _on_WindowSettings_setting_window_intro():
	_WindowIntro.activate()
	tween_fade.interpolate_property(
		_LabelInfoOpModeLogs, 
		"modulate", 
		_LabelInfoOpModeLogs.modulate, 
		Color(
			_LabelInfoOpModeLogs.modulate.r,
			_LabelInfoOpModeLogs.modulate.g,
			_LabelInfoOpModeLogs.modulate.b,
			1
		),
		0.5
	)
	tween_fade.interpolate_property(
		_LabelInfoOpModeTabs, 
		"modulate", 
		_LabelInfoOpModeTabs.modulate, 
		Color(
			_LabelInfoOpModeTabs.modulate.r,
			_LabelInfoOpModeTabs.modulate.g,
			_LabelInfoOpModeTabs.modulate.b,
			1
		),
		0.5
	)
	tween_fade.start()
	pass # Replace with function body.


func _on_WindowIntro_close():
	_WindowIntro.inactivate()
	pass # Replace with function body.


func _on_WindowIntro_inactivated():
	tween_fade.interpolate_property(
		_LabelInfoOpModeLogs, 
		"modulate", 
		_LabelInfoOpModeLogs.modulate, 
		Color(
			_LabelInfoOpModeLogs.modulate.r,
			_LabelInfoOpModeLogs.modulate.g,
			_LabelInfoOpModeLogs.modulate.b,
			0
		),
		0.5
	)
	tween_fade.interpolate_property(
		_LabelInfoOpModeTabs, 
		"modulate", 
		_LabelInfoOpModeTabs.modulate, 
		Color(
			_LabelInfoOpModeTabs.modulate.r,
			_LabelInfoOpModeTabs.modulate.g,
			_LabelInfoOpModeTabs.modulate.b,
			0
		),
		0.5
	)
	tween_fade.start()
	pass # Replace with function body.
