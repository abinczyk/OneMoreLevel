extends "res://library/pc_action/PCActionTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func wait() -> void:
	end_turn = false


# TODO: Fill progress bar.
func attack() -> void:
	var x: int = _target_position[0]
	var y: int = _target_position[1]
	var worm: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.ACTOR, x, y)

	if (not worm.is_in_group(_new_SubGroupTag.SPICE)) \
			or _ref_ObjectData.verify_state(worm, _new_ObjectStateTag.PASSIVE):
		end_turn = false
		return

	_ref_ObjectData.set_state(worm, _new_ObjectStateTag.PASSIVE)
	_ref_SwitchSprite.switch_sprite(worm, _new_SpriteTypeTag.PASSIVE)
	_ref_CountDown.hit_bonus()
	end_turn = true


# TODO: Fill progress bar.
func interact_with_trap() -> void:
	_ref_CountDown.hit_bonus()
	_remove_building_or_trap(false)


func interact_with_building() -> void:
	_remove_building_or_trap(true)


func _remove_building_or_trap(is_building: bool) -> void:
	var x: int = _target_position[0]
	var y: int = _target_position[1]

	if is_building:
		_ref_RemoveObject.remove(_new_MainGroupTag.BUILDING, x, y)
	else:
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
	end_turn = true
