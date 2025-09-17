@tool
extends "TileViewer.gd"

func _init() -> void:
	# Tell update shader in editor to show values
	if Engine.is_editor_hint():
		tile_grid_offset = tile_grid_offset
		tile_grid_size = tile_grid_size
		tile_pixel_width = tile_pixel_width
		tile_types = tile_types
		tile_types_pixel_pr_tile = tile_types_pixel_pr_tile
		content = content
