extends Node2D

class_name mesh_node


var id:int=0
var particles=[]
var springs=[]
var internal_springs=[]
var polygon=[]

var particle_id_counter:int=0
#COLORS

onready var app=get_tree().root.get_node("app")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_notify_transform(true)
	app.connect("zoom_changed",self,"on_zoom_changed")
	pass # Replace with function body.
	
func on_zoom_changed():
	update()
	
func _notification(what)->void: 
	if what == NOTIFICATION_TRANSFORM_CHANGED :
		for p in particles:
			p.global_position=p.position.rotated(rotation)+global_position
			

func _draw():
	
	var zoom_factor=get_tree().current_scene.get_node("Camera2D").zoom.x
	#draw particles
	if app.show_particles:
		for i in range(0,particles.size()) : 
			var p:particle=particles[i]
			var particle_radius=max(p.radius,1.0)
			draw_empty_circle(p.position,3.0*zoom_factor,Global.COLOR_PARTICLE)
			draw_circle(p.position,particle_radius*zoom_factor,Global.COLOR_PARTICLE)
		
	#draw springs
	if app.show_springs:
		for i in range(0,springs.size()) :
			var spring=springs[i]
			var p_a:particle=particles[spring[0]]
			var p_b:particle=particles[spring[1]]
			draw_line(p_a.position,p_b.position,Global.COLOR_SPRING,1.0,true)
		
		for i in range(0,internal_springs.size()) :
			var spring=internal_springs[i]
			var p_a:particle=particles[spring[0]]
			var p_b:particle=particles[spring[1]]
			draw_line(p_a.position,p_b.position,Global.COLOR_INTERNAL_SPRING,1.0,true)
	
	#draw polygons
	if app.show_polygons:
		if polygon.size()>0 :
			var points:PoolVector2Array=[]
			for n in polygon :
				points.append(particles[n].position )
			points.append(particles[polygon[0]].position)
			var col=Global.COLOR_POLYGON
			if app.polygon_redrawing_process==true :
				col.a=0.3
			draw_polyline(points,col,1.0,true)
			
	#draw center point
	var center_point_size=4
	
	draw_line(Vector2(-center_point_size,0),Vector2(center_point_size,0),Color.webgray,1.0,true )
	draw_line(Vector2(0,-center_point_size),Vector2(0,center_point_size),Color.webgray,1.0,true )
	
		


	
func draw_empty_circle(pos:Vector2,rad:float,color:Color,point_count:int=36,width:float=1.0,antialias:bool=true) :
	draw_arc(pos,rad,0,PI*2.0,point_count,color,width,antialias)
	
func clone() ->mesh_node:
	var n_mesh=get_script().new()
	n_mesh.id=id
	n_mesh.particles=particles
	n_mesh.springs=springs
	n_mesh.internal_springs=internal_springs
	n_mesh.polygon=polygon
	return n_mesh
	
func to_local(vec:Vector2) :
	var delta=vec-global_position
	return delta.rotated(-rotation)
	




class particle :
	var id:int
	var position:Vector2
	var global_position:Vector2
	var radius:float=0.5
	var enable_internal:bool=false
	func clone() ->particle:
		var n_part=particle.new()
		n_part.id=id
		n_part.position=position
		n_part.radius=radius
		n_part.enable_internal=enable_internal
		n_part.global_position=global_position
		return n_part
		
func update_particle_global_positions():
	for p in particles:
		p.global_position=p.position.rotated(rotation)+global_position
		
func set_particle_position(particle_index:int,vec:Vector2) :
	particles[particle_index].position=vec
	particles[particle_index].global_position=vec.rotated(rotation)+global_position
	
func set_particle_positions(particle_index_list:Array,positions:Array) :
	if particle_index_list.size()==0:
		return
	for i in range(particle_index_list.size()) :
		set_particle_position( particle_index_list[i] ,positions[i])
	update()
		
	
func create_particle(pos:Vector2,radius:float,internal:bool,particle_id:int=-1)->particle :
	var p=particle.new()
	p.position=pos
	p.global_position=p.position.rotated(rotation)+global_position
	p.radius=radius
	p.enable_internal=internal
	if particle_id==-1 :
		particle_id_counter+=1
		p.id=particle_id_counter
	else :
		p.id=particle_id
	return p
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
