extends GridContainer


var target_mesh:mesh_node
onready var value_radius:SpinBox=get_node("value_radius")
onready var value_internal:CheckBox=get_node("value_enable_internal")

func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	pass # Replace with function body.

func on_visibility_changed():
	if visible==false :
		return
	print("test polygon tool options")

