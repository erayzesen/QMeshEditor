extends GridContainer

onready var app=get_tree().root.get_node("app")
onready var actions=app.get_node("actions")
onready var ur_manager:undoredo_manager=app.get_node("undoredo_manager")
var target_mesh:mesh_node

onready var value_rotation:FloatBox=get_node("value_rotation")



func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	value_rotation.connect("value_changed",self,"on_value_rotation_changed")

	
func on_value_rotation_changed(value:float=0) :
	if target_mesh==null :
		return
	if target_mesh==null :
		return
	if(target_mesh.global_rotation_degrees==value_rotation.text.to_float()) :
		return
	var old_rotation=target_mesh.global_rotation_degrees
	var new_rotation=value_rotation.text.to_float()
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_rotation",[target_mesh,old_rotation])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_rotation",[target_mesh,target_mesh.global_rotation_degrees])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_mesh_rotation(target_mesh,new_rotation)
	
	

func update_values() :
	if target_mesh==null :
		return
	value_rotation.text=str(target_mesh.global_rotation_degrees)
	

func on_visibility_changed():
	if visible==false :
		return
	update_values()
	
		


