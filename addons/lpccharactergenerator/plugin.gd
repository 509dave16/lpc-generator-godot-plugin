@tool
extends EditorPlugin

var loader: JSONLoader = JSONLoader.new()
var dock: PanelContainer
var global_tree: Tree
var body_types := ["male", "female", "teen", "child", "muscular", "pregnant"]
var selected_body_type := "male"
var selected_body_parts := []
var excluded_body_parts: Dictionary = {}
var included_body_parts: Dictionary = {}
var none = "None"

func _enter_tree():
	for body in body_types:
		excluded_body_parts[body] = []
		included_body_parts[body] = []
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
	# This is parent of leaf items
	if tree_data.has("file"):
		# Get definition for body part and set metadata on parent
		var file = tree_data["file"]
		var definition: Dictionary = loader.load_json_file("user://sheet_definitions/" + file)
		definition["selected_item_index"] = 0
		parent.set_metadata(0, definition)
		register_with_excluded(definition, parent)
		register_with_included(definition, parent)
		var should_hide = hide_if_excluded(definition, parent)
		if !should_hide:
			# Now attach leaft items to parent
			attach_leaf_tree_items(tree, parent, definition)
		return
		
	for item_text in tree_data:
		var next_tree_data: Dictionary = tree_data[item_text]
		var item = tree.create_item(parent)
		item.collapsed = true
		item.set_text(0, item_text)
		attach_next_tree_item(tree, item, next_tree_data)
	return
	
func attach_leaf_tree_items(tree: Tree, parent: TreeItem, definition: Dictionary):
	var variants = get_variants(definition)
	# This is for "None" variant(i.e. no selection)
	create_first_variant(tree, parent)
	# This is for all variants after "None"
	for variant in variants:
		var item = tree.create_item(parent)
		# Bail early if only text
		if definition.has('use_layer_keys_for_value'):
			print('set text for body type variant')
			item.set_text(0, variant)
			continue
		
		# Create texture of first animation for part variant
		variant = normalize_variant(variant)
		var sheet_path = "user://spritesheets/" + definition["layer_1"][selected_body_type] + variant + ".png"
		var sheet = Image.load_from_file(sheet_path)
		var sheet_format = sheet.get_format()
		var image = Image.create(64,64,false, sheet_format)
		image.fill(Color.WHITE)
		image.blit_rect(sheet, image.get_used_rect() ,Vector2.ZERO)
		var texture = ImageTexture.create_from_image(image)
		
		# Create leaf tree item with texture
		item.set_metadata(0, { "leaf": true, "variant": variant })
		item.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
		item.set_custom_draw(0, self, "_draw_leaf_tree_item")
		item.set_icon(0, texture)
	return
	
func _draw_leaf_tree_item(item: TreeItem, rect: Rect2):
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
	
func normalize_variant(variant: String):
	return variant.replace(" ", "_")
	
func create_first_variant(tree: Tree, parent: TreeItem):
	var first_item = tree.create_item(parent)
	first_item.set_metadata(0, { "leaf": true, "variant": none })
	first_item.set_cell_mode(0,TreeItem.CELL_MODE_CUSTOM)
	first_item.set_custom_draw(0, self, "_draw_leaf_tree_item")
	first_item.set_text(0, none)

func get_variants(definition: Dictionary):
	# Setup body type variants if this is "body type" parent essentially
	var variants: Array = definition["variants"]
	if definition.has('use_layer_keys_for_value'):
		print('create variants for body type')
		variants = []
		for body_type in definition["layer_1"]:
			if body_types.has(body_type):
				variants.push_back(body_type)
	return variants
	
func register_with_included(definition: Dictionary, item: TreeItem):
	for body_type in definition["layer_1"]:
		if body_types.has(body_type):
			included_body_parts[body_type].push_back(item)

func register_with_excluded(definition: Dictionary, item: TreeItem):
	for body_type in body_types:
		if !definition["layer_1"].has(body_type):
			excluded_body_parts[body_type].push_back(item)
			
func hide_if_excluded(definition: Dictionary, item: TreeItem):
	var should_hide = false
	if !definition["layer_1"].has(selected_body_type):
		should_hide = true
		item.visible = false
	return should_hide
