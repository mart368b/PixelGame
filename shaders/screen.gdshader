shader_type canvas_item ;
render_mode unshaded;

// Buffer storing all the tiles to show
// The buffer stores the tiles flattened so its size can be independant of the
// actual size of the viewed tiles
uniform int CONTENT[3000];
uniform vec2 TILE_GRID_OFFSET;
uniform ivec2 TILE_GRID_SIZE;
uniform float TILE_PIXEL_WIDTH;
// Image of the differnet colors used for the tile_types
uniform sampler2D TILE_TYPES;
// how wide and tall is each color sampple in the TILE_TYPES image
uniform int TILE_TYPES_PIXEL_PR_TILE;

/// retrieve the color of a tile_type
vec4 get_tile_color(int tile_type) {
	// Finds out how many tile_types is along the x axis in TILE_TYPES
	vec2 tile_types_size = ceil(vec2(textureSize(TILE_TYPES, 0)) / float(TILE_TYPES_PIXEL_PR_TILE));
	// Figure out where the looked after tile_type is in TILE_TYPES
	vec2 position = vec2(float((tile_type % int(tile_types_size.x))), float(tile_type) / tile_types_size.x);
	
	// move the sampler to the center of the tile_type color
	float tile_offset = float(tile_types_size.x) / (tile_types_size.x * float(TILE_TYPES_PIXEL_PR_TILE));
	// Find where to sample from TILE_TYPES to get tile_type color
	vec2 sample_position = position / tile_types_size + tile_offset;
	return texture(TILE_TYPES, sample_position);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Get resolution of screen
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	// Get screen aspect ratio
	float aspect_ratio = screen_size.y / screen_size.x;
	vec2 square_uv = SCREEN_UV - TILE_GRID_OFFSET / screen_size;
	vec2 grid_size = vec2(TILE_GRID_SIZE) * TILE_PIXEL_WIDTH;
	vec2 screen_placement = square_uv * screen_size;
	
	if (square_uv.x < 0.0 || square_uv.y < 0.0 || screen_placement.x > grid_size.x || screen_placement.y > grid_size.y) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		vec2 grid_placement = screen_placement / grid_size;
		vec2 grid_uv = floor(grid_placement * vec2(TILE_GRID_SIZE)) / vec2(TILE_GRID_SIZE);
		vec2 grid_index = grid_uv * vec2(TILE_GRID_SIZE);
		// Find index into content buffer
		float index_content = grid_index.x + grid_index.y * float(TILE_GRID_SIZE.x);
		// Find tile_type
		int tile_type = CONTENT[int(index_content)];
		// Convert tile_type to a color
		vec4 tile_color = get_tile_color(tile_type);
		// Export the final color
		COLOR = tile_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
