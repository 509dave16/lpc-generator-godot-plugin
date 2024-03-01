extends Node2D

var universalSheetWidth = 832
var universalSheetHeight = 1344

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var loader: JSONLoader = JSONLoader.new()
	var data: Dictionary = loader.load_json_file("res://addons/lpccharactergenerator/data/definition-to-line-mapping.json")
	print(JSON.stringify(data))
	
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
	
	var tree = Tree.new()
	var root = tree.create_item()
	root.set_text(0, "Root")
	tree.hide_root = true
	var child1 = tree.create_item(root)
	child1.set_text(0, "Child1")
	var child2 = tree.create_item(root)
	child2.set_text(0, "Child2")
	var subchild1 = tree.create_item(child1)
	subchild1.set_text(0, "Subchild1")
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(tree)
	var layer = CanvasLayer.new()
	layer.add_child(panel)
	add_child(layer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
