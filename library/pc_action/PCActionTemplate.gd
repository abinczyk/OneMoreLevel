# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const RemoveObject := preload("res://scene/main/RemoveObject.gd")
const ObjectData := preload("res://scene/main/ObjectData.gd")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")

var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn

var _ref_DungeonBoard: DungeonBoard
var _ref_RemoveObject: RemoveObject
var _ref_ObjectData: ObjectData
var _ref_RandomNumber: RandomNumber

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()

var _source_position: Array
var _target_position: Array
var _direction_to_coord: Dictionary = {
	_new_InputTag.MOVE_UP: [0, -1],
	_new_InputTag.MOVE_DOWN: [0, 1],
	_new_InputTag.MOVE_LEFT: [-1, 0],
	_new_InputTag.MOVE_RIGHT: [1, 0],
}


# Refer: PlayerInput.gd.
func _init(parent_node: Node2D) -> void:
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_RandomNumber = parent_node._ref_RandomNumber


func get_message() -> String:
	return message


func set_message(_message: String) -> void:
	pass


func get_end_turn() -> bool:
	return end_turn


func set_end_turn(_end_turn: bool) -> void:
	pass


func is_ground(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	var x: int = _target_position[0]
	var y: int = _target_position[1]

	return not _is_occupied(x, y)


func is_npc(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])


func is_building(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			_target_position[0], _target_position[1])


func move() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)
	end_turn = true


func attack() -> void:
	_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])
	end_turn = true


func interact() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_state() -> void:
	end_turn = false


func _set_source_target_positions(source: Array, direction: String) -> void:
	var shift: Array = _direction_to_coord[direction]

	_source_position = source
	_target_position = [source[0] + shift[0], source[1] + shift[1]]


func _is_occupied(x: int, y: int) -> bool:
	return (not _new_CoordCalculator.is_inside_dungeon(x, y)) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)
