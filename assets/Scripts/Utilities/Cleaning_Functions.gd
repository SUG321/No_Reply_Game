class_name Cleaner
extends RefCounted

static func Clear_Childs(node3D: Node3D, groupName: String) -> void:
	for child in node3D.get_children():
		if child.is_in_group(groupName):
			child.queue_free()
