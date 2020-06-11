extends "res://library/init/WorldTemplate.gd"
# Initialize a map for Silent Knight Hall (Knight).


const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Wall := preload("res://sprite/Wall.tscn")


func _init(_random: RandomNumber).(_random) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_PC()
	# _init_dwarf()

	return _blueprint


# {0: [false, ...], 1: [false, ...], ...}
func _set_dungeon_board() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		_dungeon[i] = []
		for _j in range(_new_DungeonSize.MAX_Y):
			_dungeon[i].push_back(false)


func _init_wall() -> void:
	var max_retry: int = 10000

	for _i in range(max_retry):
		_create_solid_wall()


func _create_solid_wall() -> void:
	var min_start: int
	var start_x: int
	var start_y: int
	var max_x: int
	var max_y: int

	var min_size: int
	var max_size: int
	var width: int
	var height: int
	var shrinked: Array

	var dig: Array
	var dig_x: int
	var dig_y: int

	# Initialize data.
	# Start from [-1, -1] as the block will be shrinked later.
	min_start = -1
	start_x = _ref_RandomNumber.get_int(min_start, _new_DungeonSize.MAX_X)
	start_y = _ref_RandomNumber.get_int(min_start, _new_DungeonSize.MAX_Y)
	# The actual border length is from 2 to 3.
	min_size = 4
	max_size = 6
	width = _ref_RandomNumber.get_int(min_size, max_size)
	height = _ref_RandomNumber.get_int(min_size, max_size)

	# Verify the starting point and size. The block can extend over the edge of
	# the map, but cannot overlap existing blocks.
	if not _is_valid_block(start_x, start_y, width, height):
		return

	# Shrink the wall block in four directions by 1 grid.
	shrinked = _shrink_block(start_x, start_y, width, height)
	start_x = shrinked[0]
	start_y = shrinked[1]
	max_x = shrinked[2]
	max_y = shrinked[3]

	# Decide which grid to dig.
	dig = _dig_border(start_x, start_y, max_x, max_y)
	dig_x = dig[0]
	dig_y = dig[1]

	if not _is_valid_hole(dig_x, dig_y, start_x, start_y, max_x, max_y):
		dig_x = -1
		dig_y = -1

	# Set blueprint and dungeon board.
	for x in range(start_x, max_x):
		for y in range(start_y, max_y):
			# Do not generate wall blocks outside the map.
			if not _new_DungeonSize.is_inside_dungeon(x, y):
				continue
			# Every wall block might lose one grid.
			if (x == dig_x) and (y == dig_y):
				continue

			# Add wall blocks to blueprint and set dungeon board.
			_add_to_blueprint(Wall,
					_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
					x, y)
			_occupy_position(x, y)


func _is_valid_block(start_x: int, start_y: int, width: int, height: int) \
		-> bool:
	for x in range(start_x, start_x + width):
		for y in range(start_y, start_y + height):
			if not _new_DungeonSize.is_inside_dungeon(x, y):
				continue
			if _is_occupied(x, y):
				return false
	return true


func _shrink_block(start_x: int, start_y: int, width: int, height: int) \
		-> Array:
	start_x += 1
	start_y += 1
	var max_x: int = start_x + width - 2
	var max_y: int = start_y + height - 2

	return [start_x, start_y, max_x, max_y]


func _dig_border(start_x: int, start_y: int, max_x: int, max_y: int) -> Array:
	var dig_x: int
	var dig_y: int
	var border: int = _ref_RandomNumber.get_int(0, 5)

	match border:
		# Top.
		0:
			dig_x = _ref_RandomNumber.get_int(start_x, max_x)
			dig_y = start_y
		# Right.
		1:
			dig_x = max_x - 1
			dig_y = _ref_RandomNumber.get_int(start_y, max_y)
		# Bottom.
		2:
			dig_x = _ref_RandomNumber.get_int(start_x, max_x)
			dig_y = max_y - 1
		# Left.
		3:
			dig_x = start_x
			dig_y = _ref_RandomNumber.get_int(start_y, max_y)
		# Do not dig.
		4:
			dig_x = -1
			dig_y = -1

	return [dig_x, dig_y]


func _is_valid_hole(dig_x: int, dig_y: int, \
		start_x: int, start_y: int, max_x: int, max_y: int) -> bool:
	if not _new_DungeonSize.is_inside_dungeon(dig_x, dig_y):
		return false

	var neighbor: Array = [
		[dig_x - 1, dig_y],
		[dig_x + 1, dig_y],
		[dig_x, dig_y - 1],
		[dig_x, dig_y + 1],
	]

	for n in neighbor:
		if not _new_DungeonSize.is_inside_dungeon(n[0], n[1]):
			continue
		elif (n[0] < start_x) or (n[0] >= max_x) \
				or (n[1] < start_y) or (n[1] >= max_y):
			return true
	return false


func _init_PC() -> void:
	var position: Array = _get_PC_position()

	while _dungeon[position[0]][position[1]]:
		position = _get_PC_position()

	_add_to_blueprint(Player,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			position[0], position[1])


func _get_PC_position() -> Array:
	var x: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
	var y: int = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

	return [x, y]


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X - 1)
		y = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_Y - 1)

		if _is_occupied(x, y):
			continue
		_add_to_blueprint(Dwarf,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.DWARF,
				x, y)
		_occupy_position(x, y)

		dwarf -= 1


func _occupy_position(x: int, y: int) -> void:
	_dungeon[x][y] = true


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon[x][y]