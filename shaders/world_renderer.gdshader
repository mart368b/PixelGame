shader_type canvas_item;

uniform vec2 TEXTURE_OFFSET_START_UV;
uniform vec2 TEXTURE_OFFSET_SIZE_UV;

void fragment(){
	
	//COLOR = texture(TEXTURE, texture_uv);
	COLOR = texture(TEXTURE, TEXTURE_OFFSET_START_UV +  UV * TEXTURE_OFFSET_SIZE_UV);
}