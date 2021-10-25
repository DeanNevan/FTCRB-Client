extends WindowDialog

class_name WindowConfirmation

signal event(window, event_info)
signal ok(window)
signal cancel(window)

onready var _ButtonConfirm = $VBoxContainer/MarginContainer/HBoxContainer/CenterContainer/ButtonConfirm
onready var _ButtonCancel = $VBoxContainer/MarginContainer/HBoxContainer/CenterContainer2/ButtonCancel

onready var _Content = $VBoxContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func set_content(_text : String):
	_Content.bbcode_text = _text

func activate(content : String, title : String = "请确认···"):
	set_content(content)
	window_title = title
	popup_centered()

func _on_confirmed() -> void:
	emit_signal("ok", self)
	emit_signal("event", self, OK)


func _on_canceled() -> void:
	emit_signal("cancel", self)
	emit_signal("event", self, FAILED)


func _on_ButtonConfirm_pressed():
	_on_confirmed()
	hide()
	pass # Replace with function body.


func _on_ButtonCancel_pressed():
	_on_canceled()
	hide()
	pass # Replace with function body.
