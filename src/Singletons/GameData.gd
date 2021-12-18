extends Node


var current_level = null
var stardust = 0.0
var planet_health = 100.0
var refinery_count = 0


func set_things(level_node):
	current_level = level_node


func reset():
	current_level = null
	stardust = 0.0
	planet_health = 100.0
	refinery_count = 0