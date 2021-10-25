extends HBoxContainer

onready var _LabelID = $LabelID
onready var _EditContent = $EditContent
onready var _LabelTime = $LabelTime

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate(id : int, content : String, time : String):
	_LabelID.text = "%d." % id
	_EditContent.text = content
	_LabelTime.text = time
	pass


