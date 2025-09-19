extends Object
class_name TileType

var id: int
var name: String

func is_solid() -> bool:
	match self.name:
		"none":
			return true
		"lava":
			return true
		"water":
			return true
		"water_source":
			return true
		"stone":
			return true
		"air":
			return false
		_:
			var error_msg = "Unknown is_solid logic for " + self.name
			printerr(error_msg)
			push_error(error_msg)
			return true
