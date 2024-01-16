extends GridContainer

onready var app=get_tree().root.get_node("app")
onready var actions=app.get_node("actions")
onready var ur_manager:undoredo_manager=app.get_node("undoredo_manager")
var target_mesh:mesh_node
var selected_particles=[]

onready var value_pos_x:LineEdit=get_node("value_pos_x")
onready var value_pos_y:LineEdit=get_node("value_pos_y")
onready var value_radius:SpinBox=get_node("value_radius")
onready var value_internal:CheckBox=get_node("value_enable_internal")

func _ready():
	connect("visibility_changed",self,"on_visibility_changed")
	value_pos_x.connect("value_changed",self,"on_value_pos_x_changed")
	value_pos_y.connect("value_changed",self,"on_value_pos_y_changed")
	value_radius.connect("value_changed",self,"on_value_radius_changed")
	value_internal.connect("pressed",self,"on_value_internal_changed")
	
func on_value_pos_x_changed() :
	var particle_old_positions=[]
	var particle_new_positions=[]
	var is_value_same=true
	for pi in selected_particles :
		var particle=target_mesh.particles[pi]
		particle_old_positions.append(particle.position)
		var new_position=Vector2(value_pos_x.text.to_float(),particle.position.y)
		particle_new_positions.append(new_position)
		if particle.position!=new_position :
			is_value_same=false
	if is_value_same :
		return
	var copied_selected_particles=selected_particles.duplicate()
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,particle_old_positions])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,particle_new_positions])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_particle_positions(target_mesh,selected_particles,particle_new_positions )
		
	
func on_value_pos_y_changed() :
	var particle_old_positions=[]
	var particle_new_positions=[]
	var is_value_same=true
	for pi in selected_particles :
		var particle=target_mesh.particles[pi]
		particle_old_positions.append(particle.position)
		var new_position=Vector2(particle.position.x,value_pos_y.text.to_float())
		particle_new_positions.append(new_position)
		if particle.position!=new_position :
			is_value_same=false
	if is_value_same :
		return
	var copied_selected_particles=selected_particles.duplicate()
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,particle_old_positions])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,particle_new_positions])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_particle_positions(target_mesh,selected_particles,particle_new_positions )

func on_value_radius_changed(value:float) :
	var old_radius_values=[]
	var new_radius_values=[]
	var is_value_same=true
	for pi in selected_particles :
		var particle=target_mesh.particles[pi]
		old_radius_values.append(particle.radius)
		new_radius_values.append(value)
		if particle.radius!=value :
			is_value_same=false
	if is_value_same :
		return
	var copy_particle_list=selected_particles.duplicate()
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_radius_values",[target_mesh,copy_particle_list,old_radius_values])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_radius_values",[target_mesh,copy_particle_list,new_radius_values])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_particle_radius_values(target_mesh,selected_particles,new_radius_values )
	

func on_value_internal_changed() :
	var old_internal_values=[]
	var new_internal_values=[]
	var is_value_same=true
	for pi in selected_particles :
		var particle=target_mesh.particles[pi]
		old_internal_values.append(particle.enable_internal)
		new_internal_values.append(value_internal.pressed)
		if particle.enable_internal!=value_internal.pressed :
			is_value_same=false
	if is_value_same :
		return
	var copy_particle_list=selected_particles.duplicate()
	var undo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_internal_values",[target_mesh,copy_particle_list,old_internal_values])
	var redo_action=ur_manager.create_action(actions,undoredo_manager.action_types.CALL,"set_particle_internal_values",[target_mesh,copy_particle_list,new_internal_values])
	ur_manager.add_undoredo(undo_action,redo_action)
	actions.set_particle_internal_values(target_mesh,selected_particles,new_internal_values )
	

func update_values() :
	if target_mesh==null :
		return
	if selected_particles.size()==0 :
		return
	var pos_x_values_similar=true
	var pos_y_values_similar=true
	var radius_values_similar=true
	var internal_values_similar=true
	
	if selected_particles[0]>=target_mesh.particles.size() :
		app.clear_tool_options_panel()
		app.refresh_tool_helper_properties()
		return
	
	var checked_position=target_mesh.particles[selected_particles[0] ].position
	var checked_radius=target_mesh.particles[selected_particles[0] ].radius
	var checked_internal=target_mesh.particles[selected_particles[0] ].enable_internal
	for pi in selected_particles :
		if(pi>=target_mesh.particles.size()) :
			continue
		var particle=target_mesh.particles[pi]
		if checked_position.x!=particle.position.x :
			pos_x_values_similar=false
		if checked_position.y!=particle.position.y :
			pos_y_values_similar=false
		if checked_radius!=particle.radius :
			radius_values_similar=false
		if checked_internal!=particle.enable_internal :
			internal_values_similar=false
	if pos_x_values_similar :
		value_pos_x.text=str(checked_position.x)
	else:
		value_pos_x.text="--"
	if pos_y_values_similar :
		value_pos_y.text=str(checked_position.y)
	else :
		value_pos_y.text="--"
	if radius_values_similar :
		value_radius.set_value(checked_radius)
	else:
		value_radius.set_value(0.5)
	if internal_values_similar :
		value_internal.pressed=checked_internal
	else:
		value_internal.pressed=false

func on_visibility_changed():
	if visible==false :
		return
	update_values()
	
		


