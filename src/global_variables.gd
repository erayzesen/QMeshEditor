extends Node

var COLOR_PARTICLE=Color("#c2d368")
var COLOR_POLYGON=Color("#8ab060")
var COLOR_SPRING=Color("#7b7243")
var COLOR_INTERNAL_SPRING=Color("#7b7243")
var COLOR_GUIDE_SELECTED_PARTICLE=Color("#ede19e")
var COLOR_GUIDE_SPRING=Color("#646365")
var COLOR_GUIDE_POLYGON=Color("#646365")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shortcut_undo:ShortCut=ShortCut.new()
var shortcut_redo:ShortCut=ShortCut.new()
var shortcut_new_file:ShortCut=ShortCut.new()
var shortcut_open_file:ShortCut=ShortCut.new()
var shortcut_save_file:ShortCut=ShortCut.new()
var shortcut_save_as_file:ShortCut=ShortCut.new()
var shortcut_exit:ShortCut=ShortCut.new()
var shortcut_select_all:ShortCut=ShortCut.new()
var shortcut_delete:ShortCut=ShortCut.new()
var shortcut_show_grid:ShortCut=ShortCut.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	#undo
	var key_undo=InputEventKey.new()
	key_undo.scancode=KEY_Z
	key_undo.control=true
	shortcut_undo.shortcut=key_undo
	#redo
	var key_redo=InputEventKey.new()
	key_redo.scancode=KEY_Z
	key_redo.control=true
	key_redo.shift=true
	shortcut_redo.shortcut=key_redo
	#delete 
	var key_delete=InputEventKey.new()
	key_delete.scancode=KEY_DELETE
	shortcut_delete.shortcut=key_delete
	#select all
	var key_select_all=InputEventKey.new()
	key_select_all.scancode=KEY_A
	key_select_all.control=true
	shortcut_select_all.shortcut=key_select_all
	#new file
	var key_new_file=InputEventKey.new()
	key_new_file.scancode=KEY_N
	key_new_file.control=true
	shortcut_new_file.shortcut=key_new_file
	#open file
	var key_open_file=InputEventKey.new()
	key_open_file.scancode=KEY_O
	key_open_file.control=true
	shortcut_open_file.shortcut=key_open_file
	#save file
	var key_save_file=InputEventKey.new()
	key_save_file.scancode=KEY_S
	key_save_file.control=true
	shortcut_save_file.shortcut=key_save_file
	
	#save as file
	var key_save_as_file=InputEventKey.new()
	key_save_as_file.scancode=KEY_S
	key_save_as_file.control=true
	key_save_as_file.shift=true
	shortcut_save_as_file.shortcut=key_save_as_file
	
	#exit 
	var key_exit=InputEventKey.new()
	key_exit.scancode=KEY_Q
	key_exit.control=true
	shortcut_exit.shortcut=key_exit
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
