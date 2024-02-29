extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var loader: JSONLoader = JSONLoader.new()
	var data: Dictionary = loader.load_json_file("res://addons/lpccharactergenerator/data/definition-to-line-mapping.json")
	#print(JSON.stringify(data))

	var button = Button.new()
	button.text = "Hello"
	
	$GeneratorDockContainer.add_child(button)
	#var panel = PanelContainer.new()
	#panel.add_child(button)
	#panel.size = Vector2(200, 200)
	#add_child(panel)
	#var tree = Tree.new()
	#var root = tree.create_item()
	#tree.hide_root = true
	#var child1 = tree.create_item(root)
	#var child2 = tree.create_item(root)
	#var subchild1 = tree.create_item(child1)
	#subchild1.set_text(0, "Subchild1")
	#add_child(tree)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
