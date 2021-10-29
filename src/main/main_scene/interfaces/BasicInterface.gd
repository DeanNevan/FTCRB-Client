extends Control

class_name BasicInterface

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal activated
signal inactivated

var interface_id := "interface"
var interface_name := "界面"
var active := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	active = true
	show()
	emit_signal("activated")
	pass

func inactivate():
	active = false
	hide()
	emit_signal("inactivated")
	pass
