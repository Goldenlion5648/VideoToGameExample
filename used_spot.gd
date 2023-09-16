extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	await get_tree().create_timer(4).timeout
	get_removed()

func get_removed():
	get_parent().remove_child(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
