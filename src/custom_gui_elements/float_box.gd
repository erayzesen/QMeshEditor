extends LineEdit

class_name FloatBox
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var last_text=""
signal value_changed()
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("focus_entered",self,"on_focus_entered")
	connect("focus_exited",self,"on_focus_exited")
	connect("text_entered",self,"on_text_entered")

func on_focus_entered():
	last_text=text
	if text=="--" :
		text=""
func on_focus_exited():
	if text=="" or text.is_valid_float()==false:
		text=last_text
	else :
		on_text_entered(text)
		emit_signal("value_changed")
func on_text_entered(string:String):
	if(string.is_valid_float()==false) :
		text=last_text
	else :
		last_text=text.to_float()
		text=str(string.to_float())
	release_focus()
	if text.is_valid_float() :
		emit_signal("value_changed")

		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
