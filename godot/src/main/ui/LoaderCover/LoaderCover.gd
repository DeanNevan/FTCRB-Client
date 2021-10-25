extends Control

class_name LoaderCover

signal inactivated(loader_cover)

signal timeout(loader_cover)

onready var _TimerTimeout = $TimerTimeout
onready var _TweenSmooth = $TweenSmooth
onready var _Dark = $Dark
onready var _Label = $MarginContainer/VBoxContainer/Label
onready var _DotControl = $MarginContainer/VBoxContainer/DotControl
onready var _DotOrigin = $MarginContainer/VBoxContainer/DotControl/DotOrigin
onready var _DotSprite = $MarginContainer/VBoxContainer/DotControl/DotOrigin/DotSprite
onready var _AnimationPlayer = $AnimationPlayer

var delete_when_timeout := true

var timeout_text := ""

var is_active := true

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("left_mouse_button"):
	#	inactivate()
	
	if is_active:
		_DotControl.rect_pivot_offset = _DotControl.rect_size / 2
		_DotOrigin.position = _DotControl.rect_pivot_offset
		
		

func activate(text := "", timeout_seconds := -1.0, _timeout_text := "", _delete_when_timeout := true):
	if is_active:
		return
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_Label.text = text
	timeout_text = _timeout_text
	_AnimationPlayer.play("dot_rotate")
	_DotOrigin.start_track()
	is_active = true
	delete_when_timeout = _delete_when_timeout
	if timeout_seconds > 0:
		_TimerTimeout.start(timeout_seconds)
	_TweenSmooth.interpolate_property(self, "modulate", modulate, Color(modulate.r, modulate.g, modulate.b, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_TweenSmooth.start()
	pass


func inactivate(delete : bool = delete_when_timeout):
	if !is_active:
		return
	is_active = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _TweenSmooth.is_active():
		yield(_TweenSmooth, "tween_all_completed")
	_TweenSmooth.interpolate_property(self, "modulate", modulate, Color(modulate.r, modulate.g, modulate.b, 0), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_TweenSmooth.start()
	yield(_TweenSmooth, "tween_all_completed")
	if !is_active:
		emit_signal("inactivated", self)
		hide()
		_AnimationPlayer.stop()
		_DotOrigin.stop_track()
		if delete:
			queue_free()

func _on_TimerTimeout_timeout() -> void:
	if timeout_text != "":
		_Label.text += timeout_text
		yield(get_tree().create_timer(0.5), "timeout")
	inactivate()
	pass # Replace with function body.
