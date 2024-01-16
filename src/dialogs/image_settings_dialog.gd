extends AcceptDialog

onready var app=get_tree().root.get_node("app")
onready var ref_image=get_node("%reference_image")
onready var load_image_dialog:FileDialog=get_node("%load_image_dialog")

func _ready():
	connect("about_to_show",self,"on_open")
	connect("confirmed",self,"on_confirmed")
	
	$VBoxContainer/btn_load.connect("pressed",self,"on_load_button_pressed")
	load_image_dialog.connect("file_selected",self,"on_image_file_selected")
	
	$VBoxContainer/value_pos_x.connect("value_changed",self,"on_value_pos_x_changed")
	$VBoxContainer/value_pos_y.connect("value_changed",self,"on_value_pos_y_changed")
	$VBoxContainer/value_opacity.connect("value_changed",self,"on_value_opacity_changed")
	
func on_open():
	$VBoxContainer/value_pos_x.value=ref_image.global_position.x
	$VBoxContainer/value_pos_y.value=ref_image.global_position.y
	$VBoxContainer/value_opacity.value=floor(ref_image.modulate.a*100)
	$VBoxContainer/LineEdit.text=app.reference_image_location
	pass
	
func on_confirmed():
	pass
	
func on_load_button_pressed():
	load_image_dialog.popup()
	pass

func on_image_file_selected(path:String) :
	var img=Image.new()
	var err=img.load(path)
	if err!=OK :
		return
	app.reference_image_location=path
	$VBoxContainer/LineEdit.text=path
	pass

func on_value_pos_x_changed(value):
	ref_image.global_position.x=value
	app.is_file_changed=true
	
func on_value_pos_y_changed(value):
	ref_image.global_position.y=value
	app.is_file_changed=true
	
func on_value_opacity_changed(value):
	ref_image.modulate.a=value/100
	app.is_file_changed=true
	pass
	
