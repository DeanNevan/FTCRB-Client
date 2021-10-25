extends Reference
class_name Logger

enum LOG_LEVEL {NONE, ERROR, WARNING, INFO, VERBOSE, DEBUG}

var _level = LOG_LEVEL.ERROR
var _module = "Cashbook"

func _init(p_module : String = "Nakama", p_level : int = LOG_LEVEL.ERROR):
	_level = p_level
	_module = p_module

func _log(level : int, msg, _print := true):
	if level <= _level:
		if level == LOG_LEVEL.ERROR:
			if _print:
				printerr("=== %s : ERROR === \n%s" % [_module, str(msg)])
		else:
			var what = "=== UNKNOWN === "
			for k in LOG_LEVEL:
				if level == LOG_LEVEL[k]:
					what = "=== %s : %s === " % [_module, k]
					break
			if _print:
				print("\n" + what + str(msg))

func error(msg, _print := true):
	_log(LOG_LEVEL.ERROR, msg, _print)

func warning(msg, _print := true):
	_log(LOG_LEVEL.WARNING, msg, _print)

func info(msg, _print := true):
	_log(LOG_LEVEL.INFO, msg, _print)

func verbose(msg, _print := true):
	_log(LOG_LEVEL.VERBOSE, msg, _print)

func debug(msg, _print := true):
	_log(LOG_LEVEL.DEBUG, msg, _print)
