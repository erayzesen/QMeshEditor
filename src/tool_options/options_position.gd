extends GridContainer

onready var app=get_tree().root.get_node("app")
onready var actions=app.get_node("actions")
onready var ur_manager:undoredo_manager=app.get_node("undoredo_manager")
var target_mesh:mesh_node

onready var value_pos_x:LineEdit=get_node("value_pos_x")
onready var value_pos_y:LineEdit=get_node("value_pos_y")


func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	value_pos_x.connect("value_changed",self,"on_value_pos_x_changed")
	value_pos_y.connect("value_changed",self,"on_value_pos_y_changed")

	
func on_value_pos_x_changed() :
	if target_mesh==null :
		return
	if(target_mesh.global_position.x==value_pos_x.text.to_float()) :
		return
	var old_position=target_mesh.global_position
	var new_position=Vector2(value_pos_x.text.to_float(),target_mesh.global_position.y)
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,old_position])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,new_position])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_mesh_position(target_mesh,new_position)
	
func on_value_pos_y_changed() :
	if target_mesh==null :
		return
	if(target_mesh.global_position.y==value_pos_y.text.to_float()) :
		return
	var old_position=target_mesh.global_position
	var new_position=Vector2(target_mesh.global_position.x,value_pos_y.text.to_float())
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,old_position])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,new_position])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_mesh_position(target_mesh,new_position)





func update_values() :
	if target_mesh==null :
		return
	value_pos_x.text=str(target_mesh.global_position.x)
	value_pos_y.text=str(target_mesh.global_position.y)
	

func on_visibility_changed():
	if visible==false :
		return
	update_values()
	
		


