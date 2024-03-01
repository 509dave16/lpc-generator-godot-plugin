@tool
extends EditorPlugin

var loader: JSONLoader = JSONLoader.new()
var dock
var tree: Tree
	
func _enter_tree():
	var packed_scene: PackedScene = load("res://addons/lpccharactergenerator/generator_dock.tscn")
	dock = packed_scene.instantiate()
	ui(dock)
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
	
func ui(interface: Control):
	var data: Dictionary = loader.load_json_file("res://addons/lpccharactergenerator/data/definition-to-line-mapping.json")
	print(JSON.stringify(data))
	
	tree = Tree.new()
	var root = tree.create_item()
	tree.hide_root = true
	attach_next_tree_item(tree, root, data)
	interface.add_child(tree)
	

func attach_next_tree_item(tree: Tree, parent: TreeItem, tree_data: Dictionary):
	if tree_data.has("file"):
		var file = tree_data["file"]
		# TODO - Add children for variants read from file
		# Read file
		var definition: Dictionary = loader.load_json_file("user://sheet_definitions/" + file)
		for index in range(definition["variants"].size()):
			var name = definition["variants"][index]
			var sheet_path = "user://spritesheets/" + definition["layer_1"]["male"] + name + ".png"
			var sheet = Image.load_from_file(sheet_path)
			var image = Image.new()
			image = image.create(64,64,false,Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)
			image.blit_rect(sheet, image.get_used_rect() ,Vector2.ZERO)
			var texture = ImageTexture.create_from_image(image)
			var item = tree.create_item(parent)
			item.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
			item.set_icon(0, texture)

			#var checkbox = CheckBox.new()
			#item.set_metadata(0, {
				#"texture": texture,
				#"checkbox": checkbox
			#})
			#item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
			#item.set_custom_draw(0, self, '_draw_leaf_item')
		return
		
	for item_text in tree_data:
		var next_tree_data: Dictionary = tree_data[item_text]
		var item = tree.create_item(parent)
		item.collapsed = true
		item.set_text(0, item_text)
		attach_next_tree_item(tree, item, next_tree_data)
	return
	
#func _draw_leaf_item(item: TreeItem, rect: Rect2):
	#var metadata = item.get_metadata(0)
	#var texture: ImageTexture = metadata["texture"]
	#texture.draw(tree.get_id(),rect.position)
	
