extends Node

signal heart_beat
signal timeout
signal resume

var logger = Logger.new("心跳管理器", Logger.LOG_LEVEL.DEBUG)

var heart_beat_timestamp = 0
var server_heart_beat_timestamp = 0

var period_seconds := 3.0

var timeout := false

var timeout_seconds := 10.0

onready var timer_heart_beat = $TimerHeartBeat

var waiting_heat_beat := false

func _ready() -> void:
	NetworkManagers.register(self)
	heart_beat_timestamp = OS.get_system_time_msecs()
	ServerConnection.connect("responsed", self, "_on_ServerConnection_responsed")

func work():
	heart_beat_timestamp = OS.get_system_time_msecs()
	timer_heart_beat.start(period_seconds)
	pass

func stop():
	timer_heart_beat.stop()
	pass

func _send_heart_beat() -> void:
	if (!ServerConnection.connected):
		return
	waiting_heat_beat = true
	var temp := RBMessage.Request.new()
	temp.set_type(RBMessage.Type.HEARTBEAT)
	ServerConnection.send_message_request(temp)
	logger.debug("发送心跳包", false)
	pass

func _on_Timer_timeout() -> void:
	var period : int = Global.get_local_timestamp() - heart_beat_timestamp
	#print(period)
	if (period / 1000.0) > timeout_seconds:
		timeout = true
		emit_signal("timeout")
	if ServerConnection.connected:
		_send_heart_beat()
	pass # Replace with function body.

func _on_ServerConnection_responsed(response : RBMessage.Response):
	match response.get_type():
		RBMessage.Type.HEARTBEAT:
			logger.debug("收到心跳包", false)
			emit_signal("heart_beat")
			if timeout:
				timeout = false
				emit_signal("resume")
			server_heart_beat_timestamp = response.get_timestamp()
			heart_beat_timestamp = Global.get_local_timestamp()
			waiting_heat_beat = false
	pass
