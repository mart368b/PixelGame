extends TileType
class_name Lava

func _init():
	self.id = 4
	self.name = "lava"

func calculate_move(logic: TileLogic, old_map: Array[TileType], new_map: Array[TileType], cord: Vector2i):
	var connected_water = logic.get_all_tiles_of(
		new_map, 
		cord, 
		logic.TOUCHING_TARGET, 
		func(tile_type): return tile_type.name == "water"
	)
	if not connected_water.is_empty():
		logic.set_tile(new_map, cord, logic.tile_renderer.get_tile_type("stone"))
	else:
		var below_cord = cord + Vector2i(0.0, 1.0)
		var tile_below_tile = logic.get_tile_bounded(new_map, below_cord)
		if !tile_below_tile.is_solid():
			logic.set_tile(new_map, below_cord, self)
		elif tile_below_tile.name == "water":
			logic.set_tile(new_map, below_cord, logic.tile_renderer.get_tile_type("stone"))
