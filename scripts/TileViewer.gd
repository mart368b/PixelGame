extends Node

const TileType := preload("res://scripts/TileType.gd")

## Suposee to movee the tiles shown but doesnt look to work
@export
var tile_grid_offset: Vector2:
	get: 
		return 	self.material.get_shader_parameter("TILE_GRID_OFFSET")
	set(value):
		self.material.set_shader_parameter("TILE_GRID_OFFSET", value)
		
@export
var tile_grid_size: Vector2:
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
## When changed it will update the stored configuration
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
				tile_type_configuration = {} 
				var missing_data = false
				for data_key in data_received:
					var data_value = data_received[data_key]
					
					# Manually convert dict from json to TileType
					# would love to have this in TIleType.gd but i have yet to figure out how
					var tile_type = TileType.new()
					if not "id" in data_value:
						var error_msg = "Expected for " + data_key + " to contain an id field"
						printerr(error_msg)
						push_error(error_msg)
						_tile_type_config_path = null
						missing_data = true
						continue
					
					tile_type.id = data_value.id
					tile_type.name = data_key
					
					tile_type_configuration[data_key] = tile_type
				
				if missing_data:
					return
					
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
func get_tile_type(name: String) -> TileType:
	if not name in tile_type_configuration:
		var error_msg = "Failed to find tile type name {0}".format([name])
		push_error(error_msg)
		printerr(error_msg)
		return TileType.new()
	else:
		return tile_type_configuration.get(name)

## Place to update tile buffer in shader
@export
var content: PackedInt32Array:
	get:
		return 	self.material.get_shader_parameter("CONTENT")
	set(value):
		self.material.set_shader_parameter("CONTENT", value)

@export
var content_texture: Texture:
	get:
		return self.material.get_shader_parameter("CONTENT_TEXTURE")
	set(value):
		self.material.set_shader_parameter("CONTENT_TEXTURE", value)

func _ready() -> void:
	# Make sure to tell if the configuration is missing
	if tile_type_config_path == null:
		var error_msg = "Tile type config is not set. Please go and set it before everything comlpains"
		printerr(error_msg)
		push_error(error_msg)

signal grid_input(cord: Vector2i, button: MouseButton)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var position: Vector2 = event.position
		var grid_position = floor((position - tile_grid_offset) / tile_pixel_width)
		var grid_size = tile_grid_size
		if grid_position >= Vector2(0.0, 0.0) && grid_position.x < float(grid_size.x) && grid_position.y < float(grid_size.y):
			grid_input.emit(Vector2i(grid_position), event.button_index)
