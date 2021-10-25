extends WindowDialog

var active := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	active = true
	popup()

func inactivate():
	active = false
	hide()
