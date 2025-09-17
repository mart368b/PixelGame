extends Node

@export
var tile_renderer: ColorRect;

var _map_size: Vector2i
var map: Array[int] = []

func _ready() -> void:
	_map_size = tile_renderer.tile_grid_size
	map.resize(tile_renderer.tile_grid_size.x * tile_renderer.tile_grid_size.y)
	map.fill(tile_renderer.get_tile_type("air"))

func get_tile(map: Array[int], cord: Vector2i) -> int:
	var index = cord.x % _map_size.x + cord.y * _map_size.y
	return map[index]
	
func set_tile(map: Array[int], cord: Vector2i, value: int):
	var index = cord.x % _map_size.x + cord.y * _map_size.y
	map[index] = value

func get_random_tile_type() -> int:
	var dict = tile_renderer.tile_type_configuration
	var random_key = dict.keys().pick_random()
	return dict[random_key] as int
	
func calculate_move(old_map: Array[int], new_map: Array[int], cord: Vector2i):
	set_tile(new_map, cord, get_random_tile_type())

func run_physics_tick():
	var new_map: Array[int] = []
	new_map.resize(_map_size.x * _map_size.y)
	new_map.fill(tile_renderer.get_tile_type("air"))
	
	for x in range(0, _map_size.x):
		for y in range(0, _map_size.y):
			calculate_move(map, new_map, Vector2i(x, y))
			
	map = new_map

var _time_between_updates: float = 1.0 / 10.0
var _time_to_next_update: float = _time_between_updates
func _physics_process(delta: float) -> void:
	var has_updated = false
	_time_to_next_update = _time_to_next_update - delta
	while _time_to_next_update < 0.0:
		has_updated = true
		_time_to_next_update = _time_to_next_update + _time_between_updates
		run_physics_tick()
		
	if has_updated:
		tile_renderer.content = map as PackedInt32Array
