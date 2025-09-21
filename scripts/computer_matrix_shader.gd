extends Control

@export_file("*.glsl") var shader_file: String

@export
var tile_renderer: ColorRect;

var map_size: int = 8
var input := PackedFloat32Array([
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	0, 0, 2, 0, 0, 0, 2, 0,
	3, 3, 3, 3, 3, 3, 3, 3
])

var rd: RenderingDevice
var shader_rid: RID
var uniform_set: RID
var pipeline: RID
var buffer_rid: RID
var map_size_rid: RID

func init_gpu():
	rd = RenderingServer.create_local_rendering_device()
	# Load GLSL shader
	shader_rid = load_shader(rd, shader_file)

	var input_bytes = input.to_byte_array()
	buffer_rid = rd.storage_buffer_create(input_bytes.size(), input_bytes)

	var mapUniform := RDUniform.new()
	mapUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	mapUniform.binding = 0
	mapUniform.add_id(buffer_rid)

	var static_bytes := PackedInt32Array([map_size]).to_byte_array()
	map_size_rid = rd.storage_buffer_create(static_bytes.size(), static_bytes)

	var staticDataUniform := RDUniform.new()
	staticDataUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	staticDataUniform.binding = 1
	staticDataUniform.add_id(map_size_rid)

	uniform_set = rd.uniform_set_create([mapUniform, staticDataUniform], shader_rid, 0)
	pipeline = rd.compute_pipeline_create(shader_rid)


func load_shader(p_rd: RenderingDevice, path: String) -> RID:
	var shader_file_data: RDShaderFile = load(path)
	var shader_spirv: RDShaderSPIRV = shader_file_data.get_spirv()
	return p_rd.shader_create_from_spirv(shader_spirv)

func _process(delta: float) -> void:
	if rd == null:
		init_gpu()

	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, input.size() / 2, 1, 1)
	rd.compute_list_end()

	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()

	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(buffer_rid)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)

	input = output
	
	update_texture()

func update_texture():
	var image = Image.create(map_size, map_size, false, Image.FORMAT_R8)
	
	for y in range(map_size):
		for x in range(map_size):
			var tile_id = input[x % map_size + y * map_size]
			print(tile_id)
			image.set_pixel(x, y, Color(float(tile_id) / 255.0, 0, 0, 1))
			
	tile_renderer.content_texture = ImageTexture.create_from_image(image)

func _notification(what: int) -> void:
	# Object destructor, triggered before the engine deletes this Node.
	if what == NOTIFICATION_PREDELETE:
		cleanup_gpu()

func cleanup_gpu():
	rd.free_rid(pipeline)

	rd.free_rid(uniform_set)

	rd.free()
