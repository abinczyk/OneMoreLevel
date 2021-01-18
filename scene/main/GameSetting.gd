extends Node2D
class_name Game_GameSetting


signal setting_loaded()

const WIZARD: String = "wizard_mode"
const SEED: String = "rng_seed"
const WORLD: String = "world_tag"

const EXE_PATH: String = "data/setting.json"
const RES_PATH: String = "res://bin/data/setting.json"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _wizard_mode: bool
var _rng_seed: int
var _world_tag: String


func load_setting() -> void:
	var setting_file: File = File.new()
	var load_path: String = ""
	var setting_data: Dictionary
	var __

	for i in [EXE_PATH, RES_PATH]:
		if setting_file.file_exists(i):
			load_path = i
			break
	if load_path == "":
		setting_data = {}
	else:
		__ = setting_file.open(load_path, File.READ)
		setting_data = JSON.parse(setting_file.get_as_text()).get_result()
		setting_file.close()

	_wizard_mode = _set_wizard_mode(setting_data)
	_rng_seed = _set_rng_seed(setting_data)
	_world_tag = _set_world_tag(setting_data)

	emit_signal("setting_loaded")


func get_wizard_mode() -> bool:
	return _wizard_mode


func get_rng_seed() -> int:
	return _rng_seed


func get_world_tag() -> String:
	return _world_tag


func _set_wizard_mode(setting) -> bool:
	if not setting.has(WIZARD):
		return false
	return setting[WIZARD] as bool


func _set_rng_seed(setting) -> int:
	var random: int

	if not setting.has(SEED):
		return 0
	random = setting[SEED] as int
	return 0 if random < 1 else random


func _set_world_tag(setting) -> String:
	if not setting.has(WORLD):
		return ""
	if not _new_WorldTag.is_valid_world_tag(setting[WORLD]):
		return ""
	return setting[WORLD] as String
