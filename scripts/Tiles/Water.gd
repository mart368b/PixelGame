extends TileType

class_name Water

func _init():
	self.id = 1
	self.name = "water"

func calculate_move(logic: TileLogic, old_map: Array[TileType], new_map: Array[TileType], cord: Vector2i):
	var below_tiles = logic.get_all_tiles_of(
		new_map, 
		cord, 
		[logic.Direction.BottomLeft, logic.Direction.Bottom, logic.Direction.BottomRight], 
		func(tile_type): return not tile_type.is_solid()
	)
	if below_tiles:
		var selected_tile = below_tiles.pick_random()
		logic.set_tile(new_map, selected_tile.cord, self)
		logic.set_tile(new_map, cord, logic.tile_renderer.get_tile_type("air"))
	else:
		var side_tiles = logic.get_all_tiles_of(
			new_map, 
			cord, 
			[logic.Direction.Left, logic.Direction.Right], 
			func(tile_type): return not tile_type.is_solid()
		)
		if side_tiles:
			var selected_tile = side_tiles.pick_random()
			logic.set_tile(new_map, selected_tile.cord, self)
			logic.set_tile(new_map, cord, logic.tile_renderer.get_tile_type("air"))
