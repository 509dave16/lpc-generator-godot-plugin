@tool
extends EditorPlugin

var dock
	
func _enter_tree():
	var packed_scene: PackedScene = load("res://addons/lpccharactergenerator/generator_dock.tscn")
	dock = packed_scene.instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
