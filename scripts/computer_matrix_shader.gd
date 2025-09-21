extends Control

@export_file("*.glsl") var shader_file: String

@export
var debug_renderer: TextureRect;

@export var map_size: int;
var input := PackedFloat32Array()

var rd: RenderingDevice
var shader_rid: RID
var uniform_set: RID
var pipeline: RID
var buffer_rid: RID
var map_size_rid: RID

func _ready() -> void:
	
	input.resize(map_size*map_size)
	
	for y in range(map_size - 1):
		var row = PackedFloat32Array()
		row.resize(map_size)
		row.fill(0.0)
		input.append_array(row)
	
	var bedrock = PackedFloat32Array()
	bedrock.resize(map_size)
	bedrock.fill(2.0)
	input.append_array(bedrock)
	
	for y in range(map_size - 1):
		input[map_size / 2 % map_size + y * map_size] = 1.0
	
	input[10 % map_size + 10 * map_size] = 1
		
	print("MapSize: %d" % map_size)
	print("TileCount: %d" % (map_size*map_size))
	print("Input Size: %d" % input.size())
	

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

	var input_bytes = input.to_byte_array()
	rd.buffer_update(buffer_rid, 0, input_bytes.size(), input_bytes)

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
	
	input = output
	
	update_texture()

func update_texture():
	var debugImage = Image.create(map_size, map_size, false, Image.FORMAT_RGB8)

	for y in range(map_size):
		for x in range(map_size):
			var tile_id = input[x % map_size + y * map_size]
			if tile_id == 0.0:
				debugImage.set_pixel(x, y, Color(255, 255, 255, 1))
			else:
				debugImage.set_pixel(x, y, Color(255.0 / float(tile_id), 0, 0, 1))

	debug_renderer.texture = ImageTexture.create_from_image(debugImage)

func _notification(what: int) -> void:
	# Object destructor, triggered before the engine deletes this Node.
	if what == NOTIFICATION_PREDELETE:
		cleanup_gpu()

func cleanup_gpu():
	rd.free_rid(pipeline)

	rd.free_rid(uniform_set)

	rd.free()
