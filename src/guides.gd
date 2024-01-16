extends Node2D
class_name guides

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var app=get_tree().root.get_node("app")
var guide_list=[]
# Called when the node enters the scene tree for the first time.
func _ready():
	app.connect("zoom_changed",self,"update")
	pass # Replace with function body.
	
	
func _draw():
	var zoom_factor=get_tree().current_scene.get_node("Camera2D").zoom.x
	for g in guide_list :
		if  g is guide_line   :
			if g.enable_dashed:
				draw_dashed_line(g.p_a,g.p_b,g.color,1.0,g.dash_length*zoom_factor,true)
			else :
				draw_line(g.p_a,g.p_b,g.color,1.0,true)
		elif g is guide_circle :
			draw_circle(g.p,g.radius*zoom_factor,g.color) 
		elif g is guide_rect :
			var a=g.p_min
			var b=Vector2(g.p_max.x,g.p_min.y)
			var c=g.p_max
			var d=Vector2(g.p_min.x,g.p_max.y)
			if g.enable_dashed :
				draw_dashed_line(a,b,g.color,1.0,g.dash_length*zoom_factor,true)
				draw_dashed_line(b,c,g.color,1.0,g.dash_length*zoom_factor,true)
				draw_dashed_line(c,d,g.color,1.0,g.dash_length*zoom_factor,true)
				draw_dashed_line(d,a,g.color,1.0,g.dash_length*zoom_factor,true)
			else :
				draw_line(a,b,g.color,1.0,true)
				draw_line(b,c,g.color,1.0,true)
				draw_line(c,d,g.color,1.0,true)
				draw_line(d,a,g.color,1.0,true)
			
	
	
func draw_dashed_line(from:Vector2, to:Vector2, color:Color,width:float=1.0, dash_length:float=10.0, antialiased:bool=true):
	var length=(to-from).length()
	var unit=(to-from).normalized()
	if(length<dash_length) :
		draw_line(from,to,color,width,antialiased)
		return
	var dash_toggle=false
	var cur_pos=from
	var step_count=length/dash_length
	var dash_vec=unit*dash_length
	for i in range(step_count) :
		if dash_toggle==false:
			draw_line(cur_pos,cur_pos+dash_vec,color,width,antialiased)
			cur_pos+=dash_vec
			dash_toggle=true
		else :
			cur_pos+=dash_vec
			dash_toggle=false
	
func clear() :
	guide_list.clear()



func add_rect_guide(p_min:Vector2,p_max:Vector2,color:Color,enable_dashed:bool=false,dash_length:float=10.0) :
	var n_guide=guide_rect.new()
	n_guide.p_min=p_min
	n_guide.p_max=p_max
	n_guide.color=color
	n_guide.enable_dashed=enable_dashed
	n_guide.dash_length=dash_length
	guide_list.append(n_guide)

func add_line_guide(p_a:Vector2,p_b:Vector2,color:Color,enable_arrow:bool=false,enable_dashed=false,dash_length=10.0) :
	var n_guide=guide_line.new()
	n_guide.p_a=p_a
	n_guide.p_b=p_b
	n_guide.color=color
	n_guide.enable_arrow=enable_arrow
	n_guide.enable_dashed=enable_dashed
	n_guide.dash_length=dash_length
	guide_list.append(n_guide)
	
func add_circle_guide(p:Vector2,radius:float,color:Color) :
	var n_guide=guide_circle.new()
	n_guide.p=p
	n_guide.radius=radius
	n_guide.color=color
	guide_list.append(n_guide)
	
class guide_rect :
	var p_min:Vector2
	var p_max:Vector2
	var enable_dashed:bool=false
	var dash_length=10.0
	var color:Color

class guide_line :
	var p_a:Vector2
	var p_b:Vector2
	var enable_arrow:bool=false
	var enable_dashed:bool=false
	var dash_length=10.0
	var color:Color

class guide_circle :
	var p:Vector2
	var radius=1
	var color:Color
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
