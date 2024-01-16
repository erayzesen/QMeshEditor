extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum tool_modes{
	SELECT,
	PARTICLE,
	SPRING,
	POLYGON,
	POSITION,
	ROTATION
}

#GENERAL PROPERTIES
var snap_to_grid=false

#File Operations
var window_base_title="QMesh Editor"
var file_location="" setget on_file_location_changed
func on_file_location_changed(value) :
	file_location=value
	update_window_title()
var reference_image_location="" setget on_reference_image_location_changed
func on_reference_image_location_changed(value):
	reference_image_location=value
	reference_image_sprite.texture=null
	if value=="":
		return
	var img=Image.new()
	var err=img.load(value)
	if err!=OK :
		return
	var texture=ImageTexture.new()
	texture.create_from_image(img)
	get_node("%reference_image").texture=texture
	pass
var is_file_changed=true setget on_file_changed_value_changed
func on_file_changed_value_changed(value) :
	if is_file_changed==value :
		return
	is_file_changed=value
	update_window_title()
		

var show_polygons=true setget set_show_polygons
func set_show_polygons(value) :
	show_polygons=value
	update_all_meshes()
var show_springs=true  setget set_show_springs
func set_show_springs(value) :
	show_springs=value
	update_all_meshes()
var show_particles=true setget set_show_particles
func set_show_particles(value) :
	show_particles=value
	update_all_meshes()

#tools
var tool_mode=tool_modes.SELECT

#undo-redo operations
onready var ur_manager:undoredo_manager=get_node("/root/app/undoredo_manager")

#drawing editor guide shapes
onready var guides:guides=get_node("canvas/guides")

#tool option nodes
onready var options_selected_particles=get_node("%options_selected_particles")
onready var options_particle=get_node("%options_particle")
onready var options_spring=get_node("%options_spring")
onready var options_none=get_node("%options_none")
onready var options_position=get_node("%options_position")
onready var options_rotation=get_node("%options_rotation")

#reference image
onready var reference_image_sprite=get_node("%reference_image")

#zoom 
onready var btn_zoom_in=get_node("CanvasLayer/ZoomContainer/btn_zoom_in")
onready var btn_zoom_out=get_node("CanvasLayer/ZoomContainer/btn_zoom_out")
onready var btn_zoom_reset=get_node("CanvasLayer/ZoomContainer/btn_reset_zoom")
signal zoom_changed


#meshes
onready var mesh_tree_bar:Tree=get_node("%mesh_tree_bar")
onready var mesh_tree_root=mesh_tree_bar.create_item();
var mesh_id_counter:int=0
var last_selected_mesh_item:TreeItem

#hand navigation helpers
var last_mouse_position:Vector2=Vector2.INF
var middle_mouse_pan=false

#select mode helpers
var selected_particles=[]
var particle_old_positions=[]
var select_transform_mode=false
#particle mode helpers


#spring mode helpers
var spring_start_particle_index=-1

#polygon mode helpers
var polygon_container=[]
var polygon_redrawing_process=false

#position mode helpers
var mesh_old_position=Vector2.ZERO
#rotation mode helpers
var mesh_old_rotation=Vector2.ZERO

export(ButtonGroup) var tool_button_group

# Called when the node enters the scene tree for the first time.
func _ready():
	#tools
	tool_button_group.connect("pressed",self,"on_tool_changed")
	
	#zoom bar 
	btn_zoom_in.connect("pressed",self,"on_zoom_in_pressed")
	btn_zoom_out.connect("pressed",self,"on_zoom_out_pressed")
	btn_zoom_reset.connect("pressed",self,"on_zoom_reset_pressed")
	
	#mesh tree buttons
	#mesh_tree_bar.connect("cell_selected",self,"on_mesh_selected")
	mesh_tree_bar.connect("item_selected",self,"on_mesh_item_selected")
	mesh_tree_bar.connect("item_activated",self,"on_mesh_item_activated")
	#mesh_tree_bar.connect("item_activated",self,"on_mesh_selected")
	mesh_tree_root.set_text(0,"\uf20e  QBody")
	mesh_tree_root.set_selectable(0,false)
	mesh_tree_root.disable_folding=true
	get_node("%btn_add_mesh").connect("pressed",self,"on_btn_add_mesh_clicked")
	get_node("%btn_remove_mesh").connect("pressed",self,"on_btn_remove_mesh_clicked")
	
	get_tree().root.connect("size_changed",self,"on_window_size_changed")
	
	
	$actions.add_mesh()
	
	OS.set_window_title("QMesh Editor - New File")
	pass # Replace with function body.
	
func on_zoom_in_pressed() :
	if get_node("Camera2D").zoom.x>0.1 and get_node("Camera2D").zoom.y>0.1:
		get_node("Camera2D").zoom-=Vector2(0.1,0.1)
	btn_zoom_reset.text=str( round( (get_node("Camera2D").zoom.x) *100 ) ) +"%"
	emit_signal("zoom_changed")
	pass
	
func on_zoom_out_pressed() :
	get_node("Camera2D").zoom+=Vector2(0.1,0.1)
	btn_zoom_reset.text=str(round( (get_node("Camera2D").zoom.x) *100) )  +"%"
	emit_signal("zoom_changed")
	pass
	
func on_zoom_reset_pressed() :
	get_node("Camera2D").zoom=Vector2(1,1)
	btn_zoom_reset.text=str(round( get_node("Camera2D").zoom.x*100) )  +"%"
	emit_signal("zoom_changed")
	pass
	
func on_window_size_changed() :
	guides.update()



func on_tool_changed(object:Button):
	#refreshs all tool properties
	clear_tool_options_panel()
	refresh_tool_helper_properties()
	
	if object.name=="tool_select" :
		tool_mode=tool_modes.SELECT
		options_none.visible=true
	elif object.name=="tool_particle" :
		tool_mode=tool_modes.PARTICLE 
		options_particle.visible=true
	elif object.name=="tool_spring" :
		tool_mode=tool_modes.SPRING
		options_spring.visible=true
	elif object.name=="tool_polygon" :
		tool_mode=tool_modes.POLYGON
		options_none.visible=true
	elif object.name=="tool_position":
		tool_mode=tool_modes.POSITION
		options_position.target_mesh=last_selected_mesh_item.get_metadata(0)
		options_position.visible=true
	elif object.name=="tool_rotation":
		tool_mode=tool_modes.ROTATION
		options_rotation.target_mesh=last_selected_mesh_item.get_metadata(0)
		options_rotation.visible=true		
	print( tool_mode ) 
	pass
	
func refresh_tool_helper_properties() :
	guides.clear()
	guides.update()
	selected_particles.clear()
	last_mouse_position=Vector2.INF
	spring_start_particle_index=-1
	polygon_container.clear()
	particle_old_positions.clear()
	mesh_old_position=Vector2.ZERO
	mesh_old_rotation=0

func clear_tool_options_panel() :
	options_none.visible=false
	options_particle.visible=false
	options_selected_particles.visible=false
	options_spring.visible=false
	options_position.visible=false
	options_rotation.visible=false
	
func on_mesh_item_selected() :
	refresh_tool_helper_properties()
	var selected_mesh_item:TreeItem=mesh_tree_bar.get_selected()
	if selected_mesh_item==mesh_tree_root :
		return
	if last_selected_mesh_item!=null :
		last_selected_mesh_item.set_editable(0,false)
			
	last_selected_mesh_item=selected_mesh_item
	#selected_mesh_item.set_editable(0,true)	
	if tool_mode==tool_modes.POSITION :
		options_position.target_mesh=selected_mesh_item.get_metadata(0)
		options_position.update_values()
	if tool_mode==tool_modes.ROTATION :
		options_rotation.target_mesh=selected_mesh_item.get_metadata(0)
		options_rotation.update_values()
		
	pass
func on_mesh_item_activated() :
	var selected_mesh_item:TreeItem=mesh_tree_bar.get_selected()
	if selected_mesh_item==mesh_tree_root or selected_mesh_item==null :
		return
	selected_mesh_item.set_editable(0,true)

	pass
func on_btn_add_mesh_clicked() :
	var mesh_item:TreeItem=$actions.add_mesh()
	var mesh=mesh_item.get_metadata(0)
	var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"add_mesh",[mesh.id,mesh])
	var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_mesh",[mesh.id])
	ur_manager.add_undoredo(undo_action,redo_action)
	pass
	
func on_btn_remove_mesh_clicked() :
	var mesh:mesh_node=$actions.remove_mesh()
	var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"add_mesh",[mesh.id,mesh])
	var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_mesh",[mesh.id])
	ur_manager.add_undoredo(undo_action,redo_action)
	pass
	

	
func _unhandled_input(event):
	if last_selected_mesh_item==null :
		return
		
	#Hand Navigation
	if Input.is_action_pressed("ui_select") :
		if event is InputEventMouseButton :
			if event.is_pressed() :
				if event.button_index==BUTTON_LEFT :
					#print("hand navigation started")
					last_mouse_position=get_global_mouse_position()
					return
			else :
				last_mouse_position=Vector2.INF
				return
		if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_LEFT) :
			get_node("Camera2D").offset-=get_global_mouse_position()-last_mouse_position
			last_mouse_position=get_global_mouse_position()	
			return
			
	else : 	
		if Input.is_action_just_pressed("ui_middle_mouse") :
			last_mouse_position=get_global_mouse_position()
		if Input.is_action_just_released("ui_middle_mouse"):
			last_mouse_position=Vector2.INF
			
		if Input.is_action_pressed("ui_middle_mouse") :
			get_node("Camera2D").offset-=get_global_mouse_position()-last_mouse_position
			last_mouse_position=get_global_mouse_position()	
			return
		
		
		
		
	#Tools Functions
	var method_name="on_"
	if event is InputEventMouseButton :
		if event.is_pressed() :
			if event.button_index==BUTTON_LEFT :
				method_name+="left_click_"
			elif event.button_index==BUTTON_RIGHT :
				method_name+="right_click_"
		else :
			if event.button_index==BUTTON_LEFT :
				method_name+="left_release_"
			elif event.button_index==BUTTON_RIGHT :
				method_name+="right_release_"
	elif event is InputEventMouseMotion :
		method_name+="mouse_move_"
	
	if method_name=="on_" :
		return
	
	if tool_mode==tool_modes.SELECT :
		method_name+="mode_select"
	elif tool_mode==tool_modes.PARTICLE :
		method_name+="mode_particle"
	elif tool_mode==tool_modes.SPRING :
		method_name+="mode_spring"
	elif tool_mode==tool_modes.POLYGON :
		method_name+="mode_polygon"
	elif tool_mode==tool_modes.POSITION :
		method_name+="mode_position"
	elif tool_mode==tool_modes.ROTATION :
		method_name+="mode_rotation"
		
	if method_name!="on_" && has_method(method_name)==true :
		call(method_name)

#MOUSE LEFT CLICK		

	
func on_left_click_mode_select() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	
	
	if selected_particles.size()>0 :
		var minmax=get_rect_from_particle_list(selected_particles)
		minmax[0]-=Vector2(3.0,3.0)
		minmax[1]+=Vector2(3.0,3.0)
		var mp=get_global_mouse_position()
		if (mp.x>minmax[0].x and mp.y>minmax[0].y and mp.x<minmax[1].x and mp.y<minmax[1].y) :
			select_transform_mode=true
		else :
			select_transform_mode=false
			selected_particles.clear()
	#Selecting and move a single particle
	if selected_particles.size()==0 :
		var nearest_particle=get_nearest_particle(target_mesh,6.0)
		if(nearest_particle!=-1) :
			selected_particles.append(nearest_particle)
			select_transform_mode=true
			options_selected_particles.target_mesh=target_mesh
			options_selected_particles.selected_particles=selected_particles
			clear_tool_options_panel()
			options_selected_particles.visible=true
	#Saving old positions of the particles
	particle_old_positions.clear()
	for pi in selected_particles :
		particle_old_positions.append(target_mesh.particles[pi].position)
			
			
	
	last_mouse_position=get_global_mouse_position()
	pass
func on_left_click_mode_particle() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var target_position=get_global_mouse_position()
	if snap_to_grid:
		target_position=snapped_position(target_position)
	
	var p=target_mesh.create_particle(clear_extra_decimals(target_mesh.to_local(target_position ) ),options_particle.value_radius.value,options_particle.value_internal.pressed)
	$actions.insert_particle(target_mesh,p)
	var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"insert_particle",[target_mesh,p,target_mesh.particles.size()-1])
	var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_particle",[target_mesh,p.id])
	ur_manager.add_undoredo(undo_action,redo_action)
func on_left_click_mode_spring() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var finded_particle_index:int=get_nearest_particle(target_mesh)
	
	if finded_particle_index==-1 :
		spring_start_particle_index=-1
		guides.clear()
		guides.update()
		return
		
	
	if spring_start_particle_index==-1 :
		spring_start_particle_index=finded_particle_index
	else :
		var is_added=$actions.add_spring(target_mesh,spring_start_particle_index,finded_particle_index,options_spring.value_internal.pressed)
		print(is_added)
		if is_added :
			var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"add_spring",[target_mesh,spring_start_particle_index,finded_particle_index,false])
			var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_spring",[ target_mesh,[spring_start_particle_index,finded_particle_index],false ])
			ur_manager.add_undoredo(undo_action,redo_action)
		spring_start_particle_index=-1
		guides.clear()
		guides.update()
		
	
	pass
func on_left_click_mode_polygon() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var finded_particle_index:int=get_nearest_particle(target_mesh)
	
	if finded_particle_index==-1 :
		polygon_container.clear()
		guides.clear()
		guides.update()
		polygon_redrawing_process=false
		target_mesh.update()
		return
	
		
	var is_first_polygon_point:bool=false
	if polygon_container.size()!=0 :
		if polygon_container[0]==finded_particle_index :
			is_first_polygon_point=true
			polygon_redrawing_process=false
			target_mesh.update()
			
	
	if is_first_polygon_point :
		if polygon_container.size()<3 :
			return
		var old_polygon_copy=target_mesh.polygon.duplicate()
		var is_added=$actions.set_polygon(target_mesh,polygon_container.duplicate())
		if is_added :
			var polygon_copy=polygon_container.duplicate()
			var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_polygon",[target_mesh,polygon_copy])
			var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_polygon",[ target_mesh,old_polygon_copy])
			ur_manager.add_undoredo(undo_action,redo_action)
		polygon_container.clear()
		guides.clear()
		guides.update()
	else :
		if polygon_container.find( finded_particle_index )==-1 :
			polygon_container.append(finded_particle_index)
			polygon_redrawing_process=true
			target_mesh.update()
			
func on_left_click_mode_position() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	mesh_old_position=target_mesh.global_position
	last_mouse_position=get_global_mouse_position()
	
	pass

func on_left_click_mode_rotation() :
	if is_there_a_mesh()==false :
		return
	last_mouse_position=get_global_mouse_position()
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	mesh_old_rotation=target_mesh.global_rotation_degrees
	pass


#MOUSE LEFT RELEASE
func on_left_release_mode_select() :
	
	if(selected_particles.size()>0 and select_transform_mode==true) :
		select_transform_mode=false
		var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
		var particle_new_positions=[]
		for pi in selected_particles :
			particle_new_positions.append(target_mesh.particles[pi].position)
		var copied_selected_particles=selected_particles.duplicate()
		var copied_particle_old_positions=particle_old_positions.duplicate()
		var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,copied_particle_old_positions])
		var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_particle_positions",[target_mesh,copied_selected_particles,particle_new_positions])
		ur_manager.add_undoredo(undo_action,redo_action)
		print("undo redo added")
		return
		
			
		
	if is_there_a_mesh()!=false :
			
		var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
		selected_particles=get_particles_via_rect(target_mesh,last_mouse_position,get_global_mouse_position())
		if selected_particles.size()>0 :
			highlight_selected_particles_with_guides()
			options_selected_particles.target_mesh=target_mesh
			options_selected_particles.selected_particles=selected_particles
			clear_tool_options_panel()
			options_selected_particles.visible=true
		else :
			clear_tool_options_panel()
			guides.clear()
			options_none.visible=true
			
			
		
		
	last_mouse_position=Vector2.INF
	#guides.clear()
	guides.update()
	
func on_left_release_mode_position() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	last_mouse_position=Vector2.INF
	var undo_action=ur_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,mesh_old_position])
	var redo_action=ur_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_mesh_position",[target_mesh,target_mesh.global_position])
	ur_manager.add_undoredo(undo_action,redo_action)
	pass
	
func on_left_release_mode_rotation() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	last_mouse_position=Vector2.INF
	var undo_action=ur_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_mesh_rotation",[target_mesh,mesh_old_rotation])
	var redo_action=ur_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_mesh_rotation",[target_mesh,stepify(target_mesh.global_rotation_degrees,0.01) ])
	ur_manager.add_undoredo(undo_action,redo_action)
	pass

#MOUSE RIGHT CLICK
func on_right_click_mode_select() :
	pass
func on_right_click_mode_particle() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var finded_particle_index:int=get_nearest_particle(target_mesh)
		
	if(finded_particle_index==-1) :
		return
	var target_particle=target_mesh.particles[finded_particle_index]
	$actions.remove_particle(target_mesh,target_particle.id)
	var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"insert_particle",[target_mesh,target_particle,finded_particle_index])
	var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_particle",[target_mesh,target_particle.id])
	ur_manager.add_undoredo(undo_action,redo_action)
	pass
func on_right_click_mode_spring() :
	if is_there_a_mesh()==false :
		return
	
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var find_circle=6.0
	var finded_spring_index=-1
	var min_dist:float=INF
	var is_internal=false
	var spring_collections=[target_mesh.springs,target_mesh.internal_springs]
	for i in range(spring_collections.size()) :
		var spring_list=spring_collections[i]
		for s in range(spring_list.size()):
			var spring=spring_list[s]
			var pa:mesh_node.particle=target_mesh.particles[spring[0]]
			var pb:mesh_node.particle=target_mesh.particles[spring[1]]
			var diff=pb.global_position-pa.global_position
			var unit:Vector2=diff.normalized()
			var normal:Vector2=unit.tangent()
			var bridge=get_global_mouse_position()-pa.global_position
			var dist=abs(bridge.dot(normal))
			if dist<find_circle :
				var proj=bridge.dot(unit)
				if(proj>0 and proj<diff.length() ):
					if dist<min_dist:
						min_dist=dist
						finded_spring_index=s
						is_internal=true if i==1 else false
	if finded_spring_index!=-1 :
		var spring=target_mesh.internal_springs[finded_spring_index] if is_internal==true else target_mesh.springs[finded_spring_index] 
		var is_removed=$actions.remove_spring(target_mesh,spring,is_internal)
		if is_removed :
			var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"add_spring",[target_mesh,spring[0],spring[1],is_internal])
			var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_spring",[target_mesh,spring,is_internal])
			ur_manager.add_undoredo(undo_action,redo_action)
				
		
	pass
func on_right_click_mode_polygon() :
	if is_there_a_mesh()==false :
		return
		
	
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	
	if target_mesh.polygon.size()==0 : 
		return
	var find_circle=6.0
	var finded_polygon_index=-1
	var min_circumference=INF
	var mp=get_global_mouse_position()
	var polygon=target_mesh.polygon
	var is_inside=true
	var last_sign=0
	for n in range(polygon.size()):
		var p=target_mesh.particles[ polygon[n] ].global_position
		var np=target_mesh.particles[ polygon[(n+1)%polygon.size() ] ].global_position
		var diff=np-p
		var length=diff.length()
		var normal=diff.normalized().tangent()
		var bridge=mp-p
		var dist=bridge.dot(normal)
		if last_sign==0 :
			last_sign=sign(dist)
			continue
		
		if(last_sign!=sign(dist)):
			is_inside=false
			break;
		
			
	if is_inside:
		print("silinecek polygon bulundu")
		var polygon_copy=target_mesh.polygon.duplicate()
		var new_polygon_copy=[]
		var is_removed=$actions.set_polygon(target_mesh,new_polygon_copy )
		if is_removed :
			var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_polygon",[target_mesh,polygon_copy])
			var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"set_polygon",[target_mesh,new_polygon_copy])
			ur_manager.add_undoredo(undo_action,redo_action)
			
	
		
	
	

#MOUSE MOVE

func on_mouse_move_mode_select() :
	if is_there_a_mesh()==false :
		return
	
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	
	if selected_particles.size()>0 :
		
		if select_transform_mode==true :
			var delta=target_mesh.to_local(get_global_mouse_position())-target_mesh.to_local(last_mouse_position )
			if snap_to_grid:
				delta=target_mesh.to_local( snapped_position(get_global_mouse_position()) )- target_mesh.to_local( snapped_position(last_mouse_position) )
			var new_positions=[]
			for i in selected_particles :
				var particle=target_mesh.particles[i]
				var new_position=particle.position+delta
				new_position=clear_extra_decimals(new_position)
				new_positions.append(new_position)
			$actions.set_particle_positions(target_mesh,selected_particles,new_positions)
			# adding spacial snap to a selected single  particle
			if selected_particles.size()==1 and snap_to_grid :
				var single_particle=target_mesh.particles[selected_particles[0] ]
				var new_position=snapped_position(single_particle.global_position)
				new_position=target_mesh.to_local(new_position)
				new_position=clear_extra_decimals(new_position)
				$actions.set_particle_positions(target_mesh,selected_particles,[new_position])
		
			
		last_mouse_position=get_global_mouse_position()
		return
		
	if(last_mouse_position==Vector2.INF) : 
		return
		
	
	guides.clear()
	var deltaMouse=get_global_mouse_position()-last_mouse_position
	var a=last_mouse_position
	var b=last_mouse_position+Vector2(deltaMouse.x,0)
	var c=last_mouse_position+deltaMouse
	var d=last_mouse_position+Vector2(0,deltaMouse.y)
	
	guides.add_rect_guide(a,c,Global.COLOR_GUIDE_POLYGON,true, 3.0)
	
	
	var intersect_particles=get_particles_via_rect(target_mesh,a,c)
	highlight_particles_with_guides(intersect_particles)
	
	guides.update()
	pass
func on_mouse_move_mode_particle() :
	pass
func on_mouse_move_mode_spring() :
	if spring_start_particle_index==-1 :
		return
	
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var finded_particle_index:int=get_nearest_particle(target_mesh)
	guides.clear()
	if finded_particle_index!=-1 :
		guides.add_circle_guide(target_mesh.particles[finded_particle_index].global_position,6.0,Global.COLOR_GUIDE_SELECTED_PARTICLE )
	
	guides.add_line_guide(target_mesh.particles[spring_start_particle_index].global_position,get_global_mouse_position(),Global.COLOR_SPRING,false,true,5.0)
	guides.update()
	pass
func on_mouse_move_mode_polygon() :
	if polygon_container.size()==0 :
		return
	
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var finded_particle_index:int=get_nearest_particle(target_mesh)
	guides.clear()
	if finded_particle_index!=-1 :
		guides.add_circle_guide(target_mesh.particles[finded_particle_index].global_position,6.0,Global.COLOR_GUIDE_SELECTED_PARTICLE )
	
	for i in range(0,polygon_container.size()-1) :
		var cp=polygon_container[i]
		var np=polygon_container[ (i+1)%polygon_container.size() ]
		guides.add_line_guide(target_mesh.particles[cp].global_position,target_mesh.particles[np].global_position,Global.COLOR_POLYGON,false,true,5.0 )
	guides.add_line_guide(target_mesh.particles[polygon_container[polygon_container.size()-1]].global_position,get_global_mouse_position(),Global.COLOR_GUIDE_POLYGON,false,true,5.0 )
	guides.update()
	
func on_mouse_move_mode_position() :
	if is_there_a_mesh()==false :
		return
	if last_mouse_position==Vector2.INF :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var delta=get_global_mouse_position()-last_mouse_position
	var new_pos=target_mesh.global_position+delta
	if snap_to_grid:
		new_pos=snapped_position(new_pos)
		if target_mesh.global_position==new_pos :
			return
	new_pos=clear_extra_decimals(new_pos)
	$actions.set_mesh_position(target_mesh,new_pos)
	last_mouse_position=get_global_mouse_position()
	options_position.update_values()
	pass
	
func on_mouse_move_mode_rotation() :
	if is_there_a_mesh()==false :
		return
	if last_mouse_position==Vector2.INF :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var prev_angle=(last_mouse_position-target_mesh.global_position).angle()
	var cur_angle=(get_global_mouse_position()-target_mesh.global_position).angle()
	var delta=cur_angle-prev_angle
	var new_angle=target_mesh.global_rotation+delta
	new_angle=rad2deg(new_angle)
	new_angle=stepify(new_angle,0.01)
	$actions.set_mesh_rotation(target_mesh,new_angle)
	last_mouse_position=get_global_mouse_position()
	options_rotation.update_values()
	pass
	
#HELPER METHODS
func highlight_selected_particles_with_guides():
	if is_there_a_mesh()!=false :			
		var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
		guides.clear()
		highlight_particles_with_guides(selected_particles)
		var minmax=get_rect_from_particle_list(selected_particles)
		guides.add_rect_guide(minmax[0]-Vector2(3.0,3.0),minmax[1]+Vector2(3.0,3.0),Global.COLOR_GUIDE_POLYGON,true,3.0)
		guides.update()
		


func get_nearest_particle(target_mesh:mesh_node,radius:float=6.0) ->int:
	var finded_particle_index:int=-1
	for i in range(0,target_mesh.particles.size()) :
		var p:mesh_node.particle=target_mesh.particles[i]
		var dist:Vector2=p.global_position-get_global_mouse_position()
		if dist.length() <radius :
			finded_particle_index=i
			break
	return finded_particle_index
	
func get_particles_via_rect(target_mesh:mesh_node,a:Vector2,b:Vector2) ->PoolVector2Array:
	var rect_min=Vector2(min(a.x,b.x),min(a.y,b.y))
	var rect_max=Vector2(max(a.x,b.x),max(a.y,b.y))
	var rect_size=rect_max-rect_min
	var rect=Rect2(rect_min,rect_size)
	
	var result=[]
	for i in range(0,target_mesh.particles.size()) :
		var p=target_mesh.particles[i]
		var halfsize=Vector2(p.radius,p.radius)
		var p_rect:Rect2=Rect2(p.global_position-halfsize,halfsize*2.0)
		if rect.intersects(p_rect,true) :
			result.append(i)
	return result
	
func highlight_particles_with_guides(particle_index_list:Array) :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	for p in particle_index_list :
		if p<target_mesh.particles.size():
			var particle=target_mesh.particles[p]
			guides.add_circle_guide(particle.global_position,particle.radius+3.0,Global.COLOR_GUIDE_SELECTED_PARTICLE)
		
func get_rect_from_particle_list(particle_index_list:Array) -> Array:
	if is_there_a_mesh()==false :
		return []
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var pmin=Vector2(INF,INF)
	var pmax=Vector2(-INF,-INF)
	for p in particle_index_list :
		if p>=target_mesh.particles.size():
			continue
		var particle=target_mesh.particles[p]
		var particle_min=particle.global_position-Vector2(particle.radius,particle.radius)
		var particle_max=particle.global_position+Vector2(particle.radius,particle.radius)
		if particle_min.x<pmin.x :
			pmin.x=particle_min.x
		if particle_max.x>pmax.x :
			pmax.x=particle_max.x
		if particle_min.y<pmin.y :
			pmin.y=particle_min.y
		if particle_max.y>pmax.y :
			pmax.y=particle_max.y
	return [pmin,pmax]
	
func remove_selected_particles() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	var particle_list=[]
	var particle_id_list=[]
	var particle_index_position_list=[]
	for pi in selected_particles :
		particle_list.append(target_mesh.particles[pi] )
		particle_id_list.append(target_mesh.particles[pi].id)
		particle_index_position_list.append(pi)
	$actions.remove_particles(target_mesh,particle_id_list)
	var undo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"insert_particles",[target_mesh,particle_list,particle_index_position_list])
	var redo_action=undoredo_manager.create_action($actions,undoredo_manager.action_types.CALL,"remove_particles",[target_mesh,particle_id_list])
	ur_manager.add_undoredo(undo_action,redo_action)
	selected_particles.clear()
	select_transform_mode=false
	last_mouse_position=Vector2.INF
	update_canvas()
	
func select_all_particles() :
	if is_there_a_mesh()==false :
		return
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	selected_particles.clear()
	for i in target_mesh.particles.size() :
		selected_particles.append(i)
	update_canvas()
	

func update_canvas() :
	if is_there_a_mesh()==false :
		return []
	var target_mesh:mesh_node=last_selected_mesh_item.get_metadata(0)
	if(tool_mode==tool_modes.SELECT) :
		guides.clear()
		highlight_selected_particles_with_guides()
		options_selected_particles.update_values()
		if selected_particles.size()==0:
			clear_tool_options_panel()
			options_none.visible=true
	elif(tool_mode==tool_modes.SPRING):
		guides.clear()
		if spring_start_particle_index!=-1:
			if spring_start_particle_index<target_mesh.particles.size() :
				guides.clear()
				guides.add_line_guide(target_mesh.particles[spring_start_particle_index].global_position,get_global_mouse_position(),Global.COLOR_SPRING,false,true,5.0)
			else :
				spring_start_particle_index=-1
				guides.clear()	
				guides.update()
	elif (tool_mode==tool_modes.POLYGON) :
		guides.clear()
		if(polygon_container.size()>0) :
			var there_is_missing_particle=false
			for i in range(0,polygon_container.size()-1) :
				var cp=polygon_container[i]
				var np=polygon_container[ (i+1)%polygon_container.size() ]
				if cp>=target_mesh.particles.size() or np>=target_mesh.particles.size() :
					there_is_missing_particle=true
					break
				guides.add_line_guide(target_mesh.particles[cp].global_position,target_mesh.particles[np].global_position,Global.COLOR_POLYGON,false,true,5.0 )
			if there_is_missing_particle :
				polygon_container.clear()
				guides.clear()
				guides.update()
			else:
				guides.add_line_guide(target_mesh.particles[polygon_container[polygon_container.size()-1]].global_position,get_global_mouse_position(),Global.COLOR_GUIDE_POLYGON,false,true,5.0 )
	elif (tool_mode==tool_modes.POSITION) :
		options_position.update_values()
	elif (tool_mode==tool_modes.ROTATION) :
		options_rotation.update_values()	
		
	guides.update()
	target_mesh.update()	
	
func update_all_meshes() :
	var meshes:Node2D=get_node("canvas/meshes")
	for mesh in meshes.get_children() :
		mesh.update()

func create_new_file():
	ur_manager.clear()
	remove_all_meshes()
	mesh_id_counter=0
	$actions.add_mesh()
	self.file_location=""
	self.reference_image_location=""
	
func update_window_title() :
	var title=""
	if file_location!="":
		title=window_base_title + " - " + file_location.get_file()
	else:
		title=window_base_title + " - New File" 
	if is_file_changed:
		title=title+"*"
	OS.set_window_title(title)
	

func remove_all_meshes():
	var item:TreeItem=mesh_tree_root.get_children()
	while(mesh_tree_root.get_children()!=null) :
		mesh_tree_root.remove_child(mesh_tree_root.get_children())
	var meshes_node=get_node("%meshes")
	while (meshes_node.get_child_count()!=0):
		meshes_node.remove_child(meshes_node.get_child(0))
	mesh_tree_bar.update()
		
func snapped_position(pos:Vector2)->Vector2:
	var grid_size=$grid.grid_size
	var result=Vector2(round(pos.x/grid_size.x),round(pos.y/grid_size.y) )*grid_size
	return result
	
func clear_extra_decimals(pos:Vector2)->Vector2 :
	return Vector2(stepify(pos.x,0.01),stepify(pos.y,0.01))
	
		

#CHECK MESH ITEM
func is_there_a_mesh()-> bool:
	if last_selected_mesh_item==null :
		return false
	else :
		if last_selected_mesh_item.get_metadata(0)==null :
			return false
	return true


