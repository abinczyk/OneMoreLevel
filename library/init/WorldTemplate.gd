class_name Game_WorldTemplate
# Scripts such as Init[DungeonType].gd inherit this script.
# Override get_blueprint() and _set_dungeon_board().
# The child should also implement _init() to pass arguments.


const SPRITE_BLUEPRINT := preload("res://library/init/SpriteBlueprint.gd")

var _spr_Floor := preload("res://sprite/Floor.tscn")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

var _ref_RandomNumber: Game_RandomNumber

# {0: [], 1: [], ...}
var _dungeon: Dictionary = {}
# [SpriteBlueprint, ...]
var _blueprint: Array = []


func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber

	_set_dungeon_board()
	_init_floor()


# Child scripts should implement _init() to pass arguments.
# func _init(_random: RandomNumber).(_random) -> void:
# 	pass


# Override.
func get_blueprint() -> Array:
	return _blueprint


# Override.
func _set_dungeon_board() -> void:
	pass


func _add_to_blueprint(scene: PackedScene,
		main_group: String, sub_group: String, x: int, y: int) -> void:
	_blueprint.push_back(SPRITE_BLUEPRINT.new(
			scene, main_group, sub_group, x, y))


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_add_to_blueprint(_spr_Floor,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR,
					i, j)
