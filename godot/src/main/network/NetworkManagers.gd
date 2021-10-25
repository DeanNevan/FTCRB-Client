extends Node

var managers := [
	
]

func register(_manager : Object):
	managers.append(_manager)
	pass

func all_work():
	for i in managers:
		i.call("work")

func all_stop():
	for i in managers:
		i.call("stop")
