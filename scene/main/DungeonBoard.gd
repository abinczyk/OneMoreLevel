extends Node2D
class_name Game_DungeonBoard


var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

# <main_group: String, <column: int, [sprite]>>
var _sprite_dict: Dictionary
var _pc: Sprite

var _valid_main_groups: Array = [
	_new_MainGroupTag.GROUND,
	_new_MainGroupTag.ACTOR,
	_new_MainGroupTag.BUILDING,
	_new_MainGroupTag.TRAP,
]

var _sub_group_to_sprite: Dictionary = {
	_new_SubGroupTag.ARROW_RIGHT: null,
	_new_SubGroupTag.ARROW_DOWN: null,
	_new_SubGroupTag.ARROW_UP: null,
}


func _ready() -> void:
	_init_dict()


func has_sprite(main_group: String, x: int, y: int) -> bool:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return false
	if not _sprite_dict.has(main_group):
		return false
	if not _sprite_dict[main_group].has(x):
		return false
	return _sprite_dict[main_group][x][y] != null


func has_sprite_with_sub_tag(main_group: String, sub_group: String,
		x: int, y: int) -> bool:
	var find_sprite: Sprite = get_sprite(main_group, x, y)

	if find_sprite == null:
		return false
	return find_sprite.is_in_group(sub_group)


func get_sprite(main_group: String, x: int, y: int) -> Sprite:
	if has_sprite(main_group, x, y):
		return _sprite_dict[main_group][x][y]
	return null


# There should be only one sprite in the group `_new_SubGroupTag.PC`.
# The PC sprite should not be removed throughout the game.
func get_pc() -> Sprite:
	var find_pc: Array

	if _pc == null:
		find_pc = get_sprites_by_tag(_new_SubGroupTag.PC)
		if find_pc.size() > 0:
			_pc = find_pc[0]
	return _pc


# When we call `foobar.queue_free()`, the node foobar will be deleted at the end
# of the current frame if there are no references to it.
#
# However, if we set a reference to foobar in the same frame by, let's say,
# `get_tree().get_nodes_in_group()`, foobar will not be deleted when the current
# frame ends.
#
# Therefore, after calling `get_tree().get_nodes_in_group()`, we need to check
# if such nodes will be deleted with `foobar.is_queued_for_deletion()` to avoid
# potential bugs.
#
# You can reproduce such a bug in v0.1.3 with the seed 1888400396. Refer to this
# video for more information.
#
# https://youtu.be/agqdag6GqpU
func get_sprites_by_tag(group_tag: String) -> Array:
	var sprites: Array = []
	var verify: Sprite
	var counter: int = 0

	sprites = get_tree().get_nodes_in_group(group_tag)
	# Filter elements in a more efficent way based on `u/kleonc`'s suggestion.
	# https://www.reddit.com/r/godot/comments/kq4c91/beware_that_foobarqueue_free_removes_foobar_at/gi3femf
	for i in range(sprites.size()):
		verify = sprites[i]
		if verify.is_queued_for_deletion():
			continue
		sprites[counter] = verify
		counter += 1
	sprites.resize(counter)

	return sprites
	# return get_tree().get_nodes_in_group(group_tag)


func move_sprite(main_group: String, source: Array, target: Array) -> void:
	var sprite: Sprite = get_sprite(main_group, source[0], source[1])
	if sprite == null:
		return

	_sprite_dict[main_group][source[0]][source[1]] = null
	_sprite_dict[main_group][target[0]][target[1]] = sprite
	sprite.position = _new_ConvertCoord.index_to_vector(target[0], target[1])

	_try_move_arrow(sprite)


func swap_sprite(main_group: String, source: Array, target: Array) -> void:
	var source_sprite: Sprite = get_sprite(main_group, source[0], source[1])
	var target_sprite: Sprite = get_sprite(main_group, target[0], target[1])

	if (source_sprite == null) or (target_sprite == null):
		return

	_sprite_dict[main_group][source[0]][source[1]] = target_sprite
	_sprite_dict[main_group][target[0]][target[1]] = source_sprite

	source_sprite.position = _new_ConvertCoord.index_to_vector(
			target[0], target[1])
	target_sprite.position = _new_ConvertCoord.index_to_vector(
			source[0], source[1])

	_try_move_arrow(source_sprite)
	_try_move_arrow(target_sprite)


func _on_CreateObject_sprite_created(new_sprite: Sprite) -> void:
	var pos: Array
	var group: String

	# Save references to arrow indicators.
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		for sg in _sub_group_to_sprite.keys():
			if new_sprite.is_in_group(sg):
				_sub_group_to_sprite[sg] = new_sprite
		return

	# Save references to dungeon sprites.
	for mg in _valid_main_groups:
		if new_sprite.is_in_group(mg):
			group = mg
			break
	if group == "":
		return
	pos = _new_ConvertCoord.vector_to_array(new_sprite.position)
	_sprite_dict[group][pos[0]][pos[1]] = new_sprite


func _on_RemoveObject_sprite_removed(_sprite: Sprite, main_group: String,
		x: int, y: int) -> void:
	_sprite_dict[main_group][x][y] = null


func _init_dict() -> void:
	for mg in _valid_main_groups:
		_sprite_dict[mg] = {}
		for x in range(_new_DungeonSize.MAX_X):
			_sprite_dict[mg][x] = []
			_sprite_dict[mg][x].resize(_new_DungeonSize.MAX_Y)


# Move arrow indicators when PC moves.
func _try_move_arrow(sprite: Sprite) -> void:
	if not sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_sub_group_to_sprite[_new_SubGroupTag.ARROW_RIGHT] \
			.position.y = sprite.position.y
	_sub_group_to_sprite[_new_SubGroupTag.ARROW_DOWN] \
			.position.x = sprite.position.x
	_sub_group_to_sprite[_new_SubGroupTag.ARROW_UP] \
			.position.x = sprite.position.x
