extends Label

class_name DebugLabel

signal activated(label)
signal inactivated(label)

var active := false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("DebugLabels")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	active = true
	emit_signal("activated", self)
	pass

func inactivate():
	active = false
	emit_signal("inactivated", self)
	pass
