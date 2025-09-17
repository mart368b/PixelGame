@tool
extends "TileViewer.gd"

func _init() -> void:
	if Engine.is_editor_hint():
		shader_offset = shader_offset
		shader_tiles_per_screen = shader_tiles_per_screen
		tile_types = tile_types
		tile_types_pixel_pr_tile = tile_types_pixel_pr_tile
		content = content
