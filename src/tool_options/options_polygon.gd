extends GridContainer

onready var app=get_tree().root.get_node("app")
onready var actions=app.get_node("actions")
onready var ur_manager:undoredo_manager=app.get_node("undoredo_manager")
var target_mesh:mesh_node

onready var btn_remove_polygon:Button=get_node("Button")



func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	btn_remove_polygon.connect("pressed",self,"on_btn_remove_polygon_pressed")
	
func on_btn_remove_polygon_pressed() :
	pass

	






func update_values() :
	if target_mesh==null :
		return

	

func on_visibility_changed():
	if visible==false :
		return
	update_values()
	
		


