extends GridContainer



var target_mesh:mesh_node
onready var value_internal:CheckBox=get_node("value_enable_internal")

func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	
func on_visibility_changed():
	if visible==false :
		return
	print("test spring tool options")


