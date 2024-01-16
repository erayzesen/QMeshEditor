extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



onready var app=get_tree().root.get_node("app")

onready var grid=app.get_node("grid")
onready var reference_image=app.get_node("canvas/reference_image")

onready var menu_btn_file=get_node("container/btn_file")
onready var menu_btn_edit=get_node("container/btn_edit")
onready var menu_btn_view=get_node("container/btn_view")
onready var menu_btn_help=get_node("container/btn_help")

onready var open_file_dialog=get_node("%open_file_dialog")
onready var save_file_dialog=get_node("%save_file_dialog")
onready var grid_settings_dialog=get_node("%grid_settings_dialog")
onready var image_settings_dialog=get_node("%image_settings_dialog")
onready var about_dialog=get_node("%about_dialog")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#MENU BUTTON - FILE
	menu_btn_file.get_popup().add_item("New",0)
	menu_btn_file.get_popup().set_item_shortcut(0,Global.shortcut_new_file,true)
	menu_btn_file.get_popup().add_item("Open",1)
	menu_btn_file.get_popup().set_item_shortcut(1,Global.shortcut_open_file,true)
	menu_btn_file.get_popup().add_item("Save",2)
	menu_btn_file.get_popup().set_item_shortcut(2,Global.shortcut_save_file,true)
	menu_btn_file.get_popup().add_item("Save As",3)
	menu_btn_file.get_popup().set_item_shortcut(3,Global.shortcut_save_as_file,true)
	menu_btn_file.get_popup().add_item("Exit",4)
	menu_btn_file.get_popup().set_item_shortcut(4,Global.shortcut_exit,true)
	menu_btn_file.get_popup().connect("id_pressed",self,"on_file_menu_item_pressed")
	
	#MENU BUTTON - EDIT
	menu_btn_edit.get_popup().add_separator("History",0)
	menu_btn_edit.get_popup().add_item("Undo",1)
	menu_btn_edit.get_popup().set_item_shortcut(1,Global.shortcut_undo,true)
	menu_btn_edit.get_popup().add_item("Redo",2)
	menu_btn_edit.get_popup().set_item_shortcut(2,Global.shortcut_redo,true)
	menu_btn_edit.get_popup().add_separator("Operations",3)
	menu_btn_edit.get_popup().add_item("Delete",4)
	menu_btn_edit.get_popup().set_item_shortcut(4,Global.shortcut_delete,true)
	menu_btn_edit.get_popup().add_item("Select All",5)
	menu_btn_edit.get_popup().set_item_shortcut(5,Global.shortcut_select_all,true)
	menu_btn_edit.get_popup().connect("id_pressed",self,"on_edit_menu_item_pressed")
	menu_btn_edit.connect("about_to_show",self,"on_edit_menu_open")
	
	#MENU BUTTON - VIEW
	menu_btn_view.get_popup().add_separator("Grid",-1)
	menu_btn_view.get_popup().add_check_item("Show Grid",1)
	menu_btn_view.get_popup().set_item_checked(1,true)
	menu_btn_view.get_popup().add_check_item("Snap To Grid",2)
	menu_btn_view.get_popup().add_item("Grid Settings",3)
	menu_btn_view.get_popup().add_separator("Reference Image",4)
	menu_btn_view.get_popup().add_check_item("Show Image",5)
	menu_btn_view.get_popup().set_item_checked(5,true)
	menu_btn_view.get_popup().add_item("Image Settings",6)
	menu_btn_view.get_popup().add_separator("Draws",7)
	menu_btn_view.get_popup().add_check_item("Show Polygons",8)
	menu_btn_view.get_popup().set_item_checked(8,true)
	menu_btn_view.get_popup().add_check_item("Show Springs",9)
	menu_btn_view.get_popup().set_item_checked(9,true)
	menu_btn_view.get_popup().add_check_item("Show Particles",10)
	menu_btn_view.get_popup().set_item_checked(10,true)
	menu_btn_view.get_popup().connect("id_pressed",self,"on_view_menu_item_pressed")
	menu_btn_view.connect("about_to_show",self,"on_view_menu_open")
	
	#MENU BUTTON - HELP
	menu_btn_help.get_popup().add_item("About")
	menu_btn_help.get_popup().connect("id_pressed",self,"on_help_menu_item_pressed")
	
	

	
	pass # Replace with function body.

func on_edit_menu_open() :
	var ur_manager=app.get_node("undoredo_manager")
	var popup=menu_btn_edit.get_popup()
	popup.set_item_disabled(1,!ur_manager.has_undo() )
	popup.set_item_disabled(2,!ur_manager.has_redo() )
	popup.set_item_disabled(4, !(app.selected_particles.size()>0 and app.tool_mode==app.tool_modes.SELECT)  )
	popup.set_item_disabled(5, !app.tool_mode==app.tool_modes.SELECT  )
	
func on_view_menu_open() :
	var popup=menu_btn_view.get_popup()
	popup.set_item_checked(2,app.snap_to_grid )
	
	
	

func on_file_menu_item_pressed(id:int):
	var popup=menu_btn_file.get_popup()
	var item_name=popup.get_item_text(id)
	if item_name=="New" :
		app.create_new_file()
	elif item_name=="Open" :
		open_file_dialog.popup()
	elif item_name=="Save" :
		if app.file_location=="" :
			save_file_dialog.popup()
		else :
			save_file_dialog.on_file_selected(app.file_location)
	elif item_name=="Save As" :
		save_file_dialog.popup()
	elif item_name=="Exit" :
		get_tree().quit()
	pass
	

		
	
func on_edit_menu_item_pressed(id:int):
	var popup=menu_btn_edit.get_popup()
	var item_name=popup.get_item_text(id)
	if item_name=="Undo" :
		app.get_node("undoredo_manager").undo()
		
	elif item_name=="Redo" :
		app.get_node("undoredo_manager").redo()
	elif item_name=="Delete" :
		app.remove_selected_particles()
	elif item_name=="Select All":
		app.select_all_particles()
	

func on_view_menu_item_pressed(id:int):
	var popup=menu_btn_view.get_popup()
	var item_name=popup.get_item_text(id)
	
	if popup.is_item_checked(id) :
		popup.set_item_checked(id,false)
	else:
		popup.set_item_checked(id,true)
	
	if item_name=="Show Grid" :
		grid.visible=popup.is_item_checked(id)
		
	elif item_name=="Snap To Grid" :
		app.snap_to_grid=popup.is_item_checked(id)
		
	elif item_name=="Grid Settings" :
		grid_settings_dialog.popup()
		pass
	elif item_name=="Show Image" :
		reference_image.visible=popup.is_item_checked(id)
		
	elif item_name=="Image Settings" :
		image_settings_dialog.popup()
	elif item_name=="Show Polygons" :
		app.show_polygons=popup.is_item_checked(id)
		
	elif item_name=="Show Springs" :
		app.show_springs=popup.is_item_checked(id)
	elif item_name=="Show Particles" :
		app.show_particles=popup.is_item_checked(id)
	pass
	
func on_help_menu_item_pressed(id:int):
	var popup=menu_btn_help.get_popup()
	var item_name=popup.get_item_text(id)
	if item_name=="About" :
		about_dialog.popup()
		

func set_shortcuts_to_menus() :
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
