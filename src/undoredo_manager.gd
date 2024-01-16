extends Node
class_name undoredo_manager

enum action_types{
	SET,
	CALL
}

var undo_list=[]
var redo_list=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
static func create_action(target_node:Node,action_type:int,property_or_function:String,parameters:Array)->action:
	var n_action=action.new()
	n_action.target_node=target_node
	n_action.action_type=action_type
	n_action.property_or_function=property_or_function
	n_action.parameters=parameters
	return n_action

func add_undoredo(undo:action,redo:action)->undoredo_action :
	var ur_action=undoredo_action.new()
	ur_action.undo_action=undo
	ur_action.redo_action=redo
	undo_list.append(ur_action)
	redo_list.clear()
	return ur_action

func undo() :
	if undo_list.size()==0 :
		return
	print("called undo")
	var ur_action:undoredo_action=undo_list[undo_list.size()-1]
	if ur_action.undo_action.action_type==action_types.SET :
		ur_action.undo_action.target_node.set(ur_action.undo_action.property_or_function,ur_action.undo_action.parameters[0])
	elif ur_action.undo_action.action_type==action_types.CALL :
		ur_action.undo_action.target_node.callv(ur_action.undo_action.property_or_function,ur_action.undo_action.parameters)
	redo_list.append(ur_action)
	undo_list.remove(undo_list.size()-1)
		
func redo() :
	if redo_list.size()==0 :
		return
	print("called redo")
	var ur_action:undoredo_action=redo_list[redo_list.size()-1]
	if ur_action.redo_action.action_type==action_types.SET :
		ur_action.redo_action.target_node.set(ur_action.redo_action.property_or_function,ur_action.redo_action.parameters[0])
	elif ur_action.redo_action.action_type==action_types.CALL :
		ur_action.redo_action.target_node.callv(ur_action.redo_action.property_or_function,ur_action.redo_action.parameters)
	undo_list.append(ur_action)
	redo_list.remove(redo_list.size()-1)
	

		
func has_undo()->bool:
	if undo_list.size()==0 :
		return false
	return true
func has_redo()->bool:
	if redo_list.size()==0 :
		return false
	return true
	
func clear():
	undo_list.clear()
	redo_list.clear()

class undoredo_action :
	var undo_action:action
	var redo_action:action
		
	
	
class action:
	var target_node:Node
	var action_type=action_types.SET
	var property_or_function:String=""
	var parameters:Array=[]
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
