extends DebugLabel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var update_period := 0.5

onready var TimerUpdate = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(TimerUpdate)
	TimerUpdate.one_shot = false
	TimerUpdate.autostart = false
	TimerUpdate.connect("timeout", self, "_on_TimerUpdate_timeout")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	.activate()
	TimerUpdate.paused = false
	TimerUpdate.start(update_period)

func inactivate():
	.inactivate()
	TimerUpdate.paused = true


func _on_TimerUpdate_timeout():
	text = "ping: " + String(ServerConnection.get_ping())
	pass
