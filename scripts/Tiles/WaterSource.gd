extends TileType

class_name WaterSource

func _init():
	self.id = 1
	self.name = "water_source"

func calculate_move(logic: TileLogic, cord: Vector2i):
	var free_spots = logic.get_all_tiles_of(
		cord, 
		logic.AROUND_TARGET, 
		func(tile_type): return tile_type.name == "air"
	)
	for try in range(0, 5):
		if not free_spots.is_empty():
			var idx = randi() % free_spots.size()
			var removed = free_spots.pop_at(idx)
			logic.set_tile(removed.cord, logic.tile_renderer.get_tile_type("water"))
		else: 
			break
