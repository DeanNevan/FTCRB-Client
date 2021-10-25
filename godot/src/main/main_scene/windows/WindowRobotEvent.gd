extends BasicInterface

onready var _RichTextLabel = $MarginContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	Data.connect("robot_event_content_changed", self, "_on_Data_robot_event_content_changed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	update_content()
	.activate()

func update_content():
	_RichTextLabel.bbcode_text = "[center]---机器人事件---[/center]\n"
	for i in Data.robot_event_content:
		_RichTextLabel.bbcode_text += i
		_RichTextLabel.bbcode_text += "\n"
	pass

func _on_Data_robot_event_content_changed():
	update_content()
	pass
