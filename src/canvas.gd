extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var center_point_size=12
onready var app=get_tree().root.get_node("app")

# Called when the node enters the scene tree for the first time.
func _ready():
	app.connect("zoom_changed",self,"on_zoom_changed")
	pass # Replace with function body.
	
func on_zoom_changed() :
	update()
	
func _draw():
	var zoom_factor=get_tree().current_scene.get_node("Camera2D").zoom.x
	draw_line(Vector2(-center_point_size*zoom_factor,0),Vector2(center_point_size*zoom_factor,0),Color.webgray,1.0 )
	draw_line(Vector2(0,-center_point_size*zoom_factor),Vector2(0,center_point_size*zoom_factor),Color.webgray,1.0 )
	pass
	

	


	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
