extends Node

signal robot_event_content_changed

var robot_event_content := []
var op_mode_logs := {
	
}
var op_mode_logs_id_pool := {
	
}

func add_robot_event_string(string : String):
	robot_event_content.append(string)
	emit_signal("robot_event_content_changed")

func add_op_mode_log(op_mode_name : String, log_string := "", timestamp : int = 0):
	if op_mode_logs.get(op_mode_name) == null:
		op_mode_logs_id_pool[op_mode_name] = 0
		op_mode_logs[op_mode_name] = {
		}
	var id = op_mode_logs_id_pool[op_mode_name]
	op_mode_logs[op_mode_name][id] = {
		"content" : log_string,
		"timestamp" : timestamp
	}
	op_mode_logs_id_pool[op_mode_name] += 1

func remove_op_mode_log(op_mode_name : String):
	if op_mode_logs.has(op_mode_name):
		op_mode_logs.erase(op_mode_name)
	if op_mode_logs_id_pool.has(op_mode_name):
		op_mode_logs_id_pool.erase(op_mode_name)
	pass
