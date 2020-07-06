extends Node2D


signal enemy_warned(message)

const Schedule := preload("res://scene/main/Schedule.gd")
const AITemplate := preload("res://library/npc_ai/AITemplate.gd")
const ObjectData := preload("res://scene/main/ObjectData.gd")

var _ref_Schedule: Schedule
var _ref_ObjectData: ObjectData

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _new_DemoAI := preload("res://library/npc_ai/DemoAI.gd")
var _new_KnightAI := preload("res://library/npc_ai/KnightAI.gd")

var _pc: Sprite
var _ai: AITemplate
var _node_ref: Array

var _select_world: Dictionary = {
	_new_WorldTag.DEMO: _new_DemoAI,
	_new_WorldTag.KNIGHT: _new_KnightAI,
}


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_ai.take_action(_pc, current_sprite, _node_ref)
	if _ai.print_text != "":
		emit_signal("enemy_warned", _ai.print_text)
	_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	_ai = _select_world[new_world].new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if not new_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_pc = new_sprite
	_node_ref = [_ref_ObjectData]
