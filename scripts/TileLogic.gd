extends Node

@export
var tile_renderer: ColorRect;

var _map_size: Vector2i
var map: Array[int] = []

func _ready() -> void:
	_map_size = Vector2(tile_renderer.shader_tiles_per_screen, tile_renderer.shader_tiles_per_screen)
	map.resize(tile_renderer.shader_tiles_per_screen * tile_renderer.shader_tiles_per_screen)
	map.fill(tile_renderer.get_tile_type("air"))

func get_tile(map: Array[int], cord: Vector2i) -> int:
	var index = cord.x % _map_size.x + cord.y * _map_size.y
	return map[index]

func calculate_move(old_map: Array[int], new_map: Array[int]):
	var a = old_map[1]
	var b = a + 'a'
	return

func _physics_process(delta: float) -> void:
	
	var new_map: Array[int] = Array()
	new_map.resize(_map_size.x * _map_size.y)
	new_map.fill(tile_renderer.get_tile_type("air"))
	
	for x in range(0, _map_size.x):
		for y in range(0, _map_size.y):
			calculate_move(map, new_map)
			
	map = new_map
	
	tile_renderer.content = map as PackedInt32Array
