const INVALID: String = "INVALID"
const DEMO: String = "demo"

const KNIGHT: String = "knight"
const CORRUPTION: String = "corruption"

var _world_tag: Array = [
	KNIGHT, CORRUPTION,
]

var _tag_to_name: Dictionary = {
	DEMO: "Demo",
	KNIGHT: "Knight",
	CORRUPTION: "Corruption",
}


func get_world_name(world_tag: String) -> String:
	if _tag_to_name.has(world_tag):
		return _tag_to_name[world_tag]
	return INVALID


func get_full_world_tag() -> Array:
	return _world_tag


func is_valid_world_tag(world_tag: String) -> bool:
	return (world_tag == DEMO) or (world_tag in _world_tag)
