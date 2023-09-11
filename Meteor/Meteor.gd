class_name Meteor
extends StaticBody2D


signal destroyed


# ExplosiveDetector disabled


export (int, 3, 128) var num_segments : int = 12
export (int, 8, 500) var radius : int = 64
export (bool) var auto_create = true
export (bool) var auto_create_when_destroy = true


onready var chunks = $Chunks

onready var polygon_explosive = $Explosive
onready var polygon_meteor = $Meteor
onready var polygon_collision = $CollisionPolygon2D
onready var polygon_meteor_background = $Meteor/Bacground
onready var polygon_area_collision = $ExplosiveDetector/CollisionPolygon2D
onready var chunk_scene = preload("res://Chunk/Chunk.tscn")


var new_chunk

var big_polygon : PoolVector2Array
var big_polygon_area : float = 0
var polygon_area : float = 0
var big_polygon_index : int = 0

var is_clockwise : bool = false
var is_created : bool = false
var is_destroyed : bool = false
var is_settings_change : bool = false


var clip_polygon : Array
var explosive_local_points : PoolVector2Array


func _ready():
	randomize()
	
	polygon_explosive.hide()
	
#	if connect("destroyed", get_parent(), "_on_meteor_destroyed"): pass
#	if connect("destroyed", self, "_on_meteor_destroyed"): pass
	
	if auto_create:
		create_meteor()


func _physics_process(delta):
	rotate(delta)


func collision(collision_position : Vector2):
	explode(collision_position)


func create_meteor():
	if is_created and not is_settings_change:
		return
	
	set_meteor_polygon(PolygonMath.calc_circle_points(num_segments, radius), true)
	
	
	polygon_explosive.polygon = PolygonMath.calc_circle_points(12, 32)
	explosive_local_points = polygon_explosive.polygon
	
	
	is_created = true
	is_destroyed = false


func meteor_destroyed():
	drop_chunk(polygon_meteor.polygon)
	set_meteor_polygon(PoolVector2Array())
	
	is_created = false
	is_destroyed = true
	
	if auto_create_when_destroy:
		create_meteor()
	
	emit_signal("destroyed")
#	get_parent()._on_meteor_destroyed()


func drop_chunk(chunk_points : PoolVector2Array):
	new_chunk = chunk_scene.instance()
	var new_poly = Polygon2D.new()
	
	new_poly.color = polygon_meteor.color
	new_poly.polygon = chunk_points
	
	new_chunk.add_child(new_poly)
	
	new_chunk.gravity_scale = rand_range(1, 2)
	chunks.call_deferred("add_child", new_chunk)


func explode(collision_position : Vector2):
	polygon_explosive.global_position = collision_position
	
	for i in range(explosive_local_points.size()):
		explosive_local_points[i] = polygon_explosive.polygon[i] + polygon_explosive.position

	clip_polygon = Geometry.clip_polygons_2d(polygon_meteor.polygon, explosive_local_points)
	
	
	if clip_polygon.size() > 0:
		big_polygon_area = 0
		for i in range(clip_polygon.size()):
			polygon_area = PolygonMath.get_area(clip_polygon[i])
			if polygon_area > big_polygon_area:
				big_polygon_area = polygon_area
				big_polygon_index = i
			
		for i in range(clip_polygon.size()):
			if i != big_polygon_index:
				drop_chunk(clip_polygon[i])
		
		
		set_meteor_polygon(clip_polygon[big_polygon_index])
		
		
		if PolygonMath.get_area(clip_polygon[big_polygon_index]) < 1000:
			meteor_destroyed()
#			emit_signal("destroyed")
	else:
		meteor_destroyed()
#		emit_signal("destroyed")


func set_meteor_polygon(points : PoolVector2Array, is_update_back : bool = false):
	polygon_meteor.polygon = points
	polygon_collision.polygon = points
	
	if is_update_back:
		polygon_meteor_background.polygon = points


func new_settings(settings : Dictionary):
	if settings.has("side"):
		num_segments = settings["side"]
		is_settings_change = true
	if settings.has("radius"):
		radius = settings["radius"]
		is_settings_change = true

	if is_settings_change:
		create_meteor()
		is_settings_change = false

func _on_ExplosiveDetector_body_entered(body):
	# Area2D(ExplosiveDetector) disable
	if body is Bullet:
		body.disable()
		explode(body.global_position)
	
