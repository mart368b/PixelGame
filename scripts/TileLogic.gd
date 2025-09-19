extends Node

class_name TileLogic

@export
var tile_renderer: ColorRect;

var _map_size: Vector2i
var map: Array[TileType] = []

func _ready() -> void:
	_map_size = tile_renderer.tile_grid_size
	map.resize(tile_renderer.tile_grid_size.x * tile_renderer.tile_grid_size.y)
	map.fill(tile_renderer.get_tile_type("air"))
	update_tile_renderer()

func get_tile(map: Array[TileType], cord: Vector2i) -> TileType:
	if cord.x < 0.0 || cord.x >= _map_size.x || cord.y < 0.0 || cord.y >= _map_size.y:
		# Force panic
		return map[map.size()]
	var index = cord.x % _map_size.x + cord.y * _map_size.x
	return map[index]

func get_tile_bounded(map: Array[TileType], cord: Vector2i) -> TileType:
	if cord.x < 0.0 || cord.x >= _map_size.x || cord.y < 0.0 || cord.y >= _map_size.y:
		return tile_renderer.get_tile_type("none")
	var index = cord.x % _map_size.x + cord.y * _map_size.x
	var tile = map.get(index)
	if tile == null:
		return tile_renderer.get_tile_type("none")
	else:
		return tile
	
func set_tile(map: Array[TileType], cord: Vector2i, value: TileType):
	var index = cord.x % _map_size.x + cord.y * _map_size.x
	map[index] = value

func get_random_tile_type() -> TileType:
	var dict = tile_renderer.tile_type_configuration
	var random_key = dict.keys().pick_random()
	if random_key == null:
		return TileType.new()
	else:
		return tile_renderer.get_tile_type(random_key)

enum Direction {
	TopLeft,
	Top,
	TopRight,
	Right,
	BottomRight,
	Bottom,
	BottomLeft,
	Left,
	Center
}

func get_direction_vector(direction: Direction) -> Vector2i:
	match direction:
		Direction.TopLeft:
			return Vector2i(-1.0, -1.0)
		Direction.Top:
			return Vector2i(0.0, -1.0)
		Direction.TopRight:
			return Vector2i(1.0, -1.0)
		Direction.Right:
			return Vector2i(1.0, 0.0)
		Direction.BottomRight:
			return Vector2i(1.0, 1.0)
		Direction.Bottom:
			return Vector2i(0.0, 1.0)
		Direction.BottomLeft:
			return Vector2i(-1.0, 1.0)
		Direction.Left:
			return Vector2i(-1.0, 0.0)
		Direction.Center:
			return Vector2i(0.0, 0.0)
		_:
			var error_msg = "Unknown direction to vector logic for " + str(direction)
			printerr(error_msg)
			push_error(error_msg)
			return Vector2i(0.0, 0.0)

const AROUND_TARGET: Array[Direction] = [
	Direction.TopLeft,
	Direction.Top,
	Direction.TopRight,
	Direction.Right,
	Direction.BottomRight,
	Direction.Bottom,
	Direction.BottomLeft,
	Direction.Left,
];

const TOUCHING_TARGET: Array[Direction] = [
	Direction.Top,
	Direction.Right,
	Direction.Bottom,
	Direction.Left,
];

class SelectedTile:
	var tile_type: TileType
	var cord: Vector2i
	

func get_all_tiles_of(map: Array[TileType], cord: Vector2i, directions: Array[Direction], pred: Callable) -> Array[SelectedTile]:
	var selected_tiles: Array[SelectedTile] = []
	for dir in directions:
		var new_cord = cord + get_direction_vector(dir)
		var tile_type = get_tile_bounded(map, new_cord)
		if not pred.call(tile_type):
			continue
		var selected_tile = SelectedTile.new()	
		selected_tile.cord = new_cord
		selected_tile.tile_type = tile_type
		selected_tiles.push_back(selected_tile)
	
	return selected_tiles
	

func calculate_move(old_map: Array[TileType], new_map: Array[TileType], cord: Vector2i):
	var future_tile = get_tile(new_map, cord)
	var current_tile_type = get_tile(old_map, cord)
	if future_tile != current_tile_type:
		return
	match current_tile_type.name:
		"none":
			pass
		"stone":
			pass
		"air":
			pass
		_:
			var tile = tile_renderer.get_tile_type(current_tile_type.name)
			
			if tile.has_method('calculate_move'):
				tile.calculate_move(self, old_map, new_map, cord)
				return
			
			var error_msg = "Unknown movement logic for " + current_tile_type.name
			printerr(error_msg)
			push_error(error_msg)
	#set_tile(new_map, cord, get_random_tile_type())

func run_physics_tick():
	var new_map: Array[TileType] = map.duplicate()
	
	for x in range(0, _map_size.x):
		for y in range(0, _map_size.y):
			calculate_move(map, new_map, Vector2i(x, y))
			
	map = new_map

func update_tile_renderer():
	var image = Image.create(_map_size.x, _map_size.y, false, Image.FORMAT_R8)
	
	for y in range(_map_size.y):
		for x in range(_map_size.x):
			var tile_id = map[x + y * _map_size.x].id
			image.set_pixel(x, y, Color(float(tile_id) / 255.0, 0, 0, 1))
			
	tile_renderer.content = map.map(func(tile_type): return tile_type.id) as PackedInt32Array
	tile_renderer.content_texture = ImageTexture.create_from_image(image)

var _time_between_updates: float = 1.0 / 20.0
var _time_to_next_update: float = _time_between_updates
func _physics_process(delta: float) -> void:
	var has_updated = false
	_time_to_next_update = _time_to_next_update - delta
	while _time_to_next_update < 0.0:
		has_updated = true
		_time_to_next_update = _time_to_next_update + _time_between_updates
		run_physics_tick()
		
	if has_updated:
		update_tile_renderer()

func on_grid_input(cord: Vector2i, button: MouseButton):
	if button == MOUSE_BUTTON_LEFT:
		set_tile(map, cord, tile_renderer.get_tile_type("lava"))
	if button == MOUSE_BUTTON_RIGHT:
		set_tile(map, cord, tile_renderer.get_tile_type("water_source"))
	update_tile_renderer()
	return
