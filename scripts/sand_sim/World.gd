@tool

extends Control
class_name World

@export
var loaded_chunks: Dictionary

var _additional_chunks: Vector2i = Vector2i()
@export
var additional_chunks: Vector2i:
	get:
		return _additional_chunks
	set(value):
		_additional_chunks = value
		if Engine.is_editor_hint():
			reload_chunks()

var _chunk_size: Vector2i = Vector2i()
@export
var chunk_size: Vector2i:
	get:
		return _chunk_size
	set(value):
		_chunk_size = value
		if Engine.is_editor_hint():
			reload_chunks()

var _tile_size: Vector2i = Vector2i()
@export
var tile_size: Vector2i:
	get:
		return _tile_size
	set(value):
		_tile_size = value
		if Engine.is_editor_hint():
			reload_chunks()

var _camera: Camera2D
@export
var camera: Camera2D:
	get:
		return _camera
	set(value):
		_camera = value
		if Engine.is_editor_hint():
			reload_chunks()

@export
var pan_speed: Vector2 = Vector2(1.0, 1.0)

func load_chunk(cord: Vector2i):
	if cord in loaded_chunks:
		return
	
	loaded_chunks[cord] = Chunk.new(cord, chunk_size)

func reload_chunks():
	if not camera:
		printerr("Cant update chunks since no camera is selected")
		return
		
	var view_rect = camera.get_viewport_rect().size
	var view_pos = camera.get_screen_transform() * camera.get_screen_center_position()
	if Engine.is_editor_hint():
		view_pos += view_rect / 2.0
	#print(view_pos, view_rect)
	var chunk_tile_size = Vector2((chunk_size * tile_size))
	var centered_view_position = view_pos - view_rect
	var centered_world_position = Vector2i(floor(centered_view_position / chunk_tile_size))
	var centered_world_size = Vector2i(ceil((centered_view_position + view_rect) / chunk_tile_size))
	
	centered_world_position -= additional_chunks
	centered_world_size += additional_chunks
	for key in loaded_chunks.keys():
		if key.x < centered_world_position.x || key.y < centered_world_position.y || key.x >= centered_world_size.x || key.y >= centered_world_size.y:
			loaded_chunks.erase(key)
	
	#print(centered_world_position, centered_world_size)
	for y in range(centered_world_position.y, centered_world_size.y):
		for x in range(centered_world_position.x, centered_world_size.x):
			load_chunk(Vector2i(x, y))
			
	queue_redraw()

var colors = [
	Color(0.98039216, 0.92156863, 0.84313726, 1),
Color(0, 1, 1, 1),
Color(0.49803922, 1, 0.83137256, 1),
Color(0.9411765, 1, 1, 1),
Color(0.9607843, 0.9607843, 0.8627451, 1),
Color(1, 0.89411765, 0.76862746, 1),
Color(0, 0, 0, 1),
Color(1, 0.92156863, 0.8039216, 1),
Color(0, 0, 1, 1),
Color(0.5411765, 0.16862746, 0.8862745, 1),
Color(0.64705884, 0.16470589, 0.16470589, 1),
Color(0.87058824, 0.72156864, 0.5294118, 1),
Color(0.37254903, 0.61960787, 0.627451, 1),
Color(0.49803922, 1, 0, 1),
Color(0.8235294, 0.4117647, 0.11764706, 1),
Color(1, 0.49803922, 0.3137255, 1),
Color(0.39215687, 0.58431375, 0.92941177, 1),
Color(1, 0.972549, 0.8627451, 1),
Color(0.8627451, 0.078431375, 0.23529412, 1),
Color(0, 1, 1, 1),
Color(0, 0, 0.54509807, 1),
Color(0, 0.54509807, 0.54509807, 1),
Color(0.72156864, 0.5254902, 0.043137256, 1),
Color(0.6627451, 0.6627451, 0.6627451, 1),
Color(0, 0.39215687, 0, 1),
Color(0.7411765, 0.7176471, 0.41960785, 1),
Color(0.54509807, 0, 0.54509807, 1),
Color(0.33333334, 0.41960785, 0.18431373, 1),
Color(1, 0.54901963, 0, 1),
Color(0.6, 0.19607843, 0.8, 1),
Color(0.54509807, 0, 0, 1),
Color(0.9137255, 0.5882353, 0.47843137, 1),
Color(0.56078434, 0.7372549, 0.56078434, 1),
Color(0.28235295, 0.23921569, 0.54509807, 1),
Color(0.18431373, 0.30980393, 0.30980393, 1),
Color(0, 0.80784315, 0.81960785, 1),
Color(0.5803922, 0, 0.827451, 1),
Color(1, 0.078431375, 0.5764706, 1),
Color(0, 0.7490196, 1, 1),
Color(0.4117647, 0.4117647, 0.4117647, 1),
Color(0.11764706, 0.5647059, 1, 1),
Color(0.69803923, 0.13333334, 0.13333334, 1),
Color(1, 0.98039216, 0.9411765, 1),
Color(0.13333334, 0.54509807, 0.13333334, 1),
Color(1, 0, 1, 1),
Color(0.8627451, 0.8627451, 0.8627451, 1),
Color(0.972549, 0.972549, 1, 1),
Color(1, 0.84313726, 0, 1),
Color(0.85490197, 0.64705884, 0.1254902, 1),
Color(0.74509805, 0.74509805, 0.74509805, 1),
Color(0, 1, 0, 1),
Color(0.6784314, 1, 0.18431373, 1),
Color(0.9411765, 1, 0.9411765, 1),
Color(1, 0.4117647, 0.7058824, 1),
Color(0.8039216, 0.36078432, 0.36078432, 1),
Color(0.29411766, 0, 0.50980395, 1),
Color(1, 1, 0.9411765, 1),
Color(0.9411765, 0.9019608, 0.54901963, 1),
Color(0.9019608, 0.9019608, 0.98039216, 1),
Color(1, 0.9411765, 0.9607843, 1),
Color(0.4862745, 0.9882353, 0, 1),
Color(1, 0.98039216, 0.8039216, 1),
Color(0.6784314, 0.84705883, 0.9019608, 1),
Color(0.9411765, 0.5019608, 0.5019608, 1),
Color(0.8784314, 1, 1, 1),
Color(0.98039216, 0.98039216, 0.8235294, 1),
Color(0.827451, 0.827451, 0.827451, 1),
Color(0.5647059, 0.93333334, 0.5647059, 1),
Color(1, 0.7137255, 0.75686276, 1),
Color(1, 0.627451, 0.47843137, 1),
Color(0.1254902, 0.69803923, 0.6666667, 1),
Color(0.5294118, 0.80784315, 0.98039216, 1),
Color(0.46666667, 0.53333336, 0.6, 1),
Color(0.6901961, 0.76862746, 0.87058824, 1),
Color(1, 1, 0.8784314, 1),
Color(0, 1, 0, 1),
Color(0.19607843, 0.8039216, 0.19607843, 1),
Color(0.98039216, 0.9411765, 0.9019608, 1),
Color(1, 0, 1, 1),
Color(0.6901961, 0.1882353, 0.3764706, 1),
Color(0.4, 0.8039216, 0.6666667, 1),
Color(0, 0, 0.8039216, 1),
Color(0.7294118, 0.33333334, 0.827451, 1),
Color(0.5764706, 0.4392157, 0.85882354, 1),
Color(0.23529412, 0.7019608, 0.44313726, 1),
Color(0.48235294, 0.40784314, 0.93333334, 1),
Color(0, 0.98039216, 0.6039216, 1),
Color(0.28235295, 0.81960785, 0.8, 1),
Color(0.78039217, 0.08235294, 0.52156866, 1),
Color(0.09803922, 0.09803922, 0.4392157, 1),
Color(0.9607843, 1, 0.98039216, 1),
Color(1, 0.89411765, 0.88235295, 1)
]

func _ready() -> void:
	loaded_chunks.clear()
	reload_chunks()

func _draw() -> void:
	#print("bb", loaded_chunks.size())
	var view_rect = camera.get_viewport_rect().size
	var view_pos = camera.get_screen_transform() * camera.get_screen_center_position()
	if Engine.is_editor_hint():
		view_pos += view_rect / 2.0
	var view_offset = view_pos - view_rect / 2.0
	
	for cord in loaded_chunks.keys():
		for y in range(0, chunk_size.y):
			for x in range(0, chunk_size.x):
				var color = colors[(cord.y * 8 + cord.x) % colors.size()].darkened( (x * 256165798413 ^ y * 84646123 ^ cord.x * 909529032 ^ cord.y * 77632234) % 100 / 100. )
				draw_rect(Rect2(cord.x*tile_size.x*chunk_size.x + x * tile_size.x - view_offset.x, cord.y*tile_size.y*chunk_size.y + y * tile_size.y - view_offset.y, tile_size.x, tile_size.y), color, true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if Input.is_action_pressed("right"):
		camera.position += Vector2(tile_size.x * delta * pan_speed.x, 0.0)
		reload_chunks()
	if Input.is_action_pressed("left"):
		camera.position += Vector2(-tile_size.x * delta * pan_speed.x, 0.0)
		reload_chunks()
	if Input.is_action_pressed("up"):
		camera.position += Vector2(0.0, -tile_size.y * delta * pan_speed.y)
		reload_chunks()
	if Input.is_action_pressed("down"):
		camera.position += Vector2(0.0, tile_size.y * delta * pan_speed.y)
		reload_chunks()
