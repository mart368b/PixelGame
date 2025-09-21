extends TileType
class_name Lava

func _init():
	self.id = 4
	self.name = "lava"

func calculate_move(logic: TileLogic, cord: Vector2i):
	var connected_water = logic.get_all_tiles_of(
		cord, 
		logic.TOUCHING_TARGET, 
		func(tile_type): return tile_type.name == "water"
	)
	if not connected_water.is_empty():
		logic.set_tile(cord, logic.tile_renderer.get_tile_type("stone"))
	else:
		var below_cord = cord + Vector2i(0.0, 1.0)
		var tile_below_tile = logic.get_tile_bounded(below_cord)
		if !tile_below_tile.is_solid():
			logic.set_tile(below_cord, self)
		elif tile_below_tile.name == "water":
			logic.set_tile(below_cord, logic.tile_renderer.get_tile_type("stone"))
