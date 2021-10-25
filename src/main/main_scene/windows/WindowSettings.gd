extends BasicInterface

signal setting_connect
signal setting_window_robot_event
signal setting_window_robot_request
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonConnect_pressed():
	emit_signal("setting_connect")
	inactivate()
	pass # Replace with function body.


func _on_ButtonWindowRobotEvent_pressed():
	emit_signal("setting_window_robot_event")
	inactivate()
	pass # Replace with function body.


func _on_ButtonWindowRobotRequest_pressed():
	emit_signal("setting_window_robot_request")
	inactivate()
	pass # Replace with function body.
