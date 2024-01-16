extends FileDialog

onready var app=get_tree().root.get_node("app")
onready var meshes=get_node("%meshes")
onready var ur_manager=get_node("%undoredo_manager")
onready var actions=app.get_node("actions")

func _ready():
	
	connect("about_to_show",self,"on_open")
	connect("file_selected",self,"on_file_selected")
	
	call_deferred("check_cmd_arguments_to_open")
	
	
func on_open():
	
	pass
	
func check_cmd_arguments_to_open() :
	var arguments=OS.get_cmdline_args()
	if arguments.size()>0 :
		var path_arg:String=arguments[0]
		if path_arg.get_extension()=="qmesh":
			var file=File.new()
			if file.file_exists(path_arg) :
				print("opening file:" + path_arg)
				on_file_selected(path_arg)
	
func on_file_selected(path:String):
	var file=File.new()
	file.open(path,File.READ)
	var json_data=file.get_as_text()
	
	var data=JSON.parse(json_data).result
	
	
	ur_manager.clear()
	app.remove_all_meshes()
	
	var meshes=data["meshes"]
	for mesh_data in meshes :
		var mesh_item:TreeItem=actions.add_mesh()
		mesh_item.set_text(0,mesh_data["name"])
		var mesh:mesh_node=mesh_item.get_metadata(0)
		mesh.global_position=Vector2(mesh_data["position"][0],mesh_data["position"][1] )
		mesh.global_rotation_degrees=mesh_data["rotation"]
		for particle_data in mesh_data["particles"] :
			var particle=mesh.create_particle(Vector2(particle_data["position"][0],particle_data["position"][1]),particle_data["radius"],particle_data["is_internal"] )
			actions.insert_particle(mesh,particle)
		for spring_data in mesh_data["springs"]:
			actions.add_spring(mesh, spring_data[0],spring_data[1],false)
		for spring_data in mesh_data["internal_springs"]:
			actions.add_spring(mesh,spring_data[0],spring_data[1],true)
		mesh.polygon=mesh_data["polygon"]
	app.file_location=path
	app.reference_image_location=data["reference_image_location"]
	var ref_image=get_node("%reference_image")
	ref_image.global_position=Vector2(data["reference_image_position"][0],data["reference_image_position"][1])
	ref_image.modulate.a=data["reference_image_alpha"]
	app.is_file_changed=false
	var grid=app.get_node("grid")
	grid.grid_size=Vector2(data["grid_size"][0],data["grid_size"][1] )
	grid.update()
	app.snap_to_grid=data["snap_to_grid"]
	
	
	
	
	pass
