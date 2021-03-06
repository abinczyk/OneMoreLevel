var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_PathFindingData := preload("res://library/PathFindingData.gd").new()


# Find the next step.
func get_path(dungeon: Dictionary, start_x: int, start_y: int) -> Array:
	var next_step: Array = []
	var neighbor: Array = _new_CoordCalculator.get_neighbor(start_x, start_y, 1)
	var min_distance: int = _new_PathFindingData.OBSTACLE

	for n in neighbor:
		if (dungeon[n[0]][n[1]] < min_distance) \
				and (dungeon[n[0]][n[1]] > _new_PathFindingData.UNKNOWN):
			min_distance = dungeon[n[0]][n[1]]
	if min_distance == _new_PathFindingData.OBSTACLE:
		return []

	for n in neighbor:
		if (dungeon[n[0]][n[1]] == min_distance):
			next_step.push_back(n)
	return next_step


# Create a distance map.
func get_map(dungeon: Dictionary, end_point: Array) -> Dictionary:
	if end_point.size() < 1:
		return dungeon

	var check: Array = end_point.pop_front()
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			check[0], check[1], 1)

	for n in neighbor:
		if dungeon[n[0]][n[1]] == _new_PathFindingData.UNKNOWN:
			dungeon[n[0]][n[1]] = _get_distance(dungeon, n)
			end_point.push_back(n)

	return get_map(dungeon, end_point)


func _get_distance(dungeon: Dictionary, center: Array) -> int:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			center[0], center[1], 1)
	var min_distance: int = _new_PathFindingData.OBSTACLE

	for n in neighbor:
		if (dungeon[n[0]][n[1]] < min_distance) \
				and (dungeon[n[0]][n[1]] > _new_PathFindingData.UNKNOWN):
			min_distance = dungeon[n[0]][n[1]]

	return min_distance + 1
