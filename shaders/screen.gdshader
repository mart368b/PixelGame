shader_type canvas_item ;
render_mode unshaded;

// Buffer storing all the tiles to show
// The buffer stores the tiles flattened so its size can be independant of the
// actual size of the viewed tiles
uniform int CONTENT[1000];
uniform vec2 OFFSET;
uniform float TILES_PER_SCREEN;
uniform sampler2D TILE_TYPES;
uniform int TILE_TYPES_PIXEL_PR_TILE;

vec4 get_tile_color(int tile_type) {
	vec2 tile_types_size = ceil(vec2(textureSize(TILE_TYPES, 0)) / float(TILE_TYPES_PIXEL_PR_TILE));
	vec2 position = vec2(float((tile_type % int(tile_types_size.x))), float(tile_type) / tile_types_size.x);
	
	float tile_offset = float(tile_types_size.x) / (tile_types_size.x * float(TILE_TYPES_PIXEL_PR_TILE));
	vec2 tile_position = tile_types_size;
	vec2 sample_position = position / tile_position + tile_offset;
	return texture(TILE_TYPES, sample_position);
	//return vec4(tile_types_size/4.0, 0.0, 1.0);
}

/*
vec4 get_tile_color(int tile_type) {
	vec2 position = vec2(float((tile_type % TILE_TYPE_WIDTH)), float((tile_type / TILE_TYPE_WIDTH)));
	
	float tile_offset = float(TILE_TYPE_WIDTH) / float(TILE_TYPE_WIDTH * TILE_TYPES_PIXEL_PR_TILE);
	vec2 tile_position = vec2(float(TILE_TYPE_WIDTH), float(TILE_TYPE_HEIGHT));
	vec2 sample_position = position / tile_position + tile_offset;
	return texture(TILE_TYPES, sample_position);
	//return vec4(position/float(TILE_TYPE_WIDTH), 0.0, 1.0);
}*/

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	/*
	vec2 areas_pr_screen = floor((1.0 / SCREEN_PIXEL_SIZE) / TILES_PER_SCREEN);
	vec2 offset = (1.0/areas_pr_screen) * -(OFFSET * TILES_PER_SCREEN);
	vec2 index = floor(SCREEN_UV * areas_pr_screen) / areas_pr_screen;
	vec2 index_offset = index + offset;
	vec2 mod_index = index_offset - floor(index_offset);
    // Assign the modified color to the current pixel
    COLOR = vec4(mod_index, vec2(0.0, 1.0));
	*/
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect_ratio = screen_size.y / screen_size.x;
	vec2 offset_uv = SCREEN_UV + OFFSET;
	vec2 norm_index = floor(offset_uv * vec2(1.0, aspect_ratio)  * TILES_PER_SCREEN) / TILES_PER_SCREEN;
	vec2 index_screen = norm_index * vec2(float(TILES_PER_SCREEN), float(TILES_PER_SCREEN));
	float index_content = index_screen.x + index_screen.y * TILES_PER_SCREEN;
	int tile_type = CONTENT[int(index_content)];
	vec4 tile_color = get_tile_color(tile_type);
	COLOR = tile_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
