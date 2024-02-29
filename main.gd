extends Node2D

var universalSheetWidth = 832
var universalSheetHeight = 1344

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Test Blending/Bliting Images
	var image_files = [
		"user://spritesheets/body/bodies/male/universal/light.png",
		"user://spritesheets/feet/armour/plate/male/iron.png",
		"user://spritesheets/legs/armour/plate/male/iron.png",
		"user://spritesheets/arms/armour/plate/male/iron.png",
		"user://spritesheets/torso/armour/plate/male/iron.png",
		"user://spritesheets/head/heads/human_male/universal/light.png",
		"user://spritesheets/hat/helmet/barbuta/male/iron.png"
	]
	
	var base_image = Image.new()
	var base_image_file = image_files.pop_front()
	base_image.load(base_image_file)

	for image_file in image_files:
		var layered_image = Image.new()
		layered_image.load(image_file)
		base_image.blend_rect(layered_image, Rect2(0,0,universalSheetWidth,universalSheetHeight), Vector2(0, 0))

	base_image.save_png("res://composites/tests/all_layers_blend.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
