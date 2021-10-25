extends DebugLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	.activate()
	if !HeartBeatManager.is_connected("heart_beat", self, "_on_heart_beat"):
		HeartBeatManager.connect("heart_beat", self, "_on_heart_beat")
	if !HeartBeatManager.is_connected("timeout", self, "_on_timeout"):
		HeartBeatManager.connect("timeout", self, "_on_timeout")
	if !HeartBeatManager.is_connected("resume", self, "resume"):
		HeartBeatManager.connect("resume", self, "resume")

func inactivate():
	.inactivate()
	if HeartBeatManager.is_connected("heart_beat", self, "_on_heart_beat"):
		HeartBeatManager.disconnect("heart_beat", self, "_on_heart_beat")
	if HeartBeatManager.is_connected("timeout", self, "_on_timeout"):
		HeartBeatManager.disconnect("timeout", self, "_on_timeout")
	if HeartBeatManager.is_connected("resume", self, "resume"):
		HeartBeatManager.disconnect("resume", self, "resume")

func _on_heart_beat():
	text = str("心跳:%d" % HeartBeatManager.heart_beat_timestamp)

func _on_timeout():
	text = str("心跳超时")

func _on_resume():
	text = str("心跳重新连接")

