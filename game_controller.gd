extends Node2D
@export var used_spot : PackedScene

var score = 0
var current_stream: VideoStreamPlayer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_current_stream()
	set_goal_color()

func update_score_text():
	Globals.high_score = max(Globals.high_score, score)
	$CanvasLayer/score_label.text = "Score: %d" % score
	$CanvasLayer/high_score.text = "High Score: %d" % Globals.high_score
	
func find_current_stream():
	current_stream = null
	for node in get_children():
		if node is VideoStreamPlayer and node.is_visible():
			current_stream = node
			print("found ", node.name)
			break


func reset_when_done():
	if not current_stream.is_playing():
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	clicking_position()
	if Input.is_action_just_pressed("choose_new_color"):
		set_goal_color()
	reset_when_done()
	update_score_text()
	

func clicking_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var image = get_viewport().get_texture().get_image()
	if not (
			0 <= mouse_pos.x and mouse_pos.x < image.get_width() and\
			0 <= mouse_pos.y and mouse_pos.y < image.get_height()
			):
		return
		
	var color_under_mouse = image.get_pixel(mouse_pos.x, mouse_pos.y)
	$current_mouse_color.color = color_under_mouse
	
	if Input.is_action_just_pressed("use_spot"):
		var new_used_spot = used_spot.instantiate() as TextureRect
		self.add_child(new_used_spot)
		var width = new_used_spot.texture.get_width()
		var new_pos = Vector2(mouse_pos.x - width / 2, mouse_pos.y - width / 2)
		new_used_spot.position = to_local(new_pos)
		var color_diff = color_difference($current_mouse_color.color, $goal_color.color)
		prints("colors", $current_mouse_color.color, $goal_color.color)
		prints("diff", color_diff)
		if color_diff < 40:
			score += 1
			prints("score", score)
			set_goal_color()

func color_difference(color1: Color, color2: Color) -> int:
	return abs(color1.r8 - color2.r8) + abs(color1.g8 - color2.g8) +\
			abs(color1.b8 - color2.b8)

func set_goal_color():
	var stream_dim = current_stream.get_video_texture().get_size()
	var colors_seen = {}
	for i in range(100):
		var x = randi_range(0, stream_dim.x - 1)
		var y = randi_range(0, stream_dim.y - 1)
		var current_color = current_stream.get_video_texture().get_image().get_pixel(x, y)
		if current_color not in colors_seen:
			colors_seen[current_color] = 0
		colors_seen[current_color] += 1
	var original_keys = colors_seen.keys().duplicate()
	for color in colors_seen.keys():
		if colors_seen[color] < 3:
			colors_seen.erase(color)
	var chosen = colors_seen.keys().pick_random()
	if chosen == null or chosen == $goal_color.color:
		chosen = original_keys.pick_random()
	$goal_color.color = chosen
