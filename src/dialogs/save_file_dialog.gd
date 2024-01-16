extends FileDialog


onready var app=get_tree().root.get_node("app")
onready var meshes=get_node("%meshes")




func _ready():
	connect("about_to_show",self,"on_open")
	connect("file_selected",self,"on_file_selected")
	pass # Replace with function body.
	
func on_open():
	
	pass
	
	
func on_file_selected(path:String):
	
	var data={}
	var mesh_datas=[]
	
	var root:TreeItem=app.mesh_tree_root
	var item:TreeItem=root.get_children()
	while item!=null :
		var mesh=item.get_metadata(0)
		var mesh_data={}
		mesh_data["name"]=item.get_text(0)
		mesh_data["position"]=[mesh.global_position.x,mesh.global_position.y]
		mesh_data["rotation"]=mesh.global_rotation_degrees
		var particles=[]
		for particle in mesh.particles:
			var particle_data={}
			particle_data["position"]=[particle.position.x,particle.position.y]
			particle_data["radius"]=particle.radius
			particle_data["is_internal"]=particle.enable_internal
			particles.append(particle_data)
		mesh_data["particles"]=particles
		mesh_data["springs"]=mesh.springs
		mesh_data["internal_springs"]=mesh.internal_springs
		mesh_data["polygon"]=mesh.polygon
		mesh_datas.append(mesh_data)
		item=item.get_next()
	data["meshes"]=mesh_datas
	data["reference_image_location"]=app.reference_image_location
	var ref_image=get_node("%reference_image")
	data["reference_image_position"]=[ref_image.global_position.x,ref_image.global_position.y]
	data["reference_image_alpha"]=ref_image.modulate.a
	var grid=app.get_node("grid")
	data["grid_size"]=[grid.grid_size.x,grid.grid_size.y]
	data["snap_to_grid"]=app.snap_to_grid
	
	
#	print(JSON.print(data))
		
			
	var file=File.new()
	file.open(path,File.WRITE)
	file.store_string(JSON.print(data))
	file.close()
	app.file_location=path
	app.is_file_changed=false
	
