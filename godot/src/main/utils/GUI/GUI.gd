extends Node

var Scene_LoaderCover = preload("res://src/main/ui/LoaderCover/LoaderCover.tscn")
var Scene_WindowConfirmation = preload("res://src/main/ui/WindowConfirmation/WindowConfirmation.tscn")

onready var _LayerGUI = $LayerGUI
onready var _LayerFloat = $LayerFloat

func popup_confirmation(content : String, title : String = "请确认···") -> WindowDialog:
	var instance = Scene_WindowConfirmation.instance()
	add_gui(instance)
	instance.connect("cancel", self, "_on_WindowConfirmation_cancel")
	instance.activate(content, title)
	return instance
	pass

func new_loader_cover() -> LoaderCover:
	var instance = Scene_LoaderCover.instance()
	add_gui(instance)
	return instance

func _on_WindowConfirmation_cancel(window):
	if is_instance_valid(window):
		window.queue_free()
	pass

func add_gui(gui : Node):
	_LayerGUI.add_child(gui)

func add_float_gui(gui : Node):
	_LayerFloat.add_child(gui)
