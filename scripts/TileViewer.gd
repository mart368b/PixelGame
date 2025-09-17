extends Node

@export
var shader_offset: Vector2:
	get: 
		return 	self.material.get_shader_parameter("OFFSET")
	set(value):
		self.material.set_shader_parameter("OFFSET", value)

@export_range(1.0, 4000.0)
var shader_tiles_per_screen: float:
	get: 
		return 	self.material.get_shader_parameter("TILES_PER_SCREEN")
	set(value):
		self.material.set_shader_parameter("TILES_PER_SCREEN", value)

@export
var tile_types_pixel_pr_tile: int:
	get:
		return 	self.material.get_shader_parameter("TILE_TYPES_PIXEL_PR_TILE")
	set(value):
		self.material.set_shader_parameter("TILE_TYPES_PIXEL_PR_TILE", value)
@export
var tile_types: Texture2D:
	get:
		return 	self.material.get_shader_parameter("TILE_TYPES")
	set(value):
		self.material.set_shader_parameter("TILE_TYPES", value)

var tile_type_names: Dictionary = {}

var _tile_type_config
@export_file("*.json")
var tile_type_config:
	get:
		return _tile_type_config
	set(value):
		var json_as_text = FileAccess.get_file_as_string(value)
		var json = JSON.new()
		var error = json.parse(json_as_text)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_DICTIONARY:
				tile_type_names = data_received
				_tile_type_config = value
			else:
				var error_msg = "Expected for tile type config to contain a dictionary but recieved " + type_string(typeof(data_received))
				printerr(error_msg)
				push_error(error_msg)
				_tile_type_config = null
				return
		else:
			var error_msg = "".join(["JSON Parse Error: ", json.get_error_message(), " in ", value, " at line ", json.get_error_line()])
			printerr(error_msg)
			push_error(error_msg)
			_tile_type_config = null

func get_tile_type(name: String) -> int:
	if not name in tile_type_names:
		var error_msg = "Failed to find tile type name {0}".format([name])
		push_error(error_msg)
		printerr(error_msg)
		return 0
	else:
		return tile_type_names[name]

@export
var content: PackedInt32Array:
	get:
		return 	self.material.get_shader_parameter("CONTENT")
	set(value):
		self.material.set_shader_parameter("CONTENT", value)

func _ready() -> void:
	if tile_type_config == null:
		var error_msg = "Tile type config is not set. Please go and set it before everything comlpains"
		printerr(error_msg)
		push_error(error_msg)
