extends BasicInterface

signal confirm_connect(ip, port)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var _EditIP = $MarginContainer/VBoxContainer/HBoxContainer/EditIP
onready var _EditPort = $MarginContainer/VBoxContainer/HBoxContainer2/EditPort

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	_EditIP.text = ServerConnection.ip
	_EditPort.value = ServerConnection.port
	.activate()


func _on_ButtonConfirm_pressed():
	emit_signal("confirm_connect", _EditIP.text, _EditPort.value)
	inactivate()
	pass # Replace with function body.


func _on_ButtonCancel_pressed():
	inactivate()
	pass # Replace with function body.
