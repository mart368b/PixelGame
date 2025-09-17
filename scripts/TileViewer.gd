extends Node

## Suposee to movee the tiles shown but doesnt look to work
@export
var tile_grid_offset: Vector2:
	get: 
		return 	self.material.get_shader_parameter("TILE_GRID_OFFSET")
	set(value):
		self.material.set_shader_parameter("TILE_GRID_OFFSET", value)
		
@export
var tile_grid_size: Vector2i:
	get:
		return 	self.material.get_shader_parameter("TILE_GRID_SIZE")
	set(value):
		self.material.set_shader_parameter("TILE_GRID_SIZE", value)

@export
var tile_pixel_width: float:
	get:
		return 	self.material.get_shader_parameter("TILE_PIXEL_WIDTH")
	set(value):
		self.material.set_shader_parameter("TILE_PIXEL_WIDTH", value)

## Image storing the color of diffferent tile_types
@export
var tile_types: Texture2D:
	get:
		return 	self.material.get_shader_parameter("TILE_TYPES")
	set(value):
		self.material.set_shader_parameter("TILE_TYPES", value)

@export
var tile_types_pixel_pr_tile: int:
	get:
		return 	self.material.get_shader_parameter("TILE_TYPES_PIXEL_PR_TILE")
	set(value):
		self.material.set_shader_parameter("TILE_TYPES_PIXEL_PR_TILE", value)

## Internal variable to save the current path to tile_type configuration json
var _tile_type_config_path
## Contianer for the loaded tile type configuration
var tile_type_configuration: Dictionary = {}
## Path to tile type configuration file (*.json)
## This will fail and leave the configuration empty 
## if the file is not avaiable or the format is not correct
@export_file("*.json")
var tile_type_config_path:
	get:
		return _tile_type_config_path
	set(value):
		var json_as_text = FileAccess.get_file_as_string(value)
		var json = JSON.new()
		var error = json.parse(json_as_text)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_DICTIONARY:
				tile_type_configuration = data_received
				_tile_type_config_path = value
			else:
				var error_msg = "Expected for tile type config to contain a dictionary but recieved " + type_string(typeof(data_received))
				printerr(error_msg)
				push_error(error_msg)
				_tile_type_config_path = null
				return
		else:
			var error_msg = "".join(["JSON Parse Error: ", json.get_error_message(), " in ", value, " at line ", json.get_error_line()])
			printerr(error_msg)
			push_error(error_msg)
			_tile_type_config_path = null

## Get information about a given tile
func get_tile_type(name: String) -> int:
	if not name in tile_type_configuration:
		var error_msg = "Failed to find tile type name {0}".format([name])
		push_error(error_msg)
		printerr(error_msg)
		return 0
	else:
		return tile_type_configuration[name]

## Place to update tile buffer in shader
@export
var content: PackedInt32Array:
	get:
		return 	self.material.get_shader_parameter("CONTENT")
	set(value):
		self.material.set_shader_parameter("CONTENT", value)

func _ready() -> void:
	# Make sure to tell if the configuration is missing
	if tile_type_config_path == null:
		var error_msg = "Tile type config is not set. Please go and set it before everything comlpains"
		printerr(error_msg)
		push_error(error_msg)
