extends BasicInterface

signal confirm_robot_request(content)

onready var _TextEdit = $MarginContainer/VBoxContainer/TextEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonConfirm_pressed():
	emit_signal("confirm_robot_request", _TextEdit.text)
	inactivate()
	pass # Replace with function body.


func _on_ButtonCancel_pressed():
	inactivate()
	pass # Replace with function body.
