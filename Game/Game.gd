extends Node2D


signal meteor_destroyed

#
# Hala polygon un gorunmez olmasi gibi hatalar soz konusu. Kodu temizleyince umarim duzelir.
# Sanirim ayni anda birden fazla parcanin dusurulebilmesiyle bu sorun duzeldi.
#
# Geometry.triangulate_polygon fonksiyonu kullanilarak poligonlarin alani hesaplanabilir.
# veya The Shoelace Algorithm kullanilabilir. The Shoelace Algrithm daha kolay gibi.
#
# Eger Meteor icin StaticBody yerine RigidBody kullanirsam ve kopan parcalara Collision verirsem
# o zaman kopan parcalarin birbirine carpmasi vs. cok guzel olabilir.
#
# Meteor un merkezinde bir cekirdek olur ve bu cekirdekten bagi kopan parcalar dusebilir.
# En azindan kendi etrafinda donen alakasiz bir parcadansa bu daha mantikli
#
# Kopan parcalarin buyuklugune bagli olarak bir odullendirme sistemi yapilabilir.
#
# Gercek zamanli olarak ayarlar uzerinde yapilan degisiklikler arkaplanda meteora uygulanabilir.
#


onready var ship = $SpaceShip
onready var meteor = $Meteor


func _ready():
	if meteor.is_connected("destroyed", self, "_meteor_destroyed") == false:
		meteor.connect("destroyed", self, "_meteor_destroyed")
	
	meteor.create_meteor(12, 64)


func _meteor_destroyed():
	emit_signal("meteor_destroyed")


func set_process_input(state : bool):
	.set_process_input(state)
	for c in get_children():
		c.set_process_input(state)


func _on_BulletTravelLimit_body_entered(body):
	if body is Bullet:
		body.disable()
	
	if body is Chunk:
		body.disable()


























##	Gui.connect("game_over", self, "game_over")
#
#
#func reset():
#	pass
#
#
#func start_game(settings_parameter):
#	show()
#
#
#func meteor_destroyed():
#	Gui.emit_signal("game_over", "Göktaşını Yok Ettin...")
#	hide()
#
#	is_clear = true
#
#
#func return_menu():
#	pass
##	hide()
#
#
#func continue_game():
#	show(true)
##		body.hide()
##		body.set_process(false)
#
#
#func hide():
#	.hide()
#	for child in get_children():
#		child.set_process(false)
#		child.set_process_input(false)	
#
#
#func show(is_continue : bool = false):
#	if is_continue == false and is_clear:
#		if settings_data.has("radius") and settings_data.has("side"):
#			meteor.create_meteor(settings_data["side"], settings_data["radius"])
#		else:
#			meteor.create_meteor(12, 64 * 3)
#
#	.show()
#	for child in get_children():
#		child.set_process(true)
#		child.set_process_input(true)
