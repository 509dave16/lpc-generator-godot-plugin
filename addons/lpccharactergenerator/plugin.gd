@tool
extends EditorPlugin

var loader: JSONLoader = JSONLoader.new()
var dock: PanelContainer
var global_tree: Tree
	
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
	global_tree = Tree.new()
	global_tree.connect("item_selected", Callable(self, "_on_tree_item_selected"))
	var root = global_tree.create_item()
	global_tree.hide_root = true
	attach_next_tree_item(global_tree, root, data)
	interface.add_child(global_tree)
	

func attach_next_tree_item(tree: Tree, parent: TreeItem, tree_data: Dictionary):
	if tree_data.has("file"):
		attach_leaf_tree_items(tree, parent, tree_data)
		return
		
	for item_text in tree_data:
		var next_tree_data: Dictionary = tree_data[item_text]
		var item = tree.create_item(parent)
		item.collapsed = true
		item.set_text(0, item_text)
		attach_next_tree_item(tree, item, next_tree_data)
		return
	return
	
func attach_leaf_tree_items(tree: Tree, parent: TreeItem, tree_data: Dictionary):
	var file = tree_data["file"]
	var definition: Dictionary = loader.load_json_file("user://sheet_definitions/" + file)
	parent.set_metadata(0, { "selected_item_index": 0 })
	
	var first_item = tree.create_item(parent)
	first_item.set_metadata(0, { "leaf": true })
	first_item.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
	first_item.set_custom_draw(0, self, "_draw_leaf_tree_item")
	first_item.set_text(0, "None")
	for index in range(definition["variants"].size()):
		var title = definition["variants"][index]
		var sheet_path = "user://spritesheets/" + definition["layer_1"]["male"] + title + ".png"
		
		# Create texture of first animation for part variant
		var sheet = Image.load_from_file(sheet_path)
		var image = Image.create(64,64,false,Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		image.blit_rect(sheet, image.get_used_rect() ,Vector2.ZERO)
		var texture = ImageTexture.create_from_image(image)
		
		# Create leaf tree item with texture
		var item = tree.create_item(parent)
		item.set_metadata(0, { "sheet_path": sheet_path, "leaf": true })
		item.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
		item.set_custom_draw(0, self, "_draw_leaf_tree_item")
		item.set_icon(0, texture)
	return
	
func _draw_leaf_tree_item(item: TreeItem, rect: Rect2):
	#print(rect)
	# Only draw if selected leaf tree item
	var selected_item_index = get_selected_item_index(item)
	if selected_item_index != item.get_index():
		return
	
	var x_size = rect.size.x
	var y_size = rect.size.y
	var x_position = rect.position.x
	var y_position = rect.position.y
	var half_y_size = y_size / 2
	var half_y_position = y_position + half_y_size
	var half_size := Vector2(x_size, half_y_size)
	var top_position := Vector2(x_position, y_position)
	var bottom_position := Vector2(x_position, half_y_position)
	var top_rect := Rect2(top_position, half_size)
	var bottom_rect := Rect2(bottom_position, half_size)
	var current_color: Color = Color.RED
	var white := Color(1, 1, 1)
	global_tree.draw_rect(top_rect, white)
	global_tree.draw_rect(bottom_rect, current_color)
		

func _on_tree_item_selected():
	var selected_item := global_tree.get_selected()
	if selected_item != null:
		set_selected_item_index(selected_item)
		

func get_selected_item_index(item: TreeItem):
	var parent := item.get_parent()
	var metadata = parent.get_metadata(0)
	if typeof(metadata) == TYPE_NIL:
		return -1 # not leaf node so parent has no metadata
	return metadata["selected_item_index"]
	
func set_selected_item_index(selected_item: TreeItem):
	var item_metadata = selected_item.get_metadata(0)
	var is_not_leaf = typeof(item_metadata) == TYPE_NIL || !item_metadata.has('leaf')
	if is_not_leaf:
		return
	var parent := selected_item.get_parent()
	var metadata = parent.get_metadata(0)
	if typeof(metadata) == TYPE_NIL:
		metadata = {}
	metadata["selected_item_index"] = selected_item.get_index()
	parent.set_metadata(0, metadata)
