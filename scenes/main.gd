extends Node

var main_pass : Viewport
export var main_pass_path : NodePath

func _ready():
	main_pass = get_node(main_pass_path)
