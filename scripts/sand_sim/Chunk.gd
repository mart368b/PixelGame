extends Object
class_name Chunk

var tiles: Array
var cord: Vector2i
var size: Vector2i

func _init(chunk_cord: Vector2i = Vector2i(0.0, 0.0), chunk_size: Vector2i = Vector2i(0.0, 0.0)):
	self.cord = chunk_cord
	self.size = chunk_size
	
	tiles = Array()
	for y in range(0, chunk_size.y):
		var row = Array()
		for x in range(0, chunk_size.x):
			row.append(TileC.new())
		tiles.append(row)
