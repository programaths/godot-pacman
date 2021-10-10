extends Area2D
tool

var chmpnam_scr=preload("res://Chompman.gd")

func _draw():
	draw_circle(Vector2.ZERO,8,Color.beige)

func _ready():
	connect("area_entered",self,"hit")

func hit(obj:Area2D):
	if obj is chmpnam_scr:
		queue_free()
