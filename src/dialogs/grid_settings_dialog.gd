extends ConfirmationDialog

onready var grid=get_tree().root.get_node("app/grid")

func _ready():
	connect("about_to_show",self,"on_open")
	connect("confirmed",self,"on_confirmed")
	pass # Replace with function body.
	
func on_open():
	$VBoxContainer/HBoxContainer/value_size_x.value=grid.grid_size.x
	$VBoxContainer/HBoxContainer/value_size_y.value=grid.grid_size.y
	pass
	
func on_confirmed():
	grid.grid_size.x=$VBoxContainer/HBoxContainer/value_size_x.value
	grid.grid_size.y=$VBoxContainer/HBoxContainer/value_size_y.value
	grid.update()
	pass


