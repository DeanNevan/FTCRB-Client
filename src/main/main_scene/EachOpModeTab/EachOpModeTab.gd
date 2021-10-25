extends HBoxContainer

signal delete(op_mode_name)
signal select(op_mode_name)

var op_mode_name := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate(_op_mode_name : String):
	op_mode_name = _op_mode_name
	$ButtonTabOpMode.text = op_mode_name
	pass


func _on_ButtonDelete_pressed():
	emit_signal("delete", op_mode_name)
	pass # Replace with function body.


func _on_ButtonTabOpMode_pressed():
	emit_signal("select", op_mode_name)
	pass # Replace with function body.
