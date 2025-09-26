extends Object
class_name TileC

enum TILE_TYPE {
	NONE = 0,
	AIR = 1,
	WATER = 2,
	LAVA = 3
}

var tile_type: TILE_TYPE = TILE_TYPE.NONE

func _init(new_tile_type: TILE_TYPE = TILE_TYPE.NONE) -> void:
	self.tile_type = new_tile_type
