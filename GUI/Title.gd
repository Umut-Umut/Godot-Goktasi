extends Control


onready var button_continue = $VBoxContainer/Continue


func _ready():
	pass
#	Gui.connect("return_menu", self, "return_menu")


func return_menu():
	button_continue.show()

