extends Node

onready var app=get_tree().root.get_node("app")



#ACTIONS
func set_particle_positions(target_mesh:mesh_node,particle_index_list:Array,particle_position_list:Array) ->bool:
	target_mesh.set_particle_positions(particle_index_list,particle_position_list)
	app.highlight_selected_particles_with_guides()
	app.options_selected_particles.update_values()
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
	
func set_particle_radius_values(target_mesh:mesh_node,particle_index_list:Array,radius_values_list:Array)->bool:
	for i in range(particle_index_list.size()) :
		var index=particle_index_list[i]
		var value=radius_values_list[i]
		var particle=target_mesh.particles[index]
		particle.radius=value
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
func set_particle_internal_values(target_mesh:mesh_node,particle_index_list:Array,internal_values_list:Array)->bool:
	for i in range(particle_index_list.size()) :
		var index=particle_index_list[i]
		var value=internal_values_list[i]
		var particle=target_mesh.particles[index]
		particle.enable_internal=value
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
	
func insert_particle(target_mesh:mesh_node,particle:mesh_node.particle,particle_position_index:int=-1) ->bool:
	if particle_position_index>-1 :
		target_mesh.particles.insert(particle_position_index,particle)
		for s in target_mesh.springs :
			if s[0]>=particle_position_index:
				s[0]=(s[0]+1)%target_mesh.particles.size()
			if s[1]>=particle_position_index:
				s[1]=(s[1]+1)%target_mesh.particles.size()
		for s in target_mesh.internal_springs :
			if s[0]>=particle_position_index:
				s[0]=(s[0]+1)%target_mesh.particles.size()
			if s[1]>=particle_position_index:
				s[1]=(s[1]+1)%target_mesh.particles.size()
		for i in range(target_mesh.polygon.size()) :
			var p=target_mesh.polygon[i]
			if p>=particle_position_index:
				target_mesh.polygon[i]=(target_mesh.polygon[i]+1)%target_mesh.particles.size()
				
	else :
		target_mesh.particles.append(particle)
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
	
func insert_particles(target_mesh:mesh_node,particles:Array,particles_position_indexes:Array) ->bool:
	for i in range(particles.size()) :
		insert_particle(target_mesh,particles[i],particles_position_indexes[i])
	return true
	
func reverse_mesh(target_mesh:mesh_node,particles:Array,springs:Array,internal_springs:Array,polygons:Array)->bool:
	target_mesh.particles=particles.duplicate(true)
	target_mesh.springs=springs.duplicate(true)
	target_mesh.internal_springs=internal_springs.duplicate(true)
	target_mesh.polygons=polygons.duplicate(true)
	target_mesh.update()
	app.is_file_changed=true
	return true

	
func remove_particle(target_mesh,id:int)->bool :
	var removed_particle:mesh_node.particle
	var index:int=-1
	for i in range(0,target_mesh.particles.size()) :
		var p:mesh_node.particle=target_mesh.particles[i]
		if(p.id==id) :
			index=i
	if index!=-1 :
		removed_particle=target_mesh.particles[index]
		target_mesh.particles.remove(index)
		#find which spring contains the particle and remove
		var spring_collections=[target_mesh.springs,target_mesh.internal_springs]
		var blacklist=[]
		for i in range(spring_collections.size() ):
			var spring_list=spring_collections[i]
			blacklist.clear()
			for s in range(spring_list.size()):
				var spring=spring_list[s]
				if spring[0]==index or spring[1]==index:
					blacklist.append(spring)
			for spring in blacklist :
				remove_spring(target_mesh,spring,i==1)
		#fix particle index problems of springs
		for i in range(spring_collections.size() ):
			var spring_list=spring_collections[i]
			for s in range(spring_list.size()):
				var spring=spring_list[s]
				if spring[0]>index:
					spring[0]-=1
				if spring[1]>index:
					spring[1]-=1
		#find whish polygon contains the particle and remove from polygon
		blacklist=[]
		var polygon=target_mesh.polygon
		var n=0
		while n!=polygon.size() :
			var particle_index=polygon[n]
			if particle_index==index:
				polygon.remove(n)
			else :
				if particle_index>index :
					polygon[n]-=1
				n+=1
		#if polygon particle count less than 3, add to blacklist
		if polygon.size()<3 :
			target_mesh.polygon=[]
			
		target_mesh.update()
		app.update_canvas()
		app.is_file_changed=true
		return true
	return false
	pass
	
func remove_particles(target_mesh:mesh_node,particle_id_list:Array) :
	for pi in particle_id_list:
		remove_particle(target_mesh,pi)
	
func add_spring(target_mesh:mesh_node, p_a:int,p_b:int,is_internal:bool) ->bool:
	var n_spring=[p_a,p_b]
	var n_spring_r=[p_b,p_a]
	if is_internal :
		if target_mesh.internal_springs.find(n_spring)==-1 and target_mesh.internal_springs.find(n_spring_r)==-1 :
			target_mesh.internal_springs.append(n_spring)
		else :
			return false
	else :
		if target_mesh.springs.find(n_spring)==-1 and target_mesh.springs.find(n_spring_r)==-1:
			target_mesh.springs.append(n_spring)
		else :
			return false
	app.update_canvas()
	target_mesh.update()
	app.is_file_changed=true
	return true

func remove_spring(target_mesh:mesh_node,s:Array,is_internal:bool) :
	var finded_index:int=-1
	if is_internal :
		finded_index=target_mesh.internal_springs.find(s)
		if finded_index!=-1 :
			target_mesh.internal_springs.remove(finded_index)
			target_mesh.update()
			app.update_canvas()
			app.is_file_changed=true
			return true
	else :
		finded_index=target_mesh.springs.find(s)
		if finded_index!=-1 :
			target_mesh.springs.remove(finded_index)
			target_mesh.update()
			app.update_canvas()
			app.is_file_changed=true
			return true
	return false
	
func set_polygon(target_mesh:mesh_node,polygon:Array) ->bool:
	target_mesh.polygon=polygon.duplicate(true)
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	print(target_mesh.polygon)
	return true
	

	

	
func set_mesh_position(target_mesh:mesh_node,value:Vector2)->bool :
	if target_mesh.global_position==value :
		return false
	target_mesh.global_position=value
	target_mesh.update_particle_global_positions()
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
func set_mesh_rotation(target_mesh:mesh_node,value:float)->bool :
	if target_mesh.global_rotation_degrees==value :
		return false
	target_mesh.global_rotation_degrees=value
	target_mesh.update_particle_global_positions()
	target_mesh.update()
	app.update_canvas()
	app.is_file_changed=true
	return true
	
func add_mesh(specific_id:int=-1,specific_mesh_node:mesh_node=null) ->TreeItem:
	var mesh_id:int
	if specific_id==-1 :
		mesh_id=app.mesh_id_counter
		app.mesh_id_counter+=1
	else :
		mesh_id=specific_id
		
	var mesh_name="Mesh_"+str(mesh_id)
	
	var mesh:mesh_node
	if specific_mesh_node==null :
		mesh=mesh_node.new()
		mesh.name=mesh_name
		mesh.id=mesh_id
	else :
		mesh=specific_mesh_node
	get_node("%meshes").add_child(mesh)
	var tree_item=app.mesh_tree_bar.create_item(app.mesh_tree_root,0)
	tree_item.set_text(0,mesh_name )
	tree_item.set_metadata(0,mesh)
	tree_item.select(0)
	app.is_file_changed=true
	return tree_item
	
func remove_mesh(specific_id:int=-1)->mesh_node:
	var result_mesh_item=null
	var target_mesh_item:TreeItem=app.mesh_tree_bar.get_selected()
	if(specific_id!=-1) :
		var finded_item:TreeItem=null
		var item:TreeItem=app.mesh_tree_root.get_children()
		while(item!=null) :
			var mesh:mesh_node=item.get_metadata(0)
			if(mesh.id==specific_id) :
				finded_item=item
				break
			item=item.get_next()
		if(finded_item==null) :
			printerr("remove_mesh() - operation failed- via specific id.")
			return result_mesh_item
		target_mesh_item=finded_item
	
	if target_mesh_item==app.mesh_tree_root or target_mesh_item==null : 
		printerr("remove_mesh() - operation failed.")
		return result_mesh_item
	var target_mesh:Node2D=target_mesh_item.get_metadata(0)
	if(target_mesh_item==app.last_selected_mesh_item) :
		if app.last_selected_mesh_item.get_prev()!=null :
			app.last_selected_mesh_item.get_prev().select(0)
		elif app.last_selected_mesh_item.get_next()!=null :
			app.last_selected_mesh_item.get_next().select(0)
	result_mesh_item=target_mesh
	target_mesh.get_parent().remove_child(target_mesh)
	app.mesh_tree_root.remove_child(target_mesh_item)
	app.mesh_tree_bar.update()
	app.is_file_changed=true
	return result_mesh_item
	

