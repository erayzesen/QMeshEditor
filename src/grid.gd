extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var grid_cell_size=Vector2(1000,1000)
export(Vector2) var grid_size=Vector2(32,32)
export(Color) var grid_color=Color("#242424");
# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	pass # Replace with function body.
	
func _draw():
	var start_pos=-grid_cell_size*grid_size
	for x in grid_cell_size.x*2 :
		var p1=start_pos+Vector2(x*grid_size.x,0)
		var p2=start_pos+Vector2(x*grid_size.x,grid_cell_size.y*2*grid_size.y)
		draw_line(p1,p2,grid_color,1,false) 
	for y in grid_cell_size.y*2 :
		var p1=start_pos+Vector2(0,y*grid_size.y)
		var p2=start_pos+Vector2(grid_cell_size.x*grid_size.x*2,y*grid_size.y)
		draw_line(p1,p2,grid_color,1,false) 
		
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
