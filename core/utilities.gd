# Utilities.gd
extends Node

signal signalMessage

func Clear_Childs(node: Node, groupName: String) -> void:
	for child in node.get_children():
		if child.is_in_group(groupName):
			child.name = child.name + "_Garbage"
			child.queue_free()

func Print_Message(message: String) -> void:
	signalMessage.emit(message)

func Start_Pulse_UI(targetNode: Control, speed: float = 0.5) -> Tween:
	var tween: Tween = targetNode.create_tween().set_loops()
	
	tween.tween_property(targetNode, "self_modulate:a", 0.3, speed)
	tween.tween_property(targetNode, "self_modulate:a", 1.0, speed)
	
	return tween

func Stop_Pulse_UI(targetNode: Control, tween: Tween) -> void:
	if tween and tween.is_valid():
		tween.kill()
	
	if is_instance_valid(targetNode):
		targetNode.self_modulate.a = 1.0
